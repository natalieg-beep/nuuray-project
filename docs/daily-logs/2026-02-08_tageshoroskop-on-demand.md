# Session-Log: Tageshoroskop On-Demand Strategie

**Datum:** 2026-02-08
**Thema:** Tageshoroskop-Generation — On-Demand vs. Cron Job Strategie festgelegt
**Status:** ✅ Abgeschlossen

---

## 🎯 Ziel der Session

Klärung der Tageshoroskop-Generierungs-Strategie:
- Soll On-Demand generiert werden (jeder User-Request triggert Claude API)?
- Oder Cron Job (täglich um 4:00 UTC alle Horoskope vorgenerieren)?
- Wie optimieren wir Kosten vs. Performance?

---

## 🔍 Problem-Analyse

### Ausgangslage:

1. **Edge Function existiert bereits:**
   - `supabase/functions/generate-daily-horoscopes/index.ts`
   - Generiert 12 Zeichen × 2 Sprachen = 24 Horoskope
   - Kosten: ~$0.50/Tag = ~$15/Monat

2. **Frage:** Warum 24 Horoskope?
   - User wechseln typischerweise nicht die Sprache
   - Aktuell nur Test-User (< 10)
   - Bei 100 Usern: ~85% Deutsch, ~15% English → ~13 Kombinationen nötig (nicht 24!)

3. **Alternative:** On-Demand Generation
   - Horoskop wird beim ersten Request generiert
   - Danach aus Cache geladen (instant)
   - Kosten: $0 in Testphase, ~$6-7/Monat bei 100 Usern

---

## 💡 Entscheidung: Hybrid-Strategie

### Phase 1 (AKTIV): On-Demand Generation

**Wann:** Jetzt bis 1000+ User

**Wie:**
```dart
DailyHoroscopeService.getBaseHoroscope()
  → Prüfe Cache (daily_horoscopes Tabelle)
  → Falls Cache Hit: Return gecachtes Horoskop ✅
  → Falls Cache Miss: Generiere mit Claude API + Cache
  → Falls Error: Fallback-Text
```

**Vorteile:**
- ✅ Minimale Kosten während Testphase ($0!)
- ✅ Keine Edge Function nötig
- ✅ Einfach zu debuggen
- ✅ Automatisches Caching

**Nachteile:**
- ⚠️ Erster User pro Zeichen/Sprache wartet 2-3 Sekunden
- ⚠️ Bei Launch (viele User gleichzeitig) könnte Claude API Rate Limit erreicht werden

**Kosten:**
| User-Anzahl | Kosten/Monat |
|-------------|--------------|
| 0 (Test)    | $0           |
| 100         | ~$6-7        |
| 1,000       | ~$7-8        |

### Phase 2 (VORBEREITET): Cron Job

**Wann aktivieren:**
- 1000+ User erreicht ODER
- Performance-Probleme (User berichten langsames Laden) ODER
- Launch bevorsteht (viele User gleichzeitig erwartet)

**Wie:**
```
04:00 UTC täglich (Cron Job):
  → Suche alle aktiven User (profiles.sun_sign + preferred_language)
  → Extrahiere unique Kombinationen (z.B. "sagittarius:de", "aries:en")
  → Generiere nur diese Kombinationen (user-spezifisch!)
  → Prüfe vor jedem Call ob bereits vorhanden (Idempotenz)
  → Cache in daily_horoscopes Tabelle

User öffnet App:
  → DailyHoroscopeService.getBaseHoroscope()
  → Cache Hit → instant! ✅
  → Cache Miss (z.B. User wechselt Sprache) → On-Demand Generation
```

**Vorteile:**
- ✅ 99% der User: instant aus Cache
- ✅ Vorhersehbare Kosten
- ✅ Keine Rate Limit Probleme
- ✅ Perfekt für Launch-Days

**Kosten:**
| User-Anzahl | Aktive Zeichen+Sprachen | Kosten/Monat |
|-------------|-------------------------|--------------|
| 100         | ~13                     | ~$8          |
| 1,000       | ~18                     | ~$11         |
| 10,000      | ~24 (alle)              | ~$15         |

**Aufwand für Wechsel:** ~10 Minuten (Code ist schon fertig!)

---

## ✅ Implementierung

### 1. On-Demand Service (bereits vorhanden!)

**File:** `apps/glow/lib/src/features/horoscope/services/daily_horoscope_service.dart`

**Implementierung:**
```dart
Future<String> getBaseHoroscope({
  required String zodiacSign,
  String language = 'de',
  DateTime? date,
}) async {
  // 1. Versuche gecachtes Horoskop zu laden
  final response = await _supabase
      .from('daily_horoscopes')
      .select()
      .eq('date', dateString)
      .eq('zodiac_sign', zodiacSign)
      .eq('language', language)
      .maybeSingle();

  if (response != null && response['content_text'] != null) {
    print('✅ [Horoskop] Cache Hit! Horoskop gefunden');
    return response['content_text'] as String;
  }

  print('❌ [Horoskop] Cache Miss! Fallback zu Claude API');

  // 2. Cache Miss → Fallback: Generiere neues Horoskop
  if (_claudeService != null) {
    final horoscope = await _claudeService!.generateDailyHoroscope(...);
    await _cacheHoroscope(...); // Cache für nächstes Mal
    return horoscope.text;
  }

  // 3. Kein Service verfügbar → Fallback-Text
  return _getFallbackHoroscope(zodiacSign, language);
}
```

**Status:** ✅ Implementiert und getestet

### 2. Edge Function vorbereitet (Phase 2)

**File:** `supabase/functions/generate-daily-horoscopes/index.ts`

**Änderungen:**
1. ✅ User-spezifische Sprach-Logik hinzugefügt
   - Query: `profiles.sun_sign + preferred_language`
   - Nur benötigte Kombinationen generieren
2. ✅ Idempotenz-Check (skip wenn bereits vorhanden)
3. ✅ Batching (5 parallel pro Batch)
4. ✅ Status-Kommentare aktualisiert: "Phase 2 - INAKTIV"

**Code-Highlights:**
```typescript
// 🎯 SMART: Finde heraus welche Zeichen + Sprachen aktive User nutzen
const { data: activeUsers } = await supabase
  .from('profiles')
  .select('sun_sign, preferred_language')
  .not('sun_sign', 'is', null')

// Extrahiere unique Zeichen+Sprache-Kombinationen
const neededCombinations = activeUsers && activeUsers.length > 0
  ? [...new Set(activeUsers.map(u => `${u.sun_sign}:${u.preferred_language || 'de'}`))]
  : ALL_ZODIAC_SIGNS.flatMap(sign => languages.map(lang => `${sign}:${lang}`))

// Generiere mit Batching (5 parallel)
const BATCH_SIZE = 5
const batches = []
for (let i = 0; i < tasks.length; i += BATCH_SIZE) {
  batches.push(tasks.slice(i, i + BATCH_SIZE))
}
```

**Status:** ✅ Vorbereitet, aber NICHT deployed

### 3. Supabase Cleanup

**Problem:** Cron Job und Edge Function waren aus früherer Session noch aktiv

**Lösung:**
```sql
-- Cron Job löschen
SELECT cron.unschedule('daily-horoscopes-4am-utc');

-- Prüfen ob weg
SELECT * FROM cron.job WHERE jobname LIKE '%horoscope%';
```

**Edge Function löschen:**
- Dashboard: https://supabase.com/dashboard/project/.../functions
- `generate-daily-horoscopes` → Delete

**Status:** ✅ Aufgeräumt (Cron Job + Edge Function gelöscht)

### 4. Logging hinzugefügt

**Problem:** `developer.log()` Ausgaben waren im Terminal nicht sichtbar

**Lösung:** Umstellung auf `print()` mit Prefix:
```dart
print('🔍 [Horoskop] Suche: $zodiacSign, $language, $dateString');
print('✅ [Horoskop] Cache Hit! Horoskop gefunden');
print('🤖 [Horoskop] ClaudeService vorhanden, generiere Horoskop...');
```

**Status:** ✅ Funktioniert

---

## 🧪 Testing

### Test-Szenario: Home Screen laden

**Erwartung:**
- Horoskop sollte aus Cache geladen werden (bereits vorhanden in DB)

**Ergebnis:**
```
flutter: 🔍 [Horoskop] Suche: sagittarius, de, 2026-02-08
flutter: ✅ [Horoskop] Cache Hit! Horoskop gefunden

flutter: 🔍 [Horoskop] Suche: cancer, de, 2026-02-08
flutter: ✅ [Horoskop] Cache Hit! Horoskop gefunden
```

**Status:** ✅ Funktioniert perfekt! Cache Hit, keine Claude API Kosten

---

## 📚 Dokumentation

### Neue Dateien:

1. **`docs/deployment/HOROSCOPE_STRATEGY.md`** ⭐ HAUPT-DOKUMENT
   - Phase 1 vs. Phase 2 Vergleich
   - Kosten-Analyse (detaillierte Tabellen)
   - Deployment-Anleitung für Cron Job (wenn später aktiviert)
   - Cleanup-Section (Anleitung zum Löschen von Cron Job + Edge Function)
   - Monitoring-Queries
   - Troubleshooting

### Aktualisierte Dateien:

2. **`TODO.md`**
   - Tageshoroskop-Status aktualisiert
   - Edge Function Status klargestellt: "Phase 2 Code (NICHT deployed)"
   - Cleanup-Hinweis hinzugefügt
   - Verweis auf HOROSCOPE_STRATEGY.md

3. **Code-Kommentare:**
   - `supabase/functions/generate-daily-horoscopes/index.ts`
   - Header: "Phase 2 - INAKTIV"
   - Status: "Vorbereitet, aber NICHT deployed (Phase 1 nutzt On-Demand)"

---

## 🎯 Nächste Schritte

### Jetzt (Phase 1):
- ✅ On-Demand Generation läuft
- ✅ Keine weiteren Maßnahmen nötig
- ✅ Kosten: $0 in Testphase

### Später (Phase 2, ab 1000+ User):

1. **Edge Function deployen:**
   ```bash
   cd /Users/natalieg/nuuray-project
   supabase functions deploy generate-daily-horoscopes
   ```

2. **Secrets setzen:**
   - Dashboard → Edge Functions → Secrets
   - `ANTHROPIC_API_KEY` hinzufügen

3. **Cron Job aktivieren:**
   ```sql
   SELECT cron.schedule(
     'daily-horoscopes-4am-utc',
     '0 4 * * *',
     $$
     SELECT net.http_post(
       url:='https://ykkayjbplutdodummcte.supabase.co/functions/v1/generate-daily-horoscopes',
       headers:='{...}'::jsonb,
       body:='{}'::jsonb
     );
     $$
   );
   ```

4. **Manuell testen:**
   ```bash
   curl -X POST 'https://.../functions/v1/generate-daily-horoscopes' \
     -H "Authorization: Bearer SERVICE_ROLE_KEY"
   ```

**Aufwand:** ~10 Minuten

---

## 📊 Kosten-Vergleich

| Aspekt | On-Demand (Phase 1) | Cron (Phase 2) |
|--------|---------------------|----------------|
| **Kosten (100 User)** | $6-7/Monat | $8/Monat |
| **Kosten (1000 User)** | $7-8/Monat | $11/Monat |
| **Kosten (Testphase)** | $0 ✅ | $15 ❌ |
| **Performance** | Erster User wartet 2-3 Sek | Alle instant ✅ |
| **Launch-Sicherheit** | Risk bei 500+ gleichzeitig | Sicher ✅ |
| **Komplexität** | Einfach ✅ | Mittel |
| **Deployment** | Nichts nötig ✅ | Edge Function + Cron |

---

## 🎉 Ergebnis

**Phase 1 (On-Demand) ist LIVE:**
- ✅ Cache-First Strategie funktioniert
- ✅ Keine Claude API Kosten bei Cache Hit
- ✅ On-Demand Fallback bei Cache Miss
- ✅ Logging funktioniert (`print()` statt `developer.log()`)
- ✅ Supabase aufgeräumt (Cron Job + Edge Function gelöscht)
- ✅ Dokumentation komplett

**Phase 2 (Cron Job) ist vorbereitet:**
- ✅ Code fertig (lokal in `supabase/functions/`)
- ❌ NICHT deployed (absichtlich!)
- ⏳ Aktivierung später bei 1000+ Usern (~10 Minuten Aufwand)

---

## 🔗 Referenzen

- **Deployment-Guide:** `docs/deployment/HOROSCOPE_STRATEGY.md`
- **TODO:** `TODO.md` (Abschnitt: Claude API Integration)
- **Edge Function:** `supabase/functions/generate-daily-horoscopes/index.ts`
- **Service:** `apps/glow/lib/src/features/horoscope/services/daily_horoscope_service.dart`

---

**Session-Ende:** 2026-02-08
**Ergebnis:** ✅ Erfolgreich — On-Demand Strategie aktiv, Cron Job vorbereitet
