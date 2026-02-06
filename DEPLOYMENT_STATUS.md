# Deployment Status — Google Places API Integration

**Datum:** 2026-02-06
**Status:** ✅ Edge Function deployed, bereit zum Testen

---

## ✅ Was wurde deployed

### 1. Supabase Projekt verbunden
```
Project Ref: ykkayjbplutdodummcte
Region: EU Central
Status: ✅ Connected
```

### 2. Secrets gesetzt
```
GOOGLE_PLACES_API_KEY: AIzaSyBG207MVH8bkIjk_zNAKplAaB1H45HjndM
Status: ✅ Set
```

### 3. Edge Function deployed
```
Function: geocode-place
URL: https://ykkayjbplutdodummcte.supabase.co/functions/v1/geocode-place
Status: ✅ Deployed
Dashboard: https://supabase.com/dashboard/project/ykkayjbplutdodummcte/functions
```

---

## ⏳ Nächster Schritt: Google API Key Restrictions

**WICHTIG:** Du musst jetzt die Google API Key Restrictions anpassen!

### Schritt-für-Schritt:

1. **Gehe zu:** https://console.cloud.google.com/apis/credentials

2. **Wähle deinen API Key:** `AIzaSyBG207MVH8bkIjk_zNAKplAaB1H45HjndM`

3. **Application restrictions:**
   - Setze auf **"None"**
   - ⚠️ Das ist wichtig! Server-zu-Server Calls funktionieren nur ohne Referer-Restrictions

4. **API restrictions:**
   - Wähle **"Restrict key"**
   - Aktiviere **nur** diese 3 APIs:
     - ✅ Places API (New)
     - ✅ Geocoding API
     - ✅ Time Zone API
   - Alle anderen APIs deaktivieren

5. **Speichern** und 5-10 Minuten warten

---

## 🧪 Testing nach Google API Setup

### Option 1: In der App testen (empfohlen)

1. Öffne die App im Simulator/Device
2. Logout (falls eingeloggt)
3. Durchlaufe das Onboarding neu:
   - Schritt 1: Name eingeben
   - Schritt 2: Geburtsdatum/-zeit eingeben
   - Schritt 3: Geburtsort → **"Friedrichshafen, Deutschland"** eingeben
   - Klicke **"Ort suchen"**
4. **Erwartetes Ergebnis:**
   ```
   ✓ Ort gefunden: Friedrichshafen, Deutschland
   Koordinaten: 47.6547°, 9.4799°
   Zeitzone: Europe/Berlin
   ```
5. Onboarding abschließen
6. Öffne **Cosmic Profile** → Aszendent sollte jetzt berechnet sein! 🎉

### Option 2: Mit curl testen (fortgeschritten)

Dafür brauchst du einen User JWT Token:

1. In der App einloggen
2. In den Browser DevTools den JWT Token aus dem LocalStorage kopieren
3. Dann testen:

```bash
curl -i --location --request POST \
  'https://ykkayjbplutdodummcte.supabase.co/functions/v1/geocode-place' \
  --header 'Authorization: Bearer YOUR_USER_JWT_TOKEN' \
  --header 'Content-Type: application/json' \
  --data '{"query":"München, Deutschland"}'
```

**Erwartete Response:**
```json
{
  "place": "München, Deutschland",
  "latitude": 48.1351253,
  "longitude": 11.5819805,
  "timezone": "Europe/Berlin"
}
```

---

## 🐛 Troubleshooting

### "Forbidden" (403) Error
**Ursache:** API Key Restrictions blockieren Request
**Lösung:** Siehe oben — "Application restrictions" auf "None" setzen

### "Unauthorized" (401) Error
**Ursache:** Kein gültiger User JWT Token
**Lösung:** In der App testen (dort wird automatisch der User-Token übergeben)

### "ZERO_RESULTS" (404) Error
**Ursache:** Ort nicht gefunden
**Lösung:** Versuche Format "Stadt, Land" (z.B. "Berlin, Deutschland")

---

## 📊 Deployment Details

**NPX Commands verwendet:**
```bash
export SUPABASE_ACCESS_TOKEN=sbp_...
npx supabase link --project-ref ykkayjbplutdodummcte
npx supabase secrets set GOOGLE_PLACES_API_KEY=AIzaSy...
npx supabase functions deploy geocode-place
```

**Deployment Zeit:** ~2 Minuten
**Status:** ✅ Erfolgreich

---

## ✅ Checklist

- [x] Supabase CLI Setup (via NPX)
- [x] Projekt verbunden
- [x] Google API Key Secret gesetzt
- [x] Edge Function deployed
- [ ] **Google API Key Restrictions angepasst** ← DU BIST HIER
- [ ] In App getestet
- [ ] Aszendent-Berechnung verifiziert

---

**Nächste Aktion:** Google Cloud Console öffnen und API Key Restrictions anpassen!
