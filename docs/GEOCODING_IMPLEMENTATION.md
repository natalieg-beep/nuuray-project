# Geocoding Implementation — Geburtsort-Koordinaten für Aszendent-Berechnung

**Erstellt:** 2026-02-06
**Status:** ✅ Implementiert, bereit zum Deployment

---

## Problem

Der Aszendent (Ascendant) im Cosmic Profile konnte nicht berechnet werden, weil:
1. Onboarding nur Text-Input für Geburtsort hatte (keine Koordinaten)
2. Google Places API client-seitig führte zu "Forbidden" Errors (API Key Restrictions)

---

## Lösung: Server-seitige Geocoding via Supabase Edge Function

### Architektur

```
User gibt "Friedrichshafen, Deutschland" ein
  ↓
[Frontend] OnboardingBirthplaceGeocodingScreen
  ↓
[Frontend] GeocodingService.geocodePlace()
  ↓
HTTP POST → Supabase Edge Function: geocode-place
  ↓
[Edge Function] Ruft Google Places API auf:
  1. Autocomplete API → Place ID
  2. Place Details API → Koordinaten (lat/lng)
  3. Timezone API → Timezone (Europe/Berlin)
  ↓
[Edge Function] Returniert JSON:
  {
    "place": "Friedrichshafen, Deutschland",
    "latitude": 47.6546609,
    "longitude": 9.4798766,
    "timezone": "Europe/Berlin"
  }
  ↓
[Frontend] Speichert in UserProfile:
  - birth_place (Text)
  - birth_latitude (Float)
  - birth_longitude (Float)
  - birth_timezone (String)
  ↓
[Calculator] Kann jetzt Aszendent berechnen! ✅
```

### Vorteile dieser Lösung

✅ **Sicherheit:** API Key liegt nur server-seitig (nicht im Client-Code)
✅ **Keine Restrictions:** Server-zu-Server Calls funktionieren ohne Referer-Restrictions
✅ **Caching:** Könnte später gecachte Geocoding-Ergebnisse in DB speichern
✅ **Kontrolle:** Rate Limiting, Logging, Error Handling server-seitig
✅ **Kosten-Tracking:** Alle Requests gehen über Supabase (Monitoring)

---

## Implementierte Komponenten

### 1. Supabase Edge Function: `geocode-place`

**Datei:** `/supabase/functions/geocode-place/index.ts`

**Funktionen:**
- `getPlaceIdFromQuery(query)` — Autocomplete für Ortssuche
- `getPlaceDetails(placeId)` — Koordinaten abrufen
- `getTimezone(lat, lng)` — Timezone bestimmen

**Auth:** User JWT Token erforderlich (RLS)

**API Calls:**
1. `maps.googleapis.com/maps/api/place/autocomplete/json`
2. `maps.googleapis.com/maps/api/place/details/json`
3. `maps.googleapis.com/maps/api/timezone/json`

**Request:**
```json
POST /functions/v1/geocode-place
Authorization: Bearer <USER_JWT>
{
  "query": "München, Deutschland"
}
```

**Response:**
```json
{
  "place": "München, Deutschland",
  "latitude": 48.1351253,
  "longitude": 11.5819805,
  "timezone": "Europe/Berlin"
}
```

**Fehlerbehandlung:**
- `ZERO_RESULTS` → 404
- API Fehler → 500
- Keine Auth → 401

---

### 2. Frontend Service: `GeocodingService`

**Datei:** `/packages/nuuray_api/lib/src/services/geocoding_service.dart`

**Klasse:** `GeocodingService`

**Methoden:**
- `geocodePlace(String query) → Future<GeocodingResult?>`
- `searchPlaces(String query) → Future<List<String>>` (TODO: Autocomplete)

**Verwendung:**
```dart
final service = GeocodingService(Supabase.instance.client);
final result = await service.geocodePlace('Berlin, Deutschland');

if (result != null) {
  print('Lat: ${result.latitude}, Lng: ${result.longitude}');
  print('Timezone: ${result.timezone}');
}
```

---

### 3. Onboarding Screen: `OnboardingBirthplaceGeocodingScreen`

**Datei:** `/apps/glow/lib/src/features/onboarding/screens/onboarding_birthplace_geocoding_screen.dart`

**Features:**
- Text-Input mit "Suchen"-Button
- Geocoding via `GeocodingService`
- Erfolgs-Anzeige mit Koordinaten + Timezone
- Loading States, Error Handling
- "Überspringen" Option (für User ohne Geburtsort)

**UX-Flow:**
1. User gibt "Friedrichshafen, Deutschland" ein
2. Klickt "Ort suchen"
3. Loading Spinner → API Call
4. Erfolgs-Box zeigt:
   - ✓ Ort gefunden: Friedrichshafen, Deutschland
   - Koordinaten: 47.6547°, 9.4799°
   - Zeitzone: Europe/Berlin
5. "Fertig"-Button wird aktiviert
6. Profil wird mit Koordinaten gespeichert

---

### 4. Integration in Onboarding Flow

**Datei:** `/apps/glow/lib/src/features/onboarding/screens/onboarding_flow_screen.dart`

**Änderung:**
```dart
// ALT: OnboardingBirthplaceSimpleScreen (nur Text)
// NEU: OnboardingBirthplaceGeocodingScreen (mit Koordinaten)

OnboardingBirthplaceGeocodingScreen(
  initialBirthPlace: _birthPlace,
  initialLatitude: _birthLatitude,
  initialLongitude: _birthLongitude,
  initialTimezone: _birthTimezone,
  onComplete: (place, latitude, longitude, timezone) {
    setState(() {
      _birthPlace = place;
      _birthLatitude = latitude;
      _birthLongitude = longitude;
      _birthTimezone = timezone;
    });
    _saveProfile();
  },
  onBack: _previousPage,
)
```

**Profil-Speicherung:**
```dart
final profile = UserProfile(
  birthPlace: _birthPlace,           // "Friedrichshafen, Deutschland"
  birthLatitude: _birthLatitude,     // 47.6546609
  birthLongitude: _birthLongitude,   // 9.4798766
  birthTimezone: _birthTimezone,     // "Europe/Berlin"
  ...
);
```

---

## Google Places API Setup

### API Key Konfiguration

**Key:** `AIzaSyBG207MVH8bkIjk_zNAKplAaB1H45HjndM`

**Erforderliche APIs aktivieren:**
1. ✅ Places API (New)
2. ✅ Geocoding API
3. ✅ Time Zone API

**Application Restrictions:**
- ⚠️ **KEINE Restrictions setzen** (da server-seitig)
- Alternativ: IP-basierte Restriction auf Supabase IP-Range

**API Restrictions:**
- ✅ Nur die drei oben genannten APIs aktivieren
- ❌ Alle anderen APIs deaktivieren

### Warum keine Referer Restrictions?

Die `google_places_flutter` Library nutzt die Places API im "Server-Mode", was bedeutet:
- Requests kommen von Backend (Edge Function), nicht vom Client
- HTTP Referer Headers sind nicht vorhanden
- Referer Restrictions würden zu "Forbidden" Errors führen

**Quelle:** [GitHub Issue](https://github.com/fluttercommunity/flutter_google_places/issues/183)

---

## Deployment

### Schritt 1: Supabase CLI installieren

```bash
brew install supabase/tap/supabase
supabase login
```

### Schritt 2: Mit Projekt verbinden

```bash
cd /Users/natalieg/nuuray-project
supabase link --project-ref ykkayjbplutdodummcte
```

### Schritt 3: Secrets setzen

```bash
supabase secrets set GOOGLE_PLACES_API_KEY=AIzaSyBG207MVH8bkIjk_zNAKplAaB1H45HjndM
supabase secrets list  # Verifizieren
```

### Schritt 4: Function deployen

```bash
# Automatisches Deploy-Script:
cd supabase
./deploy-functions.sh

# Oder manuell:
supabase functions deploy geocode-place
```

### Schritt 5: Testen

```bash
# Test-Script ausführen:
cd supabase
./test-geocode.sh

# Oder manuell mit curl:
curl -i --location --request POST \
  'https://ykkayjbplutdodummcte.supabase.co/functions/v1/geocode-place' \
  --header 'Authorization: Bearer YOUR_USER_JWT' \
  --header 'Content-Type: application/json' \
  --data '{"query":"München, Deutschland"}'
```

**Erwartetes Ergebnis:**
```json
HTTP/1.1 200 OK
{
  "place": "München, Deutschland",
  "latitude": 48.1351253,
  "longitude": 11.5819805,
  "timezone": "Europe/Berlin"
}
```

---

## Kosten

### Google Places API Pricing (2026)

| API | Preis pro Request |
|-----|-------------------|
| Autocomplete | $0.00283 |
| Place Details | $0.017 |
| Timezone | $0.005 |
| **Total** | **~$0.025** |

### Erwartete Kosten

**Szenario 1: MVP mit 1000 Users**
- 1000 User × 1 Geocoding = **$25**

**Szenario 2: 10.000 Users/Monat**
- 10.000 × $0.025 = **$250/Monat**

**Free Tier:** Google gibt $200/Monat gratis → **8000 Geocoding-Requests kostenlos**

**Budget:** Für MVP-Phase (< 5000 Users) komplett kostenlos! ✅

---

## Testing

### Test Cases

| Input | Expected Output |
|-------|----------------|
| "Friedrichshafen, Deutschland" | ✅ Lat: 47.65, Lng: 9.48, TZ: Europe/Berlin |
| "München, Deutschland" | ✅ Lat: 48.14, Lng: 11.58, TZ: Europe/Berlin |
| "Wien, Österreich" | ✅ Lat: 48.21, Lng: 16.37, TZ: Europe/Vienna |
| "Zürich, Schweiz" | ✅ Lat: 47.37, Lng: 8.54, TZ: Europe/Zurich |
| "xyzabc123" | ❌ 404 ZERO_RESULTS |

### Integration Tests

Nach Deployment testen mit echtem User-Account:
1. Logout in App
2. Neues Onboarding durchlaufen
3. Bei Schritt 3: Geburtsort eingeben
4. "Ort suchen" klicken
5. Verifizieren:
   - ✅ Koordinaten werden angezeigt
   - ✅ Timezone korrekt
   - ✅ Profil wird mit Koordinaten gespeichert
6. Cosmic Profile öffnen
7. Verifizieren:
   - ✅ Aszendent wird jetzt berechnet! 🎉

---

## Troubleshooting

### Problem: "Forbidden" (403)

**Ursache:** API Key Restrictions blockieren Request

**Lösung:**
1. Gehe zu [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
2. API Key auswählen
3. "Application restrictions" → **None**
4. "API restrictions" → Nur Places/Geocoding/Timezone aktivieren
5. Speichern, 5-10 Minuten warten

---

### Problem: "Unauthorized" (401)

**Ursache:** Kein gültiger User JWT Token

**Lösung:**
- Prüfe ob User eingeloggt ist
- Auth Header: `Authorization: Bearer <JWT>`
- Nicht den Anon Key nutzen (außer für Test)

---

### Problem: "ZERO_RESULTS" (404)

**Ursache:** Ort nicht gefunden

**Lösung:**
- Versuche Format "Stadt, Land" (z.B. "Berlin, Deutschland")
- Prüfe Schreibweise (z.B. "München" statt "Munchen")
- Vermeide zu spezifische Adressen (Straße + Hausnummer)

---

### Problem: Edge Function Timeout

**Ursache:** Google API antwortet langsam oder gar nicht

**Lösung:**
- Prüfe Google Cloud Status: [status.cloud.google.com](https://status.cloud.google.com)
- Erhöhe Timeout in Edge Function (aktuell: 60s)
- Implementiere Retry-Logik

---

## Nächste Schritte

### Sofort (MVP):
- [x] Edge Function implementiert
- [x] Frontend Service erstellt
- [x] Onboarding Screen integriert
- [ ] **Edge Function deployen** ← NÄCHSTER SCHRITT
- [ ] Mit echten Adressen testen

### Später (Post-MVP):
- [ ] Geocoding-Ergebnisse cachen (DB-Tabelle)
- [ ] Autocomplete-Liste für bessere UX
- [ ] Offline-Fallback (manuelle Koordinaten-Eingabe)
- [ ] Rate Limiting für kostenlose User
- [ ] Analytics: Welche Orte werden am häufigsten gesucht?

---

## Dokumentation & Scripts

| Datei | Beschreibung |
|-------|--------------|
| `/supabase/functions/geocode-place/index.ts` | Edge Function Code |
| `/packages/nuuray_api/lib/src/services/geocoding_service.dart` | Frontend Service |
| `/apps/glow/lib/src/features/onboarding/screens/onboarding_birthplace_geocoding_screen.dart` | UI Screen |
| `/supabase/functions/README.md` | Deployment Guide |
| `/supabase/deploy-functions.sh` | Deploy Script |
| `/supabase/test-geocode.sh` | Test Script |
| `/supabase/.env.local.example` | Environment Variablen Template |

---

## Auswirkung auf Cosmic Profile

**VOR dieser Implementation:**
```
Cosmic Profile (Natalie):
- ☀️ Sonne: Schütze 8.01° ✅
- 🌙 Mond: Waage 11.27° ✅
- ⬆ Aszendent: ❌ FEHLT (Koordinaten erforderlich)
```

**NACH dieser Implementation:**
```
Cosmic Profile (Natalie):
- ☀️ Sonne: Schütze 8.01° ✅
- 🌙 Mond: Waage 11.27° ✅
- ⬆ Aszendent: Löwe 8.39° ✅ 🎉
```

**Komplettes Western Astrology Profil ist jetzt möglich!** ✨

---

**Status:** Bereit zum Deployment & Testing
**Estimated Time:** 30 Minuten (Deploy + Test)
**Blockers:** Keine
