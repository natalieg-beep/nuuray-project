# 📌 NUURAY — Quick Reference

**Schnellzugriff für häufige Entwicklungs-Tasks**

---

## 🚀 App starten

```bash
cd apps/glow
flutter run -d chrome          # Web
flutter run -d macos           # macOS Desktop
flutter run -d "iPhone 15 Pro" # iOS Simulator
```

---

## 🗄️ Datenbank

### Migration manuell deployen

1. Öffne: https://supabase.com/dashboard/project/ykkayjbplutdodummcte/sql
2. SQL aus `supabase/migrations/XXX.sql` kopieren
3. Im SQL Editor ausführen

### Tabellen anzeigen

https://supabase.com/dashboard/project/ykkayjbplutdodummcte/editor

---

## 🌍 Lokalisierung

### Texte hinzufügen

1. Bearbeite: `packages/nuuray_ui/lib/src/l10n/app_de.arb`
2. Bearbeite: `packages/nuuray_ui/lib/src/l10n/app_en.arb`
3. Regeneriere:
   ```bash
   cd packages/nuuray_ui
   flutter gen-l10n
   ```

### Im Code nutzen

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final l10n = AppLocalizations.of(context)!;
Text(l10n.homeGreetingMorning)  // "Guten Morgen" / "Good morning"
```

---

## 🔧 Häufige Commands

```bash
# Dependencies installieren
cd apps/glow && flutter pub get

# Build Cache löschen
flutter clean

# Linter ausführen
flutter analyze

# Tests ausführen
flutter test

# Supabase Status
~/bin/supabase status
```

---

## 🔑 Wichtige URLs

| Service | URL |
|---------|-----|
| **Supabase Dashboard** | https://supabase.com/dashboard/project/ykkayjbplutdodummcte |
| **SQL Editor** | https://supabase.com/dashboard/project/ykkayjbplutdodummcte/sql |
| **Table Editor** | https://supabase.com/dashboard/project/ykkayjbplutdodummcte/editor |
| **Anthropic Console** | https://console.anthropic.com/ |
| **Google Cloud Console** | https://console.cloud.google.com/ |

---

## 📂 Wichtige Dateien

| Datei | Zweck |
|-------|-------|
| `CLAUDE.md` | Projekt-Anweisung für Claude |
| `TODO.md` | Aktuelle Aufgaben |
| `docs/SETUP.md` | Development Setup (vollständig) |
| `docs/glow/GLOW_SPEC_V2.md` | Glow App Spezifikation |
| `docs/architecture/PROJECT_BRIEF.md` | Vollständige Architektur |
| `.env` | Environment-Variablen (NICHT in Git!) |

---

## 🧪 Test-Account

```
Email: natalie.guenes.tr@gmail.com
Passwort: test123
```

---

## 🐛 Troubleshooting

### "Command not found: supabase"

```bash
export PATH="$HOME/bin:$PATH"
source ~/.zshrc
```

### Flutter Gen-L10n Fehler

- ARB-Keys dürfen nicht mit `_` beginnen
- Kommentar-Keys entfernen

### Hot Reload funktioniert nicht

```bash
flutter clean
flutter pub get
flutter run
```

---

**Vollständige Dokumentation:** `docs/SETUP.md`
