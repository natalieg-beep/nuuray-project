# 🌟 Tageshoroskop-Strategie & Deployment

## 📋 Übersicht

NUURAY Glow nutzt ein **Hybrid-System** für Tageshoroskope:

- **Phase 1 (jetzt - 1000 User):** Pure On-Demand Generation
- **Phase 2 (ab 1000+ User):** Cron Job + On-Demand Fallback

---

## ✅ Phase 1: On-Demand (AKTIV)

### Funktionsweise

```
User öffnet App
  → DailyHoroscopeService.getBaseHoroscope()
  → Versuche Cache (daily_horoscopes Tabelle)
  → Falls Cache Miss: Generiere mit Claude API
  → Cache Ergebnis in DB
  → Return Horoskop
```

### Kosten

| User-Anzahl | Kosten/Monat | Notes |
|-------------|--------------|-------|
| 0 (Test) | $0 | Perfekt für Entwicklung! |
| 100 | ~$6-7 | ~10 Zeichen werden genutzt |
| 1,000 | ~$7-8 | Alle 12 Zeichen abgedeckt |

### Vorteile

- ✅ Minimale Kosten während Testphase
- ✅ Keine Edge Function nötig
- ✅ Einfach zu debuggen
- ✅ Automatisches Caching

### Nachteile

- ⚠️ Erster User pro Zeichen/Sprache wartet 2-3 Sekunden
- ⚠️ Bei Launch (viele User gleichzeitig) könnte Claude API Rate Limit erreicht werden

---

## 🚀 Phase 2: Cron Job (VORBEREITET, INAKTIV)

### Wann aktivieren?

**Aktiviere Cron Job wenn:**
- Du 1000+ User hast ODER
- Mehrere User berichten dass Horoskope "langsam laden" ODER
- Du Claude API Rate Limit Errors siehst (429)

### Funktionsweise

```
04:00 UTC täglich (Cron Job):
  → Suche alle aktiven User (profiles.sun_sign + preferred_language)
  → Extrahiere unique Kombinationen (z.B. "sagittarius:de", "aries:en")
  → Generiere nur diese Kombinationen
  → Prüfe vor jedem Call ob bereits vorhanden (Idempotenz)
  → Cache in daily_horoscopes Tabelle

User öffnet App:
  → DailyHoroscopeService.getBaseHoroscope()
  → Cache Hit → instant! ✅
  → Cache Miss (z.B. User wechselt Sprache) → On-Demand Generation
```

### Kosten

| User-Anzahl | Aktive Zeichen+Sprachen | Kosten/Monat |
|-------------|-------------------------|--------------|
| 100 | ~13 | ~$8 |
| 1,000 | ~18 | ~$11 |
| 10,000 | ~24 (alle) | ~$15 |

### Vorteile

- ✅ 99% der User: instant aus Cache
- ✅ Vorhersehbare Kosten
- ✅ Keine Rate Limit Probleme
- ✅ Perfekt für Launch-Days

---

## 🔧 Deployment: Cron Job aktivieren

### Voraussetzungen

- ✅ Edge Function Code existiert bereits (siehe unten)
- ✅ ANTHROPIC_API_KEY als Edge Functions Secret gesetzt
- ✅ pg_cron Extension aktiviert

### Schritt 1: Edge Function deployen

**Option A: Via Supabase Dashboard (empfohlen)**

1. Öffne: https://supabase.com/dashboard/project/ykkayjbplutdodummcte/functions
2. Klicke "Deploy a new function"
3. Name: `generate-daily-horoscopes`
4. Kopiere Code aus: `/supabase/functions/generate-daily-horoscopes/index.ts`
5. Deploy

**Option B: Via CLI (wenn installiert)**

```bash
cd /Users/natalieg/nuuray-project
supabase functions deploy generate-daily-horoscopes
```

### Schritt 2: Cron Job einrichten

**Via SQL Editor:**

https://supabase.com/dashboard/project/ykkayjbplutdodummcte/sql

```sql
-- Aktiviere pg_cron falls noch nicht aktiv
CREATE EXTENSION IF NOT EXISTS pg_cron WITH SCHEMA extensions;

-- Erstelle Cron Job (täglich 4:00 UTC)
SELECT cron.schedule(
  'daily-horoscopes-4am-utc',
  '0 4 * * *', -- Cron Expression: täglich 4:00 UTC
  $$
  SELECT
    net.http_post(
      url:='https://ykkayjbplutdodummcte.supabase.co/functions/v1/generate-daily-horoscopes',
      headers:='{"Content-Type": "application/json", "Authorization": "Bearer ' || current_setting('app.settings.service_role_key') || '"}'::jsonb,
      body:='{}'::jsonb
    ) as request_id;
  $$
);
```

### Schritt 3: Manuell testen

```bash
curl -X POST \
  'https://ykkayjbplutdodummcte.supabase.co/functions/v1/generate-daily-horoscopes' \
  -H "Authorization: Bearer YOUR_SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json"
```

**Service Role Key:** https://supabase.com/dashboard/project/ykkayjbplutdodummcte/settings/api

### Schritt 4: Verifizieren

**Check Logs:**
- Functions → generate-daily-horoscopes → Logs Tab
- Erwarte: "✅ Erfolgreich: X/X"

**Check Database:**

```sql
SELECT
  date,
  zodiac_sign,
  language,
  LEFT(content_text, 80) as preview,
  created_at
FROM daily_horoscopes
WHERE date = CURRENT_DATE
ORDER BY zodiac_sign, language;
```

---

## 🔍 Monitoring

### Logs anschauen

**Edge Function Logs:**
- https://supabase.com/dashboard/project/ykkayjbplutdodummcte/functions
- generate-daily-horoscopes → Logs Tab

**Cron Job Status:**

```sql
-- Zeige alle Cron Jobs
SELECT * FROM cron.job;

-- Zeige letzte Ausführungen
SELECT * FROM cron.job_run_details
ORDER BY start_time DESC
LIMIT 10;
```

### Kosten tracken

```sql
-- Tokens pro Tag
SELECT
  date,
  COUNT(*) as horoscopes,
  SUM(tokens_used) as total_tokens,
  ROUND((SUM(tokens_used) / 1000.0) * 0.015, 3) as estimated_cost_usd
FROM daily_horoscopes
WHERE date >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY date
ORDER BY date DESC;
```

---

## 🐛 Troubleshooting

### Problem: "WORKER_LIMIT" Error

**Ursache:** Zu viele Horoskope werden parallel generiert

**Lösung:** Reduziere `BATCH_SIZE` in Edge Function:

```typescript
const BATCH_SIZE = 3 // Statt 5
```

### Problem: "429 Rate Limit" von Claude API

**Ursache:** Zu viele Requests in kurzer Zeit

**Lösung 1:** Erhöhe Delay zwischen Batches:

```typescript
// Nach jedem Batch:
await new Promise(resolve => setTimeout(resolve, 2000)) // 2 Sek Pause
```

**Lösung 2:** Upgrade Claude API Tier bei Anthropic

### Problem: Cron Job läuft nicht

**Check 1:** Ist Job aktiv?

```sql
SELECT jobname, active, schedule
FROM cron.job
WHERE jobname = 'daily-horoscopes-4am-utc';
```

**Check 2:** Letzte Ausführung prüfen

```sql
SELECT * FROM cron.job_run_details
WHERE jobid = (SELECT jobid FROM cron.job WHERE jobname = 'daily-horoscopes-4am-utc')
ORDER BY start_time DESC
LIMIT 5;
```

---

## 📊 Vergleich: On-Demand vs. Cron

| Aspekt | On-Demand (Phase 1) | Cron (Phase 2) |
|--------|---------------------|----------------|
| **Kosten (100 User)** | $6-7/Monat | $8/Monat |
| **Kosten (1000 User)** | $7-8/Monat | $11/Monat |
| **Kosten (Testphase)** | $0 ✅ | $15 ❌ |
| **Performance** | Erster User wartet 2-3 Sek | Alle instant ✅ |
| **Launch-Sicherheit** | Risk bei 500+ gleichzeitig | Sicher ✅ |
| **Komplexität** | Einfach ✅ | Mittel |
| **Deployment** | Nichts nötig ✅ | Edge Function + Cron |

---

## 🎯 Empfehlung

**Jetzt:** Bleib bei On-Demand (Phase 1)
- Einfach, günstig, funktioniert perfekt für <1000 User
- Bereits implementiert und aktiv

**Später:** Aktiviere Cron (Phase 2) wenn:
- Du 1000+ User hast
- Performance-Probleme auftreten
- Launch bevorsteht (viele User gleichzeitig erwartet)

**Aufwand für Wechsel:** ~10 Minuten (Code ist schon fertig!)

---

## 🧹 Cleanup: Alte Cron Job Konfiguration entfernen

Falls du den Cron Job bereits in Supabase eingerichtet hast (aus früheren Sessions), lösche ihn:

**SQL Editor:** https://supabase.com/dashboard/project/ykkayjbplutdodummcte/sql

```sql
-- Cron Job deaktivieren
SELECT cron.unschedule('daily-horoscopes-4am-utc');

-- Prüfen ob weg
SELECT * FROM cron.job WHERE jobname LIKE '%horoscope%';
```

**Edge Function löschen** (falls deployed):
- Gehe zu: https://supabase.com/dashboard/project/ykkayjbplutdodummcte/functions
- Falls `generate-daily-horoscopes` existiert → **Delete**

**Edge Functions Secrets aufräumen** (optional):
- Gehe zu: Edge Functions → Secrets
- Falls `ANTHROPIC_API_KEY` dort ist → kann gelöscht werden (wird in Phase 1 nicht gebraucht)

---

**Letzte Aktualisierung:** 2026-02-08
**Status:** Phase 1 aktiv, Phase 2 vorbereitet
**Cleanup:** ✅ Supabase Cron Job gelöscht, Edge Function gelöscht
