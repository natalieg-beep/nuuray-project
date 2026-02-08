# i18n Implementation — Nuuray Glow

**Status:** ✅ Komplett implementiert (DE + EN)
**Datum:** 2026-02-08

---

## 📋 Übersicht

### Aktuell implementiert:
- 🇩🇪 **Deutsch** (Primärsprache)
- 🇬🇧 **Englisch** (Sekundärsprache)

### Gesamt: **230+ Strings** in ARB-Dateien

---

## 🏗️ Architektur

### Dateistruktur:
```
packages/nuuray_ui/
├── l10n.yaml                    # ARB-Generator Konfiguration
├── lib/
│   ├── nuuray_ui.dart          # Main Export
│   └── src/
│       ├── l10n.dart           # Localization Re-Export
│       ├── l10n/
│       │   ├── app_de.arb      # 🇩🇪 Deutsch (Template)
│       │   └── app_en.arb      # 🇬🇧 Englisch
│       └── generated/l10n/      # Auto-generiert (flutter gen-l10n)
│           ├── app_localizations.dart
│           ├── app_localizations_de.dart
│           └── app_localizations_en.dart
```

### Komponenten:

1. **ARB-Dateien** (`packages/nuuray_ui/lib/src/l10n/`)
   - `app_de.arb` — Template (Primärsprache)
   - `app_en.arb` — Englische Übersetzungen

2. **l10n.yaml** (`packages/nuuray_ui/l10n.yaml`)
   - Konfiguration für `flutter gen-l10n`

3. **LanguageProvider** (`apps/glow/lib/src/core/providers/language_provider.dart`)
   - Riverpod StateNotifier für Sprachwechsel
   - Liest/Speichert Sprache aus/in User-Profil

4. **Settings Screen** (`apps/glow/lib/src/features/settings/screens/settings_screen.dart`)
   - UI für Sprachwechsel (🇩🇪 / 🇬🇧)

5. **MaterialApp Integration** (`apps/glow/lib/main.dart`)
   - `AppLocalizations.delegate`
   - Dynamisches `locale` via `languageProvider`

---

## 🌍 Weitere Sprachen hinzufügen

### Beispiel: Spanisch 🇪🇸, Französisch 🇫🇷, Türkisch 🇹🇷

#### Schritt 1: ARB-Dateien erstellen

Erstelle neue ARB-Dateien für jede Sprache:

```bash
# Im Ordner: packages/nuuray_ui/lib/src/l10n/
cp app_de.arb app_es.arb  # Spanisch
cp app_de.arb app_fr.arb  # Französisch
cp app_de.arb app_tr.arb  # Türkisch
```

#### Schritt 2: Strings übersetzen

**app_es.arb** (Spanisch):
```json
{
  "@@locale": "es",
  "@@last_modified": "2026-02-08",

  "appName": "Nuuray Glow",
  "homeGreetingMorning": "Buenos días",
  "homeGreetingAfternoon": "Buenas tardes",
  "homeGreetingEvening": "Buenas noches",
  "authSignIn": "Iniciar sesión",
  "authRegisterButton": "Registrarse",
  ...
}
```

**app_fr.arb** (Französisch):
```json
{
  "@@locale": "fr",
  "@@last_modified": "2026-02-08",

  "appName": "Nuuray Glow",
  "homeGreetingMorning": "Bonjour",
  "homeGreetingAfternoon": "Bon après-midi",
  "homeGreetingEvening": "Bonsoir",
  "authSignIn": "Se connecter",
  "authRegisterButton": "S'inscrire",
  ...
}
```

**app_tr.arb** (Türkisch):
```json
{
  "@@locale": "tr",
  "@@last_modified": "2026-02-08",

  "appName": "Nuuray Glow",
  "homeGreetingMorning": "Günaydın",
  "homeGreetingAfternoon": "İyi günler",
  "homeGreetingEvening": "İyi akşamlar",
  "authSignIn": "Giriş yap",
  "authRegisterButton": "Kayıt ol",
  ...
}
```

#### Schritt 3: Localizations neu generieren

```bash
cd packages/nuuray_ui
flutter gen-l10n
```

Dies generiert automatisch:
- `app_localizations_es.dart`
- `app_localizations_fr.dart`
- `app_localizations_tr.dart`

#### Schritt 4: LanguageProvider erweitern

**Datei:** `apps/glow/lib/src/core/providers/language_provider.dart`

```dart
/// Verfügbare Sprachen
static const List<Locale> supportedLocales = [
  Locale('de'),
  Locale('en'),
  Locale('es'),  // 🇪🇸 NEU
  Locale('fr'),  // 🇫🇷 NEU
  Locale('tr'),  // 🇹🇷 NEU
];

/// Sprach-Name für UI-Anzeige
String getLanguageName(Locale locale) {
  switch (locale.languageCode) {
    case 'de':
      return 'Deutsch';
    case 'en':
      return 'English';
    case 'es':
      return 'Español';     // 🇪🇸 NEU
    case 'fr':
      return 'Français';    // 🇫🇷 NEU
    case 'tr':
      return 'Türkçe';      // 🇹🇷 NEU
    default:
      return locale.languageCode.toUpperCase();
  }
}

/// Sprach-Flag Emoji für UI-Anzeige
String getLanguageFlag(Locale locale) {
  switch (locale.languageCode) {
    case 'de':
      return '🇩🇪';
    case 'en':
      return '🇬🇧';
    case 'es':
      return '🇪🇸';  // 🇪🇸 NEU
    case 'fr':
      return '🇫🇷';  // 🇫🇷 NEU
    case 'tr':
      return '🇹🇷';  // 🇹🇷 NEU
    default:
      return '🌍';
  }
}
```

#### Schritt 5: Datenbank-Constraint erweitern

**Datei:** `supabase/migrations/00X_add_languages.sql`

```sql
-- Erweitere CHECK-Constraint für neue Sprachen
ALTER TABLE public.profiles
  DROP CONSTRAINT IF EXISTS profiles_language_check;

ALTER TABLE public.profiles
  ADD CONSTRAINT profiles_language_check
    CHECK (language IN ('de', 'en', 'es', 'fr', 'tr'));
```

#### Schritt 6: Fertig! 🎉

Die neue Sprache ist jetzt:
- ✅ Im Settings Screen auswählbar
- ✅ App-weit aktiv beim Wechsel
- ✅ In der Datenbank gespeichert

---

## 🔧 Verwendung in Widgets

```dart
import 'package:nuuray_ui/nuuray_ui.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Localization-Objekt holen
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Statt hardcoded Strings:
        // Text('Guten Morgen'),

        // Jetzt mit i18n:
        Text(l10n.homeGreetingMorning),  // 🇩🇪 "Guten Morgen" | 🇬🇧 "Good morning"
        Text(l10n.authSignIn),           // 🇩🇪 "Anmelden" | 🇬🇧 "Sign In"
      ],
    );
  }
}
```

### Mit Parametern:

**ARB:**
```json
{
  "numerologyPersonalYear": "Jahr {year}",
  "@numerologyPersonalYear": {
    "placeholders": {
      "year": {"type": "String"}
    }
  }
}
```

**Dart:**
```dart
Text(l10n.numerologyPersonalYear('2026'))  // "Jahr 2026"
```

---

## 📊 String-Kategorien

| Kategorie | Anzahl Strings | ARB-Prefix |
|-----------|----------------|------------|
| Common (Buttons, etc.) | 13 | `common*` |
| Home Screen | 18 | `home*` |
| Daily Horoscope | 21 | `horoscope*` |
| Zodiac Signs | 12 | `zodiac*` |
| Auth (Login/Signup) | 39 | `auth*` |
| Onboarding | 35 | `onboarding*` |
| Signature Dashboard | 15 | `signature*` |
| Western Astrology | 8 | `astrologyPlanet*` |
| Bazi | 20 | `bazi*`, `signatureBazi*` |
| Numerology | 65 | `numerology*` |
| Settings | 8 | `settings*` |
| Premium | 10 | `premium*` |
| **GESAMT** | **230+** | |

---

## 🚀 Nächste Schritte

### Aktuell noch zu tun:
1. **Hardcoded Strings migrieren**
   - Home Screen → `l10n.homeXyz`
   - Auth Screens → `l10n.authXyz`
   - Onboarding → `l10n.onboardingXyz`
   - Signature Cards → `l10n.signatureXyz`

2. **UserProfileService erweitern**
   - `updateLanguage(String languageCode)` Methode
   - Speichert Sprachwahl in DB

3. **Claude API Integration**
   - Sprache aus User-Profil lesen
   - Content in gewählter Sprache generieren

### Später (optional):
- 🇪🇸 Spanisch hinzufügen
- 🇫🇷 Französisch hinzufügen
- 🇹🇷 Türkisch hinzufügen
- 🇮🇹 Italienisch hinzufügen
- 🇵🇹 Portugiesisch hinzufügen

---

## 🎯 Best Practices

### DO:
- ✅ Alle UI-Strings in ARB-Dateien
- ✅ Konsistente Naming-Konvention (`category*`)
- ✅ Placeholder für dynamische Werte
- ✅ `@@locale` in jeder ARB-Datei
- ✅ `@@last_modified` aktuell halten

### DON'T:
- ❌ Hardcoded Strings in Widgets
- ❌ Strings in Code duplicieren
- ❌ Inkonsistente Keys zwischen Sprachen
- ❌ Vergessen, `flutter gen-l10n` zu laufen

---

**Stand:** 2026-02-08
**Maintainer:** Solo-Entwicklung (Natalie)
