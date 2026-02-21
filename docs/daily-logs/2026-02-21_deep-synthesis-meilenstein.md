# Session-Log: 2026-02-21 — Tiefe Drei-System-Synthese Meilenstein

> **Zusammenfassung:** Das Herzstück der Glow App ist fertig. Die Tiefe Drei-System-Synthese generiert eine 900-1200 Wörter lange, KI-generierte Lebensgeschichte die alle drei astrologischen Systeme kausal verwebt. Erste Probeleser-Reaktionen: "Das ist der Hammer."

---

## Was wurde gebaut

### Feature: DeepSynthesisSection

Die Tiefe Synthese ist die wichtigste Premium-Sektion im Signatur-Screen. Sie steht am Ende der Seite — nach Western Astrology, Bazi und Numerologie — und verwebt alle drei Systeme zu einer vollständigen Geschichte.

**Wo im Code:**
- Widget: `apps/glow/lib/src/features/signature/widgets/premium_synthesis_section.dart`
- Service: `apps/glow/lib/src/core/services/claude_api_service.dart` (Methoden: `generateDeepSynthesis`, `_buildDeepSynthesisSystemPrompt`, `_buildDeepSynthesisPrompt`)
- Provider: `deepSynthesisProvider` (FutureProvider.family<String, BirthChart>)
- DB-Migration: `supabase/migrations/20260221_add_deep_synthesis_text.sql`

**Wie es funktioniert:**
1. `deepSynthesisProvider` wird beim Öffnen des Signatur-Screens aufgerufen
2. Zuerst: Cache-Check in `profiles.deep_synthesis_text` (Supabase)
3. Wenn Cache leer: Claude API Call mit `generateDeepSynthesis()`
4. Ergebnis wird in DB gecacht → nächstes Öffnen sofort verfügbar
5. Debug-Build: Long-Press auf Refresh-Icon löscht Cache für Neugenerierung

**UI-States:**
- Loading: Goldener Container mit CircularProgressIndicator + "Deine Synthese wird berechnet..."
- Error: Roter Container mit "Erneut versuchen" Button
- Data: Weißer Container mit goldener Akzentlinie, Fließtext in Absätzen, "Deine NUURAY Signatur" Footer

---

## Prompt-Architektur: Von 5-Schritt-Bogen zu 3-Spannungsfeldern

### Das Problem mit dem 5-Schritt-Bogen

Der ursprüngliche 5-Schritt-Bogen (Hook → Psyche & Spannung → Energie-Wahrheit → Seelenweg → Auflösung → Impuls) war gut für kurze Texte (Tageshoroskope, Mini-Synthese). Für 900-1200 Wörter führte er dazu, dass die Systeme nacheinander abgearbeitet wurden — aufgelistet statt verwoben.

**Beispiel für das alte Problem:**
> "Als Schütze mit Lebenszahl 7 und Yang-Feuer Day Master trägst du eine besondere Energie. Dein Schütze ist abenteuerlustig und liebt Freiheit. Im Bazi zeigt dein Yang-Feuer Day Master, dass du Wärme und Enthusiasmus austrahlst. Deine Lebenszahl 7 spricht von Tiefgang und Spiritualität."

Das ist Aufzählung. Die Systeme stehen nebeneinander, erklären sich nicht gegenseitig.

### Die Lösung: Kausale Verbindungen

Inspiriert durch die Analyse von Beyond Horoscope Premium-Reports: Die Systeme müssen sich gegenseitig *erklären*. System A zeigt das Problem. System B nennt die Ursache. System C benennt warum das so sein *muss*.

**Pflicht-Formulierungen für kausale Verbindungen:**
- "...und genau deshalb..."
- "...was erklärt, warum du..."
- "...das ist kein Zufall, denn..."
- "...weil dein [Element/Zahl] gleichzeitig..."

**Neue Struktur pro Spannungsfeld:**
1. Erlebbarer Einstieg ("Du kennst das, wenn...")
2. Was die Psyche will/fürchtet (Westlich)
3. KAUSAL: Wie Bazi das verstärkt/bremst/umlenkt
4. KAUSAL: Was Numerologie als tiefere Wahrheit benennt (WARUM die Spannung existiert)
5. Auflösung: Die integrierte Erkenntnis

---

## Kritische Bugfixes dieser Session

### 1. FutureProvider.family Cache-Reset

**Bug:** Cache-Reset hat nicht funktioniert. Synthese wurde nach Reset nicht neu generiert.

**Ursache:**
```dart
// FALSCH — ohne Parameter:
ref.invalidate(deepSynthesisProvider);

// RICHTIG — mit Parameter (family braucht den konkreten Wert!):
ref.invalidate(deepSynthesisProvider(birthChart));
```

`FutureProvider.family` erstellt für jeden Parameter eine separate Provider-Instanz. `invalidate` ohne Parameter macht bei family-Providern nichts (oder invalidiert alle — aber das war nicht das Problem). Der konkrete BirthChart-Parameter muss übergeben werden.

**Fix:** `resetDeepSynthesisCache(WidgetRef ref, BirthChart birthChart)` — BirthChart-Parameter hinzugefügt und in der Funktion verwendet.

### 2. Gender-Bug: Weibliche Ansprache für männliche User

**Symptom:** Texte enthielten "Die Fürsorgliche", "sie", feminine Adjektive — obwohl User männlich ist.

**Ursache:** Mehrere:
1. ANSPRACHE-Block stand weit unten im System-Prompt → Claude anchored an frühe Tokens
2. Hardcoded "sie" im Prompt-Text selbst
3. `displayName: ?? 'Nutzerin'` in `user_profile.dart`

**Fix:**
- ANSPRACHE-Block ganz nach oben im System-Prompt (erste inhaltliche Anweisung)
- Alle "sie/Nutzerin" → "diese Person" (neutrale Formulierung)
- `displayName: ?? 'Nutzerin'` → `?? ''`

**Learning:** Claude anchored an frühe Tokens. Die ANSPRACHE-Anweisung muss die ERSTE wichtige Information nach der Rollenbeschreibung sein.

### 3. Refresh-Icon funktionierte nicht

**Problem:** Der ConsumerWidget-Scope war nicht korrekt. `_buildSynthesisContent()` war eine Methode auf dem Parent-Widget — der verschachtelte `Consumer` hatte den falschen ref-Scope.

**Fix:** `_SynthesisContent` als eigenständiges `ConsumerWidget` extrahiert. Jetzt hat das Widget seinen eigenen `ref` mit direktem Zugriff.

---

## SCHATTENSEITEN-Regel: Die wichtigste Prompt-Innovation

Feedback von ersten Probelesern: "Da steht ja nur alles Gute und nichts Schlechtes."

Das ist ein systemisches Problem: Claude schreibt ohne explizite Anweisung fast immer positiv. Texte klingen dann wie eine Lobrede — angenehm, aber nicht ehrlich und nicht nützlich.

**Die Lösung — explizite Verhältnis-Vorgabe:**
```
SCHATTENSEITEN SIND PFLICHT — KEIN WEICHSPÜLEN:
- Jedes Spannungsfeld muss den konkreten PREIS benennen
- Verhältnis: 40% Stärke, 40% ehrlicher Preis/Schatten, 20% Auflösung
- NICHT: "Das kann manchmal eine Herausforderung sein" (Euphemismus)
- SONDERN: "Du weißt selbst wie oft du...", "Dieser Zug kostet dich..."
- VERBOTEN: Text der nach dem Lesen kein Unbehagen hinterlässt
```

**Warum 40/40/20?**
- Mehr als 50% Schatten wäre entmutigend
- Weniger als 30% Schatten klingt nicht ehrlich
- 40/40/20 trifft den Sweet Spot: Ehrlich genug um zu überraschen, aufgelöst genug um zu empowern

---

## Geburtszeit-Handling

Nicht alle User kennen ihre Geburtszeit. Ohne Geburtszeit fehlen:
- Mondzeichen (Western Astrology)
- Aszendent (Western Astrology)
- Bazi Stundensäule

**Prompt-Lösung:**
```dart
final birthTimeNoteDE = hasBirthTime
    ? ''
    : '\nHINWEIS DATENVOLLSTÄNDIGKEIT: Für diese Person liegt keine Geburtszeit vor. '
      'Mondzeichen, Aszendent und Bazi-Stundensäule sind daher nicht berechenbar. '
      'Arbeite ausschließlich mit den vorhandenen Daten. '
      'Erwähne diese Lücke NICHT im Text — schreibe, was die vorhandenen Daten zeigen, '
      'ohne auf fehlende Informationen hinzuweisen.\n';
```

**UI-Lösung:** `WesternAstrologySection` zeigt einen dezenten Hinweis wenn Mond UND Aszendent fehlen: "Mond & Aszendent fehlen. Ergänze deine Geburtszeit im Profil für ein vollständiges Bild."

---

## Kosten-Kalkulation

| Messgröße | Wert |
|-----------|------|
| Input Tokens (geschätzt) | ~500 |
| Output Tokens (geschätzt) | ~900-1100 |
| Kosten pro Call | ~$0.012-0.015 |
| Caching | Einmalig pro User |
| Kosten nach Cache-Hit | $0 |
| Bei 1.000 Users (Erstgenerierung) | ~$12-15 |
| Bei 10.000 Users (Erstgenerierung) | ~$120-150 |

**Wichtig:** `max_tokens: 4096` ist notwendig. Der Standard-Wert von 2048 würde Claude bei ~600-700 Wörtern abschneiden, mitten im Text.

---

## Nächste Schritte nach diesem Meilenstein

Direkt nach der Synthese (kurzfristig):
1. **Text kopierbar machen** — `SelectableText` statt `Text` in `_SynthesisContent`
2. **PDF Export** — `printing` Package, NUURAY-styled (kann auf LuxuryPdfGenerator aufbauen)
3. **Cache-Invalidierung bei Profil-Änderung** — `deep_synthesis_text: null` beim Profile-Edit

Mittelfristig:
4. **Unit Tests** für alle 3 Kalkulatoren (KRITISCH vor Launch)
5. **Content Library EN** — 254 englische Texte (~$0.76)

---

## Dateien geändert in dieser Session

| Datei | Was |
|-------|-----|
| `apps/glow/lib/src/core/services/claude_api_service.dart` | `generateDeepSynthesis()`, `_buildDeepSynthesisSystemPrompt()`, `_buildDeepSynthesisPrompt()`, `_callClaudeWithMaxTokens()`, `_buildBaziContext()`, `_buildNumerologyContext()`, `_getBaziElementName()`, `_getZodiacNameEn()`, Gender-Bugfixes |
| `apps/glow/lib/src/features/signature/widgets/premium_synthesis_section.dart` | Komplett neu: `deepSynthesisProvider`, `resetDeepSynthesisCache()`, `DeepSynthesisSection`, `_SynthesisContent` |
| `apps/glow/lib/src/features/signature/screens/signature_screen.dart` | `DeepSynthesisSection` integriert, Placeholder entfernt |
| `apps/glow/lib/src/features/signature/widgets/western_astrology_section.dart` | `_buildMissingBirthTimeHint()` hinzugefügt |
| `packages/nuuray_core/lib/src/models/user_profile.dart` | `displayName: ?? 'Nutzerin'` → `?? ''` |
| `supabase/migrations/20260221_add_deep_synthesis_text.sql` | Neu: `deep_synthesis_text TEXT NULL` Spalte |
| `docs/NUURAY_BRAND_SOUL.md` | Abschnitt 6b: Deep Synthesis Prompt-Architektur |
| `docs/daily-logs/2026-02-21_deep-synthesis-meilenstein.md` | Diese Datei |
| `docs/README.md` | Aktualisiert |
| `TODO.md` | Session-Block + neue Tasks |

---

*Erstellt: 2026-02-21 | Session-Typ: Feature-Implementierung + Prompt-Engineering*
