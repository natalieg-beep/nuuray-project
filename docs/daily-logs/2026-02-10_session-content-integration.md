# Session 2026-02-10: Content Library Integration + Gender Tracking

## ✅ Abgeschlossen

### 1. **Content Library Service Integration**
- `ContentLibraryService` Provider zu `app_providers.dart` hinzugefügt
- `currentLocaleProvider` erstellt (liefert Locale-String aus `languageProvider`)
- Western Astrology Section: Lädt echte Texte aus Content Library (Sonne, Mond, Aszendent)
- Bazi Section: Lädt Day Master Text aus Content Library
- Numerology Section: Lädt Life Path, Soul Urge, Expression Numbers aus Content Library
- FutureBuilder für async Content-Loading
- In-Memory Caching durch ContentLibraryService

### 2. **RLS Policy Fix für daily_horoscopes**
- Migration `20260210_fix_daily_horoscopes_rls.sql` erstellt
- Policy erlaubt jetzt authenticated users das Einfügen von Horoskopen
- Horoskop-Generierung funktioniert jetzt ohne RLS-Fehler

### 3. **Gender-Tracking im Onboarding** ✅
- **DB Migration:** `20260210_add_gender_to_profiles.sql`
  - Spalte `gender TEXT CHECK (gender IN ('female', 'male', 'diverse', 'prefer_not_to_say'))`
  - Index für schnellere Abfragen
- **UserProfile Model erweitert:**
  - `final String? gender` Feld hinzugefügt
  - fromJson, toJson, copyWith, props aktualisiert
- **Onboarding UI:**
  - Neuer Screen: `onboarding_gender_screen.dart`
  - 4 Optionen: Weiblich 👩, Männlich 👨, Divers ✨, Keine Angabe 🤐
  - Auto-advance nach 400ms (smooth UX)
- **Onboarding Flow aktualisiert:**
  - Jetzt 3 Schritte: Name → Gender → Geburtsdaten
  - Fortschrittsbalken: `(_currentPage + 1) / 3`
  - Gender-Daten werden in Profil gespeichert

### 4. **Deutsche Sternzeichen-Namen** ✅
- Neue Datei: `packages/nuuray_core/lib/src/l10n/zodiac_names.dart`
- `ZodiacNames.de` Map: `sagittarius` → `Schütze`
- `ZodiacNames.en` Map: `sagittarius` → `Sagittarius`
- `ZodiacNames.getName(sign, locale)` Helper-Funktion
- Western Astrology Section nutzt jetzt lokalisierte Namen
- **Vorher:** "Sagittarius in Sonne" ❌
- **Nachher:** "Schütze in Sonne" ✅

## ⏳ In Progress

### 5. **Numerologie Section vervollständigen**
Aktuell nur 3 Zahlen (Life Path, Soul Urge, Expression).

**Fehlend aus BirthChart:**
- `displayNameNumber` (Rufname-Numerologie)
- `birthdayNumber`
- `attitudeNumber`
- `maturityNumber`
- `personalYear` (wahrscheinlich dynamisch berechnet)
- **Birth Energy (expandable):**
  - `birthExpressionNumber`
  - `birthSoulUrgeNumber`
  - `birthPersonalityNumber`
- **Current Energy (expandable):**
  - `currentExpressionNumber`
  - `currentSoulUrgeNumber`
  - `currentPersonalityNumber`
- **Erweiterte Numerologie:**
  - `karmicDebtLifePath`
  - `karmicDebtExpression`
  - `karmicDebtSoulUrge`
  - `challengeNumbers` (List<int>)
  - `karmicLessons` (List<int>)
  - `bridgeLifePathExpression`
  - `bridgeSoulUrgePersonality`

**Content Library Abdeckung:**
- ✅ Life Path Numbers (1-9, 11, 22, 33) → vorhanden
- ✅ Soul Urge Numbers (1-9, 11, 22, 33) → vorhanden
- ✅ Expression Numbers (1-9, 11, 22, 33) → vorhanden
- ❌ Birthday, Attitude, Maturity → FEHLEN in Content Library
- ❌ Karmic Debt, Challenge, Lessons, Bridges → FEHLEN in Content Library

**TODO:**
- Numerology Section UI erweitern (alle Zahlen anzeigen)
- Content Library Seeds für fehlende Kategorien generieren

## 🐛 Offene Bugs

### Bazi Beschreibung lädt nicht
**Symptom:** "Lädt..." bleibt hängen, Content wird nicht geladen.

**Mögliche Ursachen:**
1. `birthChart.baziElement` hat falsches Format (sollte z.B. `yang_wood_rat` sein)
2. Kein Eintrag in Content Library für diesen Key
3. FutureBuilder hängt (Query-Fehler)

**Debug-Schritte:**
1. User-Profil prüfen: Welcher Wert steht in `baziElement`?
2. Content Library prüfen: Existiert Eintrag für `category='bazi_day_master'` + `key=<baziElement>` + `locale='de'`?
3. Browser DevTools: Supabase Query-Fehler im Network Tab?

## 📝 Nächste Schritte

1. **Bazi Debug** (Priorität 1)
   - User-Profil Bazi-Wert checken
   - Content Library Eintrag verifizieren
   - Falls fehlt: Manuell hinzufügen oder Seed-Script fixen

2. **Numerologie vervollständigen** (Priorität 2)
   - Fehlende Content Library Kategorien generieren (Birthday, Attitude, Maturity, Karmic Debt, etc.)
   - UI erweitern: Collapsible Sections für Birth/Current Energy
   - Erweiterte Numerologie als separater Bereich

3. **Content Review + Neu-Generierung** (Priorität 3)
   - Seed-Prompts mit `{gender}` Variable erweitern
   - Content Library komplett neu generieren (mit besseren Prompts)
   - Tone verbessern: Weniger generisch, mehr konkret und überraschend

4. **Bazi Vier Säulen** (Priorität 4 - großes Feature)
   - Bazi Calculator erweitern (Year, Month, Day, Hour Pillar berechnen)
   - Tabellen-UI für alle 4 Säulen
   - Content Library für alle Säulen-Kombinationen (sehr viele!)

## 🎯 User Feedback

> "bei westliche Astrologie Sagittarius in Sonne/Libra im Mond/ Leo in Aszendent --> für die deutsche Sprache geht das so nicht, da müssen die deutschen Sternzeichen bezeichnungen hin."

✅ **FIXED:** Deutsche Namen werden jetzt angezeigt.

> "Der Text ist halt gernerell auch mega langweilig --> Bitte mal auf die Todo.txt --> Review Content"

⏳ **TODO:** Content Review + Neu-Generierung mit besseren Prompts.

> "bei Chinesich Bazi erscheint nur Day Master - war im Konezpt nicht von allen vier die Rede, vlt sogar als Tabelle?"

⏳ **TODO:** Bazi Vier Säulen implementieren (großes Feature).

> "die Beschreibung steht auf lädt ... es passiert aber nichts"

🐛 **BUG:** Bazi Content lädt nicht → Debug erforderlich.

> "es sind nur 3 Zahlen (Lebensweg, Seelenwunsch, Ausdruck) aufgeführt - im Home Screen haben wir viel mehr, die müssen alle mit rein"

⏳ **IN PROGRESS:** Numerologie Section wird erweitert.

> "Gender-Tracking im Onboarding - dazu fällt mir ein, dass wir im Onboarding beim User gar nicht tracken ob männlich/weiblich/divers"

✅ **DONE:** Gender-Tracking komplett implementiert (DB + UI + Model).

## 📊 Statistik

- **Kompiliert:** ✅ Erfolgreich
- **Neue Dateien:** 3
  - `onboarding_gender_screen.dart`
  - `zodiac_names.dart`
  - `20260210_add_gender_to_profiles.sql`
- **Modifizierte Dateien:** 8
  - `user_profile.dart` (gender Feld)
  - `onboarding_flow_screen.dart` (3 Schritte)
  - `app_providers.dart` (contentLibraryServiceProvider)
  - `language_provider.dart` (currentLocaleProvider)
  - `western_astrology_section.dart` (Content Library + ZodiacNames)
  - `bazi_section.dart` (Content Library)
  - `numerology_section.dart` (Content Library)
  - `nuuray_core.dart` (zodiac_names export)

## 💰 Kosten

Keine API-Calls in dieser Session (nur UI + Model-Updates).
Content Library wurde in vorheriger Session generiert (~$0.24).
