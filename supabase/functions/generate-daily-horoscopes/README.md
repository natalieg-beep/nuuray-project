# 🌟 Edge Function: `generate-daily-horoscopes`

## 📋 Zweck

Täglicher Cron Job (4:00 UTC), der Tageshoroskope für alle 12 Sternzeichen in beiden Sprachen generiert und cached.

---

## ⚙️ Funktionsweise

1. **Generierung:** 12 Zeichen × 2 Sprachen = **24 Horoskope**
2. **API:** Claude Sonnet 4 (`claude-sonnet-4-20250514`)
3. **Cache:** `daily_horoscopes` Tabelle (Supabase)
4. **Cleanup:** Löscht Horoskope älter als 7 Tage

---

## 💰 Kosten

- **Pro Horoskop:** ~300 tokens = ~$0.02
- **Pro Tag:** 24 Horoskope = ~$0.50
- **Pro Monat:** ~$15

---

## 🚀 Deployment

### 1. Edge Function deployen

```bash
cd /Users/natalieg/nuuray-project

# Deploy
supabase functions deploy generate-daily-horoscopes

# Mit Environment Variables
supabase secrets set ANTHROPIC_API_KEY=sk-ant-api03-...
```

### 2. Manuell testen (ohne Cron)

```bash
# Via Supabase CLI
supabase functions invoke generate-daily-horoscopes

# Via curl
curl -X POST \
  'https://ykkayjbplutdodummcte.supabase.co/functions/v1/generate-daily-horoscopes' \
  -H 'Authorization: Bearer YOUR_ANON_KEY'
```

**Erwartete Ausgabe:**
```json
{
  "success": true,
  "date": "2026-02-09",
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

---

## ⏰ Cron Job einrichten

### Option A: Supabase Dashboard (empfohlen)

1. Öffne: https://supabase.com/dashboard/project/ykkayjbplutdodummcte/functions
2. Klicke auf `generate-daily-horoscopes`
3. Reiter: **Cron Jobs**
4. **Add Cron Job:**
   - Name: `daily-horoscopes-4am`
   - Schedule: `0 4 * * *` (täglich 4:00 UTC)
   - Target: `generate-daily-horoscopes`
5. Speichern

### Option B: Via `supabase/config.toml`

**Datei:** `/Users/natalieg/nuuray-project/supabase/config.toml`

```toml
[functions.generate-daily-horoscopes]
verify_jwt = false

[functions.generate-daily-horoscopes.cron]
# Täglich um 4:00 UTC
schedule = "0 4 * * *"
```

**Deployen:**
```bash
supabase functions deploy generate-daily-horoscopes
```

---

## 🧪 Testing

### 1. Manueller Test (jetzt sofort ausführen)

```bash
# CLI
supabase functions invoke generate-daily-horoscopes

# Oder via curl
curl -X POST \
  'https://ykkayjbplutdodummcte.supabase.co/functions/v1/generate-daily-horoscopes' \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
```

**Prüfen in DB:**
```sql
SELECT date, zodiac_sign, language,
       LEFT(content_text, 50) as preview,
       tokens_used
FROM daily_horoscopes
WHERE date = CURRENT_DATE
ORDER BY zodiac_sign, language;
```

**Erwartung:** 24 Zeilen (12 Zeichen × 2 Sprachen)

---

### 2. Cron Job Test (Zeitplan ändern)

**Temporär Zeitplan ändern für sofortigen Test:**

```toml
# Für Test: Alle 5 Minuten
schedule = "*/5 * * * *"
```

**Nach Test:** Zurück zu `0 4 * * *`

---

## 🔍 Monitoring

### Logs anschauen

```bash
# Live Logs
supabase functions logs generate-daily-horoscopes --follow

# Letzte 100 Zeilen
supabase functions logs generate-daily-horoscopes --limit 100
```

### Supabase Dashboard

1. Öffne: https://supabase.com/dashboard/project/ykkayjbplutdodummcte/functions
2. Klicke auf `generate-daily-horoscopes`
3. Reiter: **Logs**

---

## 🐛 Troubleshooting

### Problem: "ANTHROPIC_API_KEY not found"

**Lösung:**
```bash
supabase secrets set ANTHROPIC_API_KEY=sk-ant-api03-...
supabase functions deploy generate-daily-horoscopes
```

### Problem: "Permission denied" beim Schreiben in DB

**Lösung:** Edge Function nutzt `SUPABASE_SERVICE_ROLE_KEY` (automatisch verfügbar)

### Problem: Claude API Rate Limit

**Symptom:** Fehler nach einigen Requests

**Lösung:**
- Warte 60 Sekunden zwischen Batches
- Oder: Deployment in mehreren Batches (z.B. 12 Zeichen zuerst, dann 12 weitere)

### Problem: Cron Job läuft nicht

**Prüfen:**
1. Dashboard → Functions → Cron Jobs → Status?
2. Logs prüfen: `supabase functions logs`
3. Zeitzone korrekt? (UTC!)

---

## 📊 Erwartete Performance

- **Dauer:** ~2-5 Minuten (24 API Calls)
- **Tokens gesamt:** ~7200 (300 pro Horoskop)
- **Kosten:** ~$0.50 pro Run
- **Erfolgsrate:** >95% (bei stabiler API)

---

## 🔐 Sicherheit

- ✅ Edge Function nutzt Service Role Key (Admin-Zugriff)
- ✅ Claude API Key als Secret gespeichert
- ✅ Keine User-Auth nötig (Cron Job)
- ✅ RLS auf `daily_horoscopes` Tabelle (Read-Only für authenticated Users)

---

## 🚦 Status

- [x] Edge Function erstellt ✅
- [ ] Deployed ❌
- [ ] Manuell getestet ❌
- [ ] Cron Job konfiguriert ❌
- [ ] Produktiv (täglich 4:00 UTC) ❌

---

**Nächster Schritt:** Deployment + Manueller Test
