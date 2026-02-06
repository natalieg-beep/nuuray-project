# Supabase Edge Functions — Deployment Guide

## Voraussetzungen

1. **Supabase CLI installieren:**
   ```bash
   brew install supabase/tap/supabase
   ```

2. **Login:**
   ```bash
   supabase login
   ```

3. **Mit Projekt verbinden:**
   ```bash
   supabase link --project-ref ykkayjbplutdodummcte
   ```

## Environment Variables setzen

Die Edge Functions benötigen folgende Secrets:

```bash
# Google Places API Key
supabase secrets set GOOGLE_PLACES_API_KEY=AIzaSyBG207MVH8bkIjk_zNAKplAaB1H45HjndM

# Anthropic API Key (für daily-content Function)
supabase secrets set ANTHROPIC_API_KEY=sk-ant-...

# Secrets anzeigen
supabase secrets list
```

## Functions deployen

### Alle Functions deployen:
```bash
supabase functions deploy
```

### Einzelne Function deployen:
```bash
# Geocoding Function
supabase functions deploy geocode-place

# Daily Content Function
supabase functions deploy generate-daily-content
```

## Functions testen

### Lokal testen (mit Supabase CLI):
```bash
# Function lokal starten
supabase functions serve geocode-place --env-file supabase/.env.local

# In einem anderen Terminal testen:
curl -i --location --request POST 'http://localhost:54321/functions/v1/geocode-place' \
  --header 'Authorization: Bearer YOUR_ANON_KEY' \
  --header 'Content-Type: application/json' \
  --data '{"query":"Friedrichshafen, Deutschland"}'
```

### Deployed Function testen:
```bash
curl -i --location --request POST 'https://ykkayjbplutdodummcte.supabase.co/functions/v1/geocode-place' \
  --header 'Authorization: Bearer YOUR_ANON_KEY' \
  --header 'Content-Type: application/json' \
  --data '{"query":"München, Deutschland"}'
```

## Google Places API Setup

### API Key Restrictions (wichtig!):

1. Gehe zu [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
2. Wähle den API Key: `AIzaSyBG207MVH8bkIjk_zNAKplAaB1H45HjndM`
3. **Application restrictions:** Setze auf **None** (da server-seitig)
4. **API restrictions:** Aktiviere nur diese APIs:
   - Places API (New)
   - Geocoding API
   - Time Zone API
5. Speichern

⚠️ **Wichtig:** Bei server-seitiger Nutzung dürfen KEINE HTTP referrer restrictions gesetzt werden!

## Troubleshooting

### "Forbidden" Error
- Prüfe ob API Key Restrictions korrekt sind (siehe oben)
- Prüfe ob alle drei APIs aktiviert sind
- Warte 5-10 Minuten nach Änderungen

### "Unauthorized" Error
- Prüfe ob User JWT Token korrekt übergeben wird
- Prüfe RLS Policies in Supabase

### "ZERO_RESULTS"
- Prüfe Schreibweise der Adresse
- Versuche Format "Stadt, Land" (z.B. "Berlin, Deutschland")

## Kosten-Übersicht

**Google Places API Pricing (Stand 2026):**
- Autocomplete: $0.00283 per request
- Place Details: $0.017 per request
- Timezone: $0.005 per request

**Pro Geocoding-Request:** ~$0.025 (alle drei APIs zusammen)

**Erwartete Kosten bei 1000 Users:**
- Onboarding: 1000 × $0.025 = **$25**
- Monatliche Updates (optional): vernachlässigbar

**Budget:** $50/Monat für Maps/Places API sollte ausreichen.

## API Limits

**Google Places API (kostenloser Kontingent):**
- $200/Monat gratis (~8000 Geocoding-Requests)
- Danach: Pay-as-you-go

**Supabase Edge Functions:**
- Free Tier: 500.000 Requests/Monat
- Mehr als genug für MVP

## Monitoring

### Logs anschauen:
```bash
supabase functions logs geocode-place
```

### Oder im Supabase Dashboard:
https://app.supabase.com/project/ykkayjbplutdodummcte/functions/geocode-place/logs

---

**Nächste Schritte:**
1. ✅ Supabase CLI installieren
2. ✅ Mit Projekt verbinden
3. ✅ Secrets setzen
4. ✅ API Key Restrictions anpassen
5. ✅ Function deployen
6. ✅ Testen mit echten Adressen
