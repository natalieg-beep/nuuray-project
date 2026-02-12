# 📝 Changelog — Projektbeschreibung Update

**Datum:** 2026-02-07
**Grund:** User-Feedback eingearbeitet, Projektbeschreibung strukturiert & erweitert

---

## ✅ Alle Änderungen im Überblick

### 1. Naming: "Cosmic Profile" → "Deine Signatur"

**Warum?**
- Persönlicher ("Deine" statt "Cosmic")
- Einprägsamer
- Weniger esoterisch/abschreckend
- Impliziert Einzigartigkeit

**Geändert in:**
- Screen-Namen
- Datenbank-Tabellen (`signature_profiles` statt `cosmic_profiles`)
- Edge Functions (`calculate-signature` statt `calculate-cosmic-profile`)
- Alle UI-Texte
- Navigation

---

### 2. Dashboard-Platzierung

**Alt:** Cosmic Profile war separater Screen oder collapsible am Ende des Home Screens

**Neu:** "Deine Signatur" Dashboard immer sichtbar OBEN auf Home Screen

**Format:**
```
🌟 DEINE SIGNATUR
Schütze ☀️ • Waage 🌙 • Löwe ⬆️
癸 Yin-Wasser • Lebensweg 8
[Mehr erfahren →]
```

**Vorteile:**
- Kern der App (darf nicht versteckt sein!)
- Täglicher Reminder ihrer Einzigartigkeit
- Schneller Zugriff auf vollständiges Profil
- Minimal genug um nicht zu stören

---

### 3. Onboarding: 3 Schritte (Name → Gender → Geburtsdaten)

**Alt:**
- Schritt 1: Name (4 Felder)
- Schritt 2: Geburtsdatum + -zeit
- Schritt 3: Geburtsort

**Neu (AKTUELL):**
- **Schritt 1: Name & Identität** (Rufname, Vornamen, Geburtsnamen, Nachname)
- **Schritt 2: Gender** (Female, Male, Diverse, Prefer not to say)
- **Schritt 3: Geburtsdaten** (Datum + Zeit + Ort kombiniert)

**Dauer:** ~2-3 Minuten

#### Name-Felder neu strukturiert:

**Alt:**
- `first_name` (Rufname)
- `full_first_names` (Vornamen lt. Urkunde)
- `last_name` (Nachname)
- `birth_name` (Geburtsname falls abweichend)

**Neu:**
- `display_name` (Rufname/Username) — **PFLICHT**
- `full_first_names` (Vornamen lt. Geburtsurkunde, z.B. "Natalie Frauke") — **OPTIONAL**
- `birth_name` (Geburtsname / Maiden Name, Nachname vor Heirat) — **OPTIONAL**
- `last_name` (Aktueller Nachname nach Heirat/Namensänderung) — **OPTIONAL**

**Numerologie-Logik (Dual-Energy System):**
- **Birth Energy (Urenergie):** `full_first_names` + `birth_name` → Expression/Soul Urge/Personality (Geburtsname!)
- **Current Energy (Aktuelle Energie):** `full_first_names` + `last_name` → Expression/Soul Urge/Personality (aktueller Name)

#### Geburtsdaten kombiniert:

**Alles auf einer Seite:**
- Geburtsdatum
- Geburtszeit (optional)
- Geburtsort (optional, mit Google Places)

**Hinweis bei Überspringen:** "⚠️ Ohne Geburtsort & -zeit kann dein Aszendent nicht berechnet werden."

---

### 4. Content erweitert: Jahresvorschau

**Neu hinzugefügt:**

| Content-Typ | Wann generiert? | Cache | Kosten |
|-------------|-----------------|-------|--------|
| **Jahresvorschau** | On-Demand beim Premium-Kauf | 365 Tage | ~$0.50 (Opus!) |

**Features:**
- ~2000 Wörter (8-10 Min. Lesezeit)
- Enthält: Transite, Luck Pillars (Bazi), persönliches Jahr (Numerologie)
- Wird NICHT für alle User am 1.1. generiert (zu teuer!)
- On-Demand beim Premium-Kauf, dann jährlich automatisch

**Datenbank:** `daily_content` Tabelle erweitert mit `cache_until` Feld

---

### 5. Sprachen: Deutsch + Englisch ab Tag 1

**Entwicklungsstrategie:**
- **Primärsprache:** Deutsch (Entwicklung)
- **Sekundärsprache:** Englisch (parallel entwickelt)

**Settings Integration:**
- Dropdown: 🇩🇪 Deutsch / 🇬🇧 English
- Speichert in `profiles.language`
- App-weite Reaktion (UI + Claude API)

**Claude API:**
- Sprach-Variable im Prompt: `Language: ${user.language}`
- Claude generiert direkt in gewünschter Sprache

**ARB-Dateien:**
- `app_de.arb` (Primär)
- `app_en.arb` (Parallel)

**Neue Sektion in Projektbeschreibung:** Kapitel 11 "Sprachen & Lokalisierung"

---

### 6. Bazi: Warum 10 Gods etc. NICHT verwendet werden

**User-Frage:** "Warum zu komplex?"

**Antwort hinzugefügt:**

| Feature | Warum nicht im MVP? |
|---------|---------------------|
| **10 Gods** | • 10 komplexe Archetypen<br>• User-Verwirrung ohne Kontext<br>• Claude-Prompts zu lang<br>→ **Später als Premium-Feature** |
| **Luck Pillars** | • Komplex zu berechnen<br>• Zu viel Info auf einmal<br>→ **Später als Jahresvorschau-Feature** |
| **Hidden Stems** | • Macht Element-Balance extrem komplex<br>• Braucht professionelle Beratung<br>→ **Evtl. nie, zu spezialisiert** |

**Für MVP reicht:** Day Master + Vier Säulen + Element-Balance ✅

---

## 📊 Statistik

**Geänderte Abschnitte:** 15+
**Neue Abschnitte:** 2 (Sprachen & Lokalisierung, erweiterte Bazi-Begründung)
**Umbenennungen:** 20+ (Cosmic Profile → Deine Signatur)
**Erweiterte Features:** 3 (Jahresvorschau, Sprachen, Namens-Energie)

---

## ✅ Alle User-Requests implementiert

1. ✅ "Deine Signatur" statt "Cosmic Profile"
2. ✅ Dashboard auf Home Screen (immer sichtbar)
3. ✅ Onboarding: 3 Schritte (Name → Gender → Geburtsdaten)
4. ✅ Name-Felder neu strukturiert (display_name, full_birth_name, current_last_name)
5. ✅ Aktueller Nachname fließt in Numerologie ein
6. ✅ Jahresvorschau hinzugefügt (Premium, On-Demand)
7. ✅ Sprachen: Deutsch (Entwicklung) + Englisch (parallel)
8. ✅ Begründung für Bazi-Komplexität erweitert

---

## 🚀 Nächste Schritte

**Sofort:**
1. ✅ Onboarding neu implementiert (3 Schritte: Name → Gender → Geburtsdaten)
2. "Deine Signatur" Dashboard auf Home Screen
3. Datenbank-Migration (Tabellen umbenennen, neue Felder)
4. Settings Screen mit Sprach-Auswahl
5. i18n ARB-Dateien (DE + EN)

**Dann:**
1. Claude API Integration (Prompt-Templates)
2. Jahresvorschau-Feature
3. Testing & Polish

---

**Status:** ✅ Projektbeschreibung komplett aktualisiert!
**Bereit für:** Implementierung 🚀
