# Claude API Integration — Nuuray Glow

> **Status:** ✅ Implementiert (2026-02-07)
> **Testing:** ⏳ Ausstehend (API Key erforderlich)

---

## Übersicht

Die Claude API (Anthropic) wird für Content-Generierung in Nuuray Glow verwendet:

- **Tageshoroskope** (80-120 Wörter, gecacht)
- **Cosmic Profile Interpretationen** (400-500 Wörter, Premium)
- **Wochen-/Monatshoroskope** (Premium, später)
- **Partner-Check** (Premium, später)

---

## Service-Architektur

### ClaudeApiService

**Location:** `apps/glow/lib/src/core/services/claude_api_service.dart`

**Features:**
- ✅ Tageshoroskop-Generierung (mit Mondphase)
- ✅ Cosmic Profile Interpretation (Western + Bazi + Numerologie)
- ✅ Token-Usage Tracking (für Kosten-Kalkulation)
- ✅ Deutsche + Englische Prompts
- ✅ System-Prompts für konsistenten Ton

**Model:** `claude-sonnet-4-20250514` (optimales Preis-Leistungs-Verhältnis)

---

## Prompt-Strategie

### 1. System-Prompts

Definieren den Charakter und Ton:

**Tageshoroskope:**
- Unterhaltsam & inspirierend (wie eine gute Freundin)
- Staunend über die Magie des Kosmos
- Bodenständig & realistisch (keine leeren Versprechen)
- Empowernd (Fokus auf Handlungsfähigkeit)

**Cosmic Profile:**
- Warm, einfühlsam, empowernd
- Synthese aller drei Systeme (nicht Auflistung)
- Konkrete Lebens-Impulse (nicht abstrakt)
- Kein esoterischer Jargon

### 2. User-Prompts (Templates)

**Tageshoroskop:**
```
Schreibe ein Tageshoroskop für das Sternzeichen **{zodiacName}** für den {date}.

Die aktuelle Mondphase ist: {moonPhase}.

**Anforderungen:**
- Länge: 80-120 Wörter
- Ton: Unterhaltsam, staunend, inspirierend
- Fokus: Tagesenergie, kleine Handlungsempfehlungen, emotionale Insights
- Keine generischen Floskeln
- Direkte Ansprache ("Du")

**Format:**
Nur der Fließtext, keine Überschrift.
```

**Cosmic Profile:**
```
Erstelle eine personalisierte Interpretation des Cosmic Profile für:

**Westliche Astrologie:**
- Sonnenzeichen: {sunSign}
- Mondzeichen: {moonSign}
- Aszendent: {ascendant}

**Bazi:**
- Day Master: {baziDayMaster}

**Numerologie:**
- Life Path Number: {lifePathNumber}

**Aufgabe:**
Synthese der drei Systeme zu EINEM stimmigen Text über die Persönlichkeit.

**Anforderungen:**
- Länge: 400-500 Wörter
- Ton: Warm, einfühlsam, empowernd
- Struktur: Einleitung, Stärken, Herausforderungen, Lebensweg
- Keine Auflistungen, sondern fließender Text
```

---

## Kosten-Kalkulation

### Claude Sonnet 4 Pricing (Stand Feb 2026)

| Typ | Preis |
|-----|-------|
| Input | $3.00 / 1M tokens |
| Output | $15.00 / 1M tokens |

### Beispiel-Kosten

**Tageshoroskop (120 Wörter):**
- Input: ~200 tokens (Prompt)
- Output: ~150 tokens (Horoskop)
- **Kosten: ~$0.0029** (< 0.3 Cent)

**Cosmic Profile (500 Wörter):**
- Input: ~300 tokens
- Output: ~600 tokens
- **Kosten: ~$0.01** (1 Cent)

### MVP-Budget

**Tageshoroskope (gecacht):**
- 12 Sternzeichen × 1 Horoskop/Tag = 12 Calls/Tag
- **Kosten: ~$0.035/Tag = $1.05/Monat** 💰

**Cosmic Profile (on-demand):**
- 1000 User × $0.01 = **$10/Monat**

**Total MVP:** ~$11/Monat (extrem günstig!)

---

## Caching-Strategie

### Tageshoroskope

**Problem:** 1000 User × 12 Sternzeichen = 12.000 API Calls/Tag = $35/Tag

**Lösung:** Basis-Horoskope vorab generieren (Cron Job)

```
04:00 UTC → Edge Function generiert 12 Horoskope (eins pro Sternzeichen)
          → Speichert in `daily_horoscopes` Tabelle
          → Cache: 24h

User öffnet App → Lädt gecachtes Horoskop aus Supabase
               → KEIN Claude API Call
```

**Einsparung:** 12.000 → 12 Calls/Tag = **99.9% weniger Kosten**

### Cosmic Profile

- On-Demand beim ersten Profil-Aufruf
- Cache in `birth_charts` Tabelle (JSONB Feld `interpretation`)
- Regenerierung nur wenn User explizit anfordert

---

## Setup

### 1. API Key erhalten

1. Gehe zu: https://console.anthropic.com
2. Erstelle ein Konto (oder login)
3. Gehe zu "API Keys" → "Create Key"
4. Kopiere den Key (beginnt mit `sk-ant-...`)

### 2. Environment Variable setzen

Füge in `apps/glow/.env` hinzu:

```bash
ANTHROPIC_API_KEY=sk-ant-api03-...
```

**WICHTIG:** Diese Datei ist in `.gitignore` → wird NICHT committed!

### 3. Service nutzen

```dart
import 'package:nuuray_glow/src/core/services/claude_api_service.dart';

final claudeService = ClaudeApiService(
  apiKey: dotenv.env['ANTHROPIC_API_KEY']!,
);

// Tageshoroskop generieren
final response = await claudeService.generateDailyHoroscope(
  zodiacSign: 'cancer',
  language: 'de',
  moonPhase: 'waxing_moon',
);

print(response.text);
print('Kosten: \$${response.estimatedCost}');
```

---

## Testing

### Manueller Test

```bash
# 1. API Key in .env setzen
export ANTHROPIC_API_KEY=sk-ant-...

# 2. Test-Script ausführen
cd apps/glow
dart test/test_claude_api.dart
```

**Erwartete Ausgabe:**
```
🧪 Testing Claude API Service...

✅ Service initialisiert

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔮 Test 1: Tageshoroskop für Krebs (Deutsch)

✅ Horoskop generiert!

📝 INHALT:
───────────────────────────────────────────────────────
Heute lädt dich die zunehmende Energie des Mondes ein, ...
───────────────────────────────────────────────────────

📊 METADATEN:
   Model: claude-sonnet-4-20250514
   Input Tokens: 198
   Output Tokens: 147
   Total Tokens: 345
   Kosten: $0.0028
   Dauer: 1243ms

✅ Länge: 118 Wörter (Ziel: 80-120)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎉 Alle Tests erfolgreich!
```

---

## Integration in App

### 1. DailyHoroscopeService erstellen

**Location:** `apps/glow/lib/src/features/horoscope/services/daily_horoscope_service.dart`

```dart
class DailyHoroscopeService {
  final ClaudeApiService _claudeService;
  final SupabaseClient _supabase;

  Future<String> getTodaysHoroscope(String zodiacSign) async {
    // 1. Versuche gecachtes Horoskop zu laden
    final cached = await _loadCachedHoroscope(zodiacSign);
    if (cached != null) return cached;

    // 2. Fallback: Generiere neues Horoskop (sollte nicht passieren)
    final response = await _claudeService.generateDailyHoroscope(
      zodiacSign: zodiacSign,
      language: 'de',
    );

    // 3. Cache in Supabase
    await _cacheHoroscope(zodiacSign, response.text);

    return response.text;
  }
}
```

### 2. Edge Function für Cron Job

**Location:** `supabase/functions/generate-daily-horoscopes/index.ts`

```typescript
// Läuft täglich um 04:00 UTC
Deno.serve(async (req) => {
  const zodiacSigns = ['aries', 'taurus', 'gemini', ...];

  for (const sign of zodiacSigns) {
    // Claude API Call via ClaudeApiService
    const horoscope = await generateHoroscope(sign);

    // In Supabase speichern
    await supabase.from('daily_horoscopes').insert({
      date: new Date(),
      zodiac_sign: sign,
      language: 'de',
      content_text: horoscope.text,
      tokens_used: horoscope.totalTokens,
    });
  }

  return new Response('OK');
});
```

**Cron Config:** `supabase/functions/_shared/cron.json`

```json
{
  "schedules": [
    {
      "name": "generate-daily-horoscopes",
      "schedule": "0 4 * * *",
      "function": "generate-daily-horoscopes"
    }
  ]
}
```

---

## Prompts verbessern

### A/B Testing

1. Generiere 2 Varianten mit leicht unterschiedlichen Prompts
2. Zeige User Random-Variante
3. Tracke Engagement (Zeit auf Screen, Sharing)
4. Nutze bessere Variante

### Feedback-Loop

- User kann Horoskop "liken" oder "nicht so gut" markieren
- Negative Beispiele sammeln → Prompt verfeinern

---

## Rate Limiting

Claude API Limits:
- **Tier 1 (neue Accounts):** 50 Requests/Min
- **Tier 2:** 100 Requests/Min
- **Tier 3:** 200 Requests/Min

**MVP:** 12 Requests/Tag (Tageshoroskope) → kein Problem
**Skalierung:** Bei 10.000 Usern mit On-Demand Profile → Tier 2 erforderlich

---

## Alternativen (falls Budget knapp)

1. **OpenAI GPT-4o Mini** — günstiger, aber weniger Qualität
2. **Gemini Pro** — Google's Alternative (noch günstiger)
3. **Lokales Model** — Llama 3 auf eigenem Server (hohe Setup-Kosten)

**Empfehlung:** Bei Claude bleiben für MVP (beste Qualität, geringe Kosten)

---

## Security

### API Key Protection

- ✅ API Key nur in `.env` (nicht in Git)
- ✅ Edge Functions nutzen Service Role (Server-seitig)
- ✅ Client-seitige Calls nur über Supabase Edge Functions

### Rate Limiting (App-seitig)

```dart
// Max 5 Regenerierungen pro Tag (um Missbrauch zu vermeiden)
final regenerateCount = await getUserRegenerateCount(userId);
if (regenerateCount >= 5) {
  throw Exception('Limit erreicht');
}
```

---

## Next Steps

- [x] Service implementiert ✅
- [x] Test-Script geschrieben ✅
- [ ] API Key von Natalie holen
- [ ] Manueller Test durchführen
- [ ] DailyHoroscopeService bauen
- [ ] Edge Function für Cron Job
- [ ] Supabase Cron Job konfigurieren
- [ ] UI Integration (Home Screen)

---

**Stand:** 2026-02-07
**Autor:** Claude + Natalie
**Status:** Ready for Testing
