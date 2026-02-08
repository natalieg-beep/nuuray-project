# Session-Log: Supabase CLI Installation

**Datum:** 2026-02-08
**Zeit:** Nachmittag
**Dauer:** ~30 Min

---

## 🎯 Ziel

Supabase CLI installieren für einfacheres Deployment von Migrations.

---

## ✅ Was wurde gemacht

### 1. Installation via Homebrew (gescheitert)

**Problem:** Xcode Version zu alt (16.2 vs. erforderlich 26.0)

```bash
brew install supabase/tap/supabase
# → Error: Your Xcode (16.2) at /Applications/Xcode.app is too outdated.
```

### 2. NPM Installation (nicht unterstützt)

```bash
npm install -g supabase
# → Installing Supabase CLI as a global module is not supported.
```

### 3. Manuelle Binary-Installation (erfolgreich!) ✅

```bash
# Download
cd /tmp
curl -fsSL https://github.com/supabase/cli/releases/latest/download/supabase_darwin_arm64.tar.gz -o supabase.tar.gz

# Extract
tar -xzf supabase.tar.gz

# Install zu ~/bin
mkdir -p ~/bin
mv supabase ~/bin/supabase
chmod +x ~/bin/supabase

# PATH konfigurieren
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Verifizieren
supabase --version
# → 2.75.0 ✅
```

### 4. Projekt verknüpfen

```bash
supabase link --project-ref ykkayjbplutdodummcte
# → Finished supabase link. ✅
```

### 5. Migration 005 deployen

**Manuell via Supabase Dashboard** (weil `db push` Docker erfordert):
- SQL aus `005_add_signature_text.sql` kopiert
- Im SQL Editor ausgeführt
- Verifiziert: `signature_text` Spalte existiert in `profiles` ✅

---

## 📚 Dokumentation erstellt

1. **`docs/SETUP.md`** — Vollständiger Development Setup Guide
   - Flutter, Supabase CLI, API Keys, Migrations
   - Troubleshooting-Section
   - ~200 Zeilen detaillierte Anleitung

2. **`docs/QUICK_REFERENCE.md`** — Schnellzugriff für häufige Commands
   - App starten
   - Datenbank-Zugriff
   - Lokalisierung
   - Wichtige URLs

3. **`docs/README.md`** aktualisiert
   - Neue Dateien hinzugefügt
   - Schnellzugriff-Tabelle erweitert

4. **`TODO.md`** aktualisiert
   - Supabase CLI Installation dokumentiert
   - Migration 005 Status hinzugefügt

---

## 🔧 Technische Details

**Installation:**
- Version: 2.75.0
- Pfad: `~/bin/supabase`
- PATH: In `~/.zshrc` konfiguriert
- Projekt-Ref: `ykkayjbplutdodummcte`

**Commands verfügbar:**
```bash
~/bin/supabase --version      # ✅ 2.75.0
~/bin/supabase status         # ✅ Funktioniert
~/bin/supabase link           # ✅ Funktioniert
~/bin/supabase db push        # ⚠️ Braucht Docker
```

**Migrations-Workflow:**
- **Aktuell:** Manuell via Supabase Dashboard SQL Editor
- **Zukünftig:** Mit `db push` wenn Docker läuft
- **Empfehlung:** Manuell ist OK für solo-dev

---

## 🎓 Learnings

1. **Homebrew + Xcode:** Xcode-Version-Check blockiert Installation
   - Workaround: Manuelle Binary-Installation

2. **NPM nicht unterstützt:** Supabase CLI will nicht global via npm installiert werden
   - Alternative: Binary oder Homebrew

3. **Docker für `db push`:** Shadow Database für Diff-Generation
   - Für Production: Migrations manuell deployen ist sicherer
   - Für Development: Docker optional

4. **PATH-Konfiguration:** `~/bin` ist guter Ort für Custom Binaries
   - Kein sudo nötig
   - In `~/.zshrc` persistent

5. **Dokumentation wichtig:** Setup-Schritte dokumentieren spart Zeit bei:
   - Onboarding neuer Devs
   - Nach Rechner-Wechsel
   - Für späteres Ich

---

## ✅ Ergebnis

- ✅ Supabase CLI funktioniert
- ✅ Projekt gelinkt
- ✅ Migration 005 deployed
- ✅ Dokumentation komplett
- ✅ Für zukünftige Sessions bereit

---

## 📋 Nächste Schritte

**Weiter mit Archetyp-System Phase 2:**
- Prompt-Template für Claude API
- Service-Methode für Signatur-Generierung
- Integration in Onboarding

---

**Entwickelt von:** Natalie
**Status:** ✅ Komplett
**Nächste Session:** Phase 2 — API & Service-Logik
