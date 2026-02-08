# 🛠️ NUURAY — Development Setup

**Letzte Aktualisierung:** 2026-02-08

Diese Anleitung beschreibt das lokale Setup für die Entwicklung von Nuuray (Glow, Tide, Path).

---

## 📋 Voraussetzungen

### 1. Flutter SDK

**Version:** >=3.5.0

```bash
flutter --version
# Flutter 3.5.0+ erforderlich
```

**Installation:** https://docs.flutter.dev/get-started/install

---

### 2. Supabase CLI

**Version:** 2.75.0+ (installiert am 2026-02-08)

#### Installation (macOS ARM64)

**Methode 1: Homebrew (empfohlen, wenn Xcode aktuell)**

```bash
brew install supabase/tap/supabase
```

**Methode 2: Manuell via Binary (funktioniert ohne Xcode)**

```bash
# Download & Install
cd /tmp
curl -fsSL https://github.com/supabase/cli/releases/latest/download/supabase_darwin_arm64.tar.gz -o supabase.tar.gz
tar -xzf supabase.tar.gz
mkdir -p ~/bin
mv supabase ~/bin/supabase
chmod +x ~/bin/supabase

# PATH konfigurieren (einmalig)
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Verifizieren
supabase --version
# → 2.75.0
```

#### Setup

```bash
# Projekt verknüpfen (einmalig)
supabase link --project-ref ykkayjbplutdodummcte

# Status prüfen
supabase status
```

#### Migrations deployen

**Option 1: Manuell via Supabase Dashboard** (aktuell genutzt)
1. Gehe zu: https://supabase.com/dashboard/project/ykkayjbplutdodummcte/sql
2. Öffne Migration-Datei: `supabase/migrations/XXX_name.sql`
3. SQL kopieren und im SQL Editor ausführen

**Option 2: Via CLI** (erfordert Docker für lokales Testing)
```bash
# Alle neuen Migrations pushen
supabase db push

# ACHTUNG: Bereits deployed Migrations werden übersprungen,
# aber die CLI versucht alle zu pushen. Aktuell empfohlen: Manuell deployen.
```

---

### 3. Google Cloud API Keys

Für Geburtsort-Geocoding (Google Places API):

**Setup:**
1. Google Cloud Console: https://console.cloud.google.com/
2. APIs aktiviert:
   - Places API (New)
   - Places API (Old)
   - Place Autocomplete
   - Place Details
   - Geocoding API
   - Time Zone API

**API Key:** Gespeichert in Supabase Secrets (`GOOGLE_PLACES_API_KEY`)

---

### 4. Anthropic API Key

Für Claude API (Content-Generierung):

**Setup:**
1. Anthropic Console: https://console.anthropic.com/
2. API Key erstellen
3. In `.env` Datei speichern (siehe unten)

---

## 🔧 Projekt-Setup

### 1. Repository klonen

```bash
git clone <repository-url>
cd nuuray-project
```

### 2. Dependencies installieren

```bash
# Root-Level (wenn Melos verwendet wird)
flutter pub get

# Oder für jede App einzeln:
cd apps/glow && flutter pub get
cd ../../packages/nuuray_core && flutter pub get
cd ../nuuray_api && flutter pub get
cd ../nuuray_ui && flutter pub get
```

### 3. Environment-Variablen

**Datei:** `apps/glow/.env` (nicht in Git!)

```env
# Supabase
SUPABASE_URL=https://ykkayjbplutdodummcte.supabase.co
SUPABASE_ANON_KEY=<supabase-anon-key>

# Anthropic (Claude API)
ANTHROPIC_API_KEY=<your-api-key>

# Google Places (optional, wird via Supabase Edge Function genutzt)
GOOGLE_PLACES_API_KEY=<optional-for-local-testing>
```

**Wo finde ich die Keys?**
- Supabase: Dashboard → Settings → API → `anon` public key
- Anthropic: https://console.anthropic.com/settings/keys

### 4. Lokalisierung generieren

```bash
cd packages/nuuray_ui
flutter gen-l10n
```

Generiert `AppLocalizations` Klassen aus `lib/src/l10n/app_de.arb` und `app_en.arb`.

---

## 🚀 App starten

### iOS Simulator

```bash
cd apps/glow
flutter run -d "iPhone 15 Pro"
```

### Android Emulator

```bash
cd apps/glow
flutter run -d emulator-5554
```

### Chrome (Web)

```bash
cd apps/glow
flutter run -d chrome
```

### macOS Desktop

```bash
cd apps/glow
flutter run -d macos
```

---

## 📊 Datenbank-Migrationen

### Neue Migration erstellen

```bash
cd supabase/migrations
touch "$(date +%Y%m%d)_beschreibung.sql"
```

**Format:** `YYYYMMDD_beschreibung.sql` (z.B. `20260208_add_signature_text.sql`)

**Template:**

```sql
-- Migration: Kurze Beschreibung
-- Erstellt: YYYY-MM-DD
-- Beschreibung: Detaillierte Erklärung was diese Migration macht

-- Beispiel: Neues Feld hinzufügen
ALTER TABLE profiles
ADD COLUMN new_field TEXT NULL;

COMMENT ON COLUMN profiles.new_field IS
'Beschreibung des Feldes und wofür es genutzt wird';
```

### Migration deployen

**Aktuell genutzt: Manuell via Supabase Dashboard**

1. Öffne SQL Editor: https://supabase.com/dashboard/project/ykkayjbplutdodummcte/sql
2. SQL aus Migration-Datei kopieren
3. Ausführen
4. Verifizieren im Table Editor

---

## 🧪 Testing

### Unit Tests (nuuray_core)

```bash
cd packages/nuuray_core
flutter test
```

### Widget Tests (Glow App)

```bash
cd apps/glow
flutter test
```

### Integration Tests

```bash
cd apps/glow
flutter test integration_test/
```

---

## 🔍 Troubleshooting

### "Command not found: supabase"

**Lösung:**
```bash
# PATH prüfen
echo $PATH | grep "$HOME/bin"

# Falls nicht vorhanden:
export PATH="$HOME/bin:$PATH"
source ~/.zshrc
```

### Flutter Gen-L10n Fehler: "Invalid ARB resource name"

**Problem:** ARB-Keys dürfen nicht mit `_` beginnen (z.B. `_comment`)

**Lösung:** Entferne Kommentar-Keys oder nutze `@key` Format

### Supabase Link schlägt fehl

**Lösung:**
```bash
# Projekt-Ref aus Supabase Dashboard holen
# Settings → General → Reference ID
supabase link --project-ref <your-project-ref>
```

### Docker Daemon not running

**Problem:** `supabase db diff` erfordert Docker für Shadow DB

**Lösung:**
- Docker Desktop starten, ODER
- Migrations manuell via Dashboard deployen (empfohlen)

---

## 📚 Weitere Dokumentation

- **Projekt-Architektur:** `docs/architecture/PROJECT_BRIEF.md`
- **Glow Spezifikation:** `docs/glow/GLOW_SPEC_V2.md`
- **Implementierungs-Guides:** `docs/glow/implementation/`
- **Daily Logs:** `docs/daily-logs/`
- **TODO Liste:** `TODO.md`

---

## 📦 Nützliche Commands

```bash
# Flutter
flutter doctor                    # System-Check
flutter clean                     # Build-Cache löschen
flutter pub upgrade               # Dependencies updaten
flutter analyze                   # Linter ausführen

# Supabase
supabase status                   # Projekt-Status
supabase db pull                  # Schema von Remote holen
supabase db diff                  # Migrations generieren (braucht Docker)
supabase functions deploy         # Edge Functions deployen

# Git
git status                        # Änderungen anzeigen
git log --oneline -10             # Letzte 10 Commits
git diff                          # Änderungen im Detail
```

---

**Entwickelt von:** Solo-Entwicklerin (Natalie)
**Letzte Aktualisierung:** 2026-02-08
**Projekt:** NUURAY (Glow, Tide, Path)
