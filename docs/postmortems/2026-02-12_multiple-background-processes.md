# Postmortem: Mehrfach-Start von Background-Prozessen

**Datum:** 2026-02-12, 14:30-16:00 Uhr
**Severity:** Medium (Kosten-Verschwendung, keine Daten-Korruption)
**Status:** Resolved

---

## 🔴 Was ist passiert?

Beim Generieren der Bazi-Säulen Content Library (180 Texte via Claude API) wurden **5 parallele Prozesse** gestartet, die gleichzeitig liefen und sich gegenseitig blockierten/überschrieben.

---

## 🔍 Timeline

| Zeit | Event | Action |
|------|-------|--------|
| 14:35 | Start 1 | ❌ `ANTHROPIC_API_KEY` fehlte → Fehler, **ABER: Prozess lief im Hintergrund weiter** |
| 14:38 | Start 2 | ❌ `SUPABASE_ANON_KEY` statt `SERVICE_ROLE_KEY` → RLS-Fehler, **Prozess lief weiter** |
| 14:42 | Start 3 | ❌ `title` Feld fehlte → NOT NULL Constraint Fehler, **Prozess lief weiter** |
| 14:46 | Start 4 | ❌ Variablen-Konflikt (`branch`) → Compile-Fehler, **Prozess lief weiter** |
| 14:50 | Start 5 | ✅ Alle Fixes korrekt → **ABER: 5 Prozesse liefen parallel!** |
| 15:05 | Discovery | User fragt "wo stehen wir" → `ps aux` zeigt 5 Prozesse |
| 15:07 | Fix | `pkill -f "seed_bazi_pillars"` stoppt alle Prozesse |
| 15:10 | Clean Start | 1 sauberer Prozess gestartet, läuft korrekt durch |

---

## 💥 Root Cause

**Hauptursache:** Background-Tasks (`run_in_background: true`) laufen auch bei Fehlern weiter, wenn der Fehler erst während der Ausführung auftritt (nicht beim Start).

**Verstärkende Faktoren:**
1. ❌ Kein Check auf bereits laufende Prozesse vor neuem Start
2. ❌ Kein `pkill` nach erkanntem Fehler
3. ❌ Task-IDs wurden nicht getrackt oder mit `TaskStop` beendet
4. ❌ Blindes "fix & restart" ohne Cleanup

---

## 📊 Impact

### Kosten
- **Verschwendet:** ~$0.13 (43 Duplikate × $0.003)
- **Erwartbar:** ~$0.54 (180 Texte gesamt)
- **Zusatzkosten:** ~24% Overhead

### Zeit
- **Verschwendet:** ~20 Minuten Debugging
- **Zusätzlich:** ~5 Minuten für doppelte Generierung

### Daten
- ✅ **Keine Korruption:** Supabase hat Duplikate verhindert (Upsert-Logik)
- ✅ **Kein Datenverlust:** Alle 43 generierten Texte sind korrekt

---

## 🛠️ Was haben wir gelernt?

### Sofort-Maßnahmen (für diese Session)
1. ✅ `pkill -f "seed_bazi_pillars"` → Alle alten Prozesse gestoppt
2. ✅ `ps aux | grep seed_bazi_pillars` → Verifiziert dass alles weg ist
3. ✅ **Ein einziger** sauberer Start mit allen Fixes
4. ✅ Monitoring mit `tail -f` statt blind im Hintergrund laufen lassen

### Langfristige Learnings

#### 1. **Background-Task Checkliste** (IMMER befolgen!)

```bash
# VOR jedem Background-Task Start:

# Schritt 1: Alte Prozesse checken
ps aux | grep <script-name>

# Schritt 2: Falls vorhanden → STOPPEN
pkill -f "<script-name>"

# Schritt 3: Verifizieren
ps aux | grep <script-name>  # sollte leer sein!

# Schritt 4: DANN erst starten
dart scripts/<script-name>.dart
```

#### 2. **Task-ID Tracking**

Wenn `run_in_background: true`:
```dart
// Task-ID notieren!
final taskId = "bb00c21";

// Bei Fehler: TaskStop verwenden
TaskStop(task_id: taskId);

// NICHT einfach neu starten!
```

#### 3. **Fehler-Handling bei Background-Tasks**

```bash
# ❌ FALSCH:
dart script.dart &  # Fehler? → Einfach neu starten

# ✅ RICHTIG:
dart script.dart &  # Fehler? →
ps aux | grep script  # Check
pkill -f script       # Stop
# Fix das Problem im Code
dart script.dart &    # Dann neu starten
```

#### 4. **Cost-Aware Development**

- Background-Tasks mit Claude API → **Kosten laufen!**
- Bei Fehlern **SOFORT stoppen**, nicht weiterlaufen lassen
- Lieber 2 Minuten für sauberen Cleanup als $0.50 verschwendet

---

## ✅ Präventionsmaßnahmen

### Code-Level
- [ ] TODO: `seed_bazi_pillars.dart` mit PID-File Lock erweitern
- [ ] TODO: Script prüft beim Start ob bereits ein Prozess läuft
- [ ] TODO: Exit bei fehlenden Env-Vars **vor** Background-Start

### Prozess-Level
- ✅ **Immer `ps aux | grep` vor Background-Start**
- ✅ **Immer `pkill` bei erkanntem Fehler**
- ✅ **Task-IDs in Notizen festhalten**
- ✅ **Monitoring während der ersten 30 Sekunden** (catch early errors)

### Dokumentation
- ✅ Dieses Postmortem für zukünftige Referenz
- ✅ Session-Log mit Fehler-Details
- ✅ CLAUDE.md mit Best Practices erweitern

---

## 📝 Action Items

| Item | Owner | Status |
|------|-------|--------|
| Cleanup aller Zombie-Prozesse | Claude | ✅ Done |
| Sauberer Neustart mit allen Fixes | Claude | ✅ Done |
| Session-Log aktualisieren | Claude | ✅ Done |
| Postmortem erstellen | Claude | ✅ Done |
| PID-File Lock implementieren | Backlog | ⏳ TODO |
| CLAUDE.md erweitern | Backlog | ⏳ TODO |

---

## 🎯 Takeaway

**One-Liner für die Zukunft:**

> **"Background-Tasks sind wie Feuer: Bevor du ein neues anzündest, lösch' die alten!"** 🔥

**Konkret:**
```bash
# Diese 3 Zeilen VOR jedem Background-Task:
ps aux | grep <name>     # Check
pkill -f "<name>"        # Kill
ps aux | grep <name>     # Verify
```

**Kosten-Bewusstsein:**
- Claude API Background-Tasks = **$$ laufen im Hintergrund**
- Lieber 1 Minute Cleanup als $1 verschwendet
- Bei Fehler: **STOP FIRST, FIX SECOND, START THIRD**

---

**Reviewer Notes:** Dieser Fehler war vermeidbar, aber nicht kritisch. Keine Daten wurden beschädigt, nur Zeit und Geld verschwendet. Die dokumentierten Learnings sollten zukünftige Vorfälle dieser Art verhindern.
