# 🚀 Cron Job Setup — Step-by-Step Anleitung

## 📋 Was wir machen

1. Edge Function im Supabase Dashboard erstellen
2. Anthropic API Key als Secret hinzufügen
3. Cron Job konfigurieren (täglich 4:00 UTC)
4. Testen!

**Geschätzte Dauer:** 10-15 Minuten

---

## ✅ Schritt 1: Edge Function erstellen

### 1.1 Öffne Supabase Dashboard
👉 https://supabase.com/dashboard/project/ykkayjbplutdodummcte/functions

### 1.2 Klicke "Create a new function"

### 1.3 Einstellungen:
- **Name:** `generate-daily-horoscopes`
- **Region:** EU Central (oder was du bevorzugst)

### 1.4 Code einfügen:
**Kopiere den GESAMTEN Code** aus:
`/Users/natalieg/nuuray-project/supabase/functions/generate-daily-horoscopes/index.ts`

**Oder öffne die Datei und kopiere alles (Zeile 1-313)**

### 1.5 Klicke "Deploy"

✅ **Ergebnis:** Function erscheint in der Liste!

---

## 🔐 Schritt 2: API Key als Secret hinzufügen

### 2.1 Öffne Secrets
👉 https://supabase.com/dashboard/project/ykkayjbplutdodummcte/settings/vault/secrets

### 2.2 Klicke "New secret"

### 2.3 Einstellungen:
- **Name:** `ANTHROPIC_API_KEY`
- **Value:** `sk-ant-api03-zoYFG...` (dein kompletter API Key aus `.env`)

**⚠️ WICHTIG:** Der Key muss mit `sk-ant-api03-` beginnen!

### 2.4 Klicke "Add secret"

✅ **Ergebnis:** Secret erscheint in der Liste (Wert ist verschleiert)

---

## ⏰ Schritt 3: Cron Job konfigurieren

### 3.1 Gehe zurück zu Functions
👉 https://supabase.com/dashboard/project/ykkayjbplutdodummcte/functions

### 3.2 Klicke auf `generate-daily-horoscopes`

### 3.3 Reiter: "Cron Jobs"

### 3.4 Klicke "Add Cron Job"

### 3.5 Einstellungen:
- **Name:** `daily-horoscopes-4am-utc`
- **Schedule (Cron Expression):** `0 4 * * *`
- **Target Function:** `generate-daily-horoscopes`
- **HTTP Method:** POST

**Erklärung Cron-Syntax:**
```
0 4 * * *
│ │ │ │ │
│ │ │ │ └─ Tag der Woche (0-6, 0 = Sonntag) - * = jeden Tag
│ │ │ └─── Monat (1-12) - * = jeden Monat
│ │ └───── Tag des Monats (1-31) - * = jeden Tag
│ └─────── Stunde (0-23) - 4 = 4:00 UTC
└───────── Minute (0-59) - 0 = :00

→ "Jeden Tag um 4:00 UTC"
```

**Zeitumrechnung:**
- **4:00 UTC** = 5:00 MEZ (Winter) = 6:00 MESZ (Sommer)

### 3.6 Klicke "Save"

✅ **Ergebnis:** Cron Job erscheint in der Liste mit Status "Active"!

---

## 🧪 Schritt 4: Manuell testen (SOFORT ausführen)

**Bevor wir auf morgen früh warten, testen wir jetzt gleich!**

### 4.1 In Supabase Functions

1. Öffne: https://supabase.com/dashboard/project/ykkayjbplutdodummcte/functions
2. Klicke auf `generate-daily-horoscopes`
3. Reiter: **"Invoke"**
4. Klicke: **"Invoke function"** (ohne Body)
5. Warte ~2-5 Minuten (24 Claude API Calls dauern etwas)

### 4.2 Erwartete Response:
```json
{
  "success": true,
  "date": "2026-02-08",
  "generated": 24,
  "errors": 0,
  "totalTokens": 7200,
  "estimatedCost": "$0.108",
  "results": [
    {
      "zodiacSign": "aries",
      "language": "de",
      "text": "Heute...",
      "tokens": 300,
      "success": true
    },
    ...
  ]
}
```

**Falls Fehler:** Prüfe Logs (Reiter "Logs")

---

## ✅ Schritt 5: Verifizieren in DB

### 5.1 Öffne SQL Editor
👉 https://supabase.com/dashboard/project/ykkayjbplutdodummcte/sql

### 5.2 Führe aus:
```sql
SELECT
  date,
  zodiac_sign,
  language,
  LEFT(content_text, 80) as preview,
  tokens_used,
  created_at
FROM daily_horoscopes
WHERE date = CURRENT_DATE
ORDER BY zodiac_sign, language;
```

### 5.3 Erwartung:
- **24 Zeilen** (12 Zeichen × 2 Sprachen)
- `date` = heute
- `content_text` = vollständiger Horoskop-Text
- `tokens_used` = ~250-350 pro Zeile

✅ **Wenn du 24 Zeilen siehst → ERFOLG!** 🎉

---

## 📱 Schritt 6: In der App testen

### 6.1 App neu starten
```bash
flutter run
# oder Hot Restart: R
```

### 6.2 Login mit Test-User
- Email: `natalie.guenes.tr@gmail.com`
- Passwort: `test123`

### 6.3 Home Screen öffnen

### 6.4 Tageshoroskop prüfen:
- **Sternzeichen:** Schütze (Sagittarius)
- **Erwartet:** Vollständiger Text aus DB (nicht mehr "Heute ist ein guter Tag..." Fallback)
- **Länge:** ~80-120 Wörter (aktuell) oder ~150-200 (wenn du geändert hast)

✅ **Wenn du ein echtes Horoskop siehst → LÄUFT!** 🚀

---

## 🔍 Monitoring

### Logs anschauen (falls Probleme)

1. Öffne: https://supabase.com/dashboard/project/ykkayjbplutdodummcte/functions
2. Klicke auf `generate-daily-horoscopes`
3. Reiter: **"Logs"**
4. Hier siehst du alle Ausführungen + Fehler

**Was du sehen solltest:**
```
🌟 Starting daily horoscope generation...
📝 Generiere: aries (de)
✅ Erfolg! (305 tokens)
📝 Generiere: aries (en)
✅ Erfolg! (298 tokens)
...
📊 ZUSAMMENFASSUNG:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Erfolgreich: 24/24
❌ Fehler: 0/24
🪙  Tokens gesamt: 7234
💰 Geschätzte Kosten: ~$0.109
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 🐛 Troubleshooting

### Problem 1: "ANTHROPIC_API_KEY not found"
**Lösung:** Secret wurde nicht richtig gesetzt
→ Gehe zu Vault/Secrets und prüfe ob `ANTHROPIC_API_KEY` existiert

### Problem 2: "Claude API Error (401)"
**Lösung:** API Key ist ungültig
→ Prüfe ob Key korrekt kopiert wurde (kein Leerzeichen am Ende!)

### Problem 3: Function timeout
**Lösung:** 24 API Calls dauern lange (2-5 Min ist normal)
→ Erhöhe Timeout in Function Settings auf 300 Sekunden (5 Min)

### Problem 4: Cron Job läuft nicht
**Lösung:**
1. Prüfe Dashboard → Functions → Cron Jobs → Status "Active"?
2. Prüfe Zeitzone (4:00 UTC = 5:00 MEZ)
3. Warte bis zur nächsten Ausführung (morgen 4:00 UTC)

---

## 📊 Kosten-Übersicht

- **Pro Run:** ~$0.50 (24 Horoskope)
- **Pro Tag:** ~$0.50 (1x täglich)
- **Pro Monat:** ~$15 (30 Tage)
- **Pro Jahr:** ~$180

**Vergleich:**
- **OHNE Cron Job:** $0.02 × jeder User × täglich = viel teurer bei vielen Usern!
- **MIT Cron Job:** $0.50 täglich = fix, egal wie viele User

→ Ab ~25 täglichen Usern spart Cron Job Geld! 💰

---

## ✅ Checkliste

- [ ] Edge Function erstellt im Dashboard
- [ ] Code eingefügt (alle 313 Zeilen)
- [ ] ANTHROPIC_API_KEY Secret hinzugefügt
- [ ] Cron Job konfiguriert (`0 4 * * *`)
- [ ] Manuell getestet (Invoke)
- [ ] DB verifiziert (24 Zeilen vorhanden)
- [ ] App getestet (echtes Horoskop sichtbar)
- [ ] Logs geprüft (keine Errors)

---

## 🎉 Geschafft!

**Ab morgen 4:00 UTC:**
- Cron Job läuft automatisch
- 24 neue Horoskope werden generiert
- Alle User bekommen frische Horoskope
- Kosten: ~$0.50/Tag

**Du kannst jetzt:**
- ☕ Kaffee trinken
- 😴 Schlafen
- 🎉 Feiern

Die App arbeitet automatisch! 🚀

---

**Nächste Optimierungen (später):**
- [ ] Text-Länge erhöhen (150-200 Wörter)
- [ ] Mondphasen-Berechnung integrieren
- [ ] Premium-Features aktivieren (Mini-Personalisierung)
- [ ] Monitoring/Alerting (wenn Cron Job fehlschlägt)

---

**Letzte Aktualisierung:** 2026-02-08
**Erstellt von:** Claude + Natalie
