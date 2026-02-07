# ✅ Onboarding auf 2 Schritte umgestellt — 2026-02-08

> **Status:** ✅ Erfolgreich implementiert
> **Dauer:** ~20 Minuten
> **Änderungen:** Onboarding-Flow von 3 → 2 Schritte, Name-Felder von 4 → 3

---

## 🎯 Ziel

Onboarding an GLOW_SPEC_V2.md anpassen:
- **2 Schritte** statt 3
- **Schritt 1:** Name & Identität (3 Felder)
- **Schritt 2:** Geburtsdaten KOMBINIERT (Datum + Zeit + Ort auf einem Screen)

---

## ✅ Änderungen

### 1. Neuer Screen: `onboarding_birthdata_combined_screen.dart`
**Datei:** `apps/glow/lib/src/features/onboarding/screens/onboarding_birthdata_combined_screen.dart`

**Features:**
- Kombiniert Geburtsdatum, Geburtszeit UND Geburtsort auf einem Screen
- Geocoding-Integration (Google Places via Supabase Edge Function)
- Alles optional außer Geburtsdatum
- Success/Error States für Geocoding
- ScrollView für lange Inhalte

**UI-Elemente:**
```
- 📅 Geburtsdatum (PFLICHT) → Date Picker
- 🕐 Geburtszeit (optional) → Time Picker
  - ☑️ Checkbox: "Geburtszeit ist mir nicht bekannt"
- 📍 Geburtsort (optional)
  - TextField für Ortssuche
  - "Ort suchen" Button
  - Success-Anzeige (grün): Ort + Koordinaten + Timezone
  - Error-Anzeige (rot): Fehlermeldung
- ℹ️ Hinweis: Ohne Ort & Zeit kein Aszendent
```

---

### 2. OnboardingFlowScreen angepasst
**Datei:** `apps/glow/lib/src/features/onboarding/screens/onboarding_flow_screen.dart`

**Änderungen:**
- ✅ `3 Schritte` → `2 Schritte`
- ✅ Import geändert: `onboarding_birthdate_screen.dart` + `onboarding_birthplace_autocomplete_screen.dart` → `onboarding_birthdata_combined_screen.dart`
- ✅ Progress Indicator: `/ 3` → `/ 2`
- ✅ PageView: 3 Children → 2 Children
- ✅ Schritt 2 kombiniert Datum, Zeit, Ort in einem Screen

**Vorher:**
```dart
// Schritt 1: Name
// Schritt 2: Geburtsdatum & -zeit
// Schritt 3: Geburtsort
```

**Jetzt:**
```dart
// Schritt 1: Name
// Schritt 2: Geburtsdaten KOMBINIERT (Datum + Zeit + Ort)
```

---

### 3. Name-Screen vereinfacht
**Datei:** `apps/glow/lib/src/features/onboarding/screens/onboarding_name_screen.dart`

**Änderungen:**
- ✅ **4 Felder → 3 Felder**
- ✅ Umbenennung & Vereinfachung gemäß GLOW_SPEC_V2

**Vorher (4 Felder):**
1. `displayName` (Rufname) — PFLICHT
2. `fullFirstNames` (Vornamen lt. Geburtsurkunde) — OPTIONAL
3. `lastName` (Nachname) — OPTIONAL
4. `birthName` (Geburtsname) — OPTIONAL

**Jetzt (3 Felder):**
1. **`displayName`** (Rufname/Username) — PFLICHT
   - "Wie sollen wir dich nennen?"
2. **`fullBirthName`** (Voller Geburtsname) — OPTIONAL
   - "Lt. Geburtsurkunde, für präzise Numerologie"
   - Verwendet für: Expression, Soul Urge, Personality
3. **`currentLastName`** (Nachname aktuell) — OPTIONAL
   - "Falls geändert nach Heirat/Namensänderung"
   - Beeinflusst aktuelle Namens-Energie

**Logik:**
- `fullBirthName` wird für Numerologie-Berechnungen verwendet (Geburtsname)
- `currentLastName` fließt in aktuelle Energie ein (nach Namensänderung)

---

## 📊 Code-Statistik

**Neue Dateien:**
- `onboarding_birthdata_combined_screen.dart` (~500 Zeilen)

**Geänderte Dateien:**
- `onboarding_flow_screen.dart` (3 → 2 Schritte)
- `onboarding_name_screen.dart` (4 → 3 Felder)

---

## ✅ Ergebnis

### Vorher (3 Schritte)
```
Schritt 1: Name (4 Felder)
  → Rufname
  → Vornamen lt. Geburtsurkunde
  → Nachname
  → Geburtsname

Schritt 2: Geburtsdatum & -zeit
  → Datum (Pflicht)
  → Zeit (Optional)

Schritt 3: Geburtsort
  → Ort-Suche (Optional)
  → Geocoding
```

### Jetzt (2 Schritte)
```
Schritt 1: Name & Identität (3 Felder)
  → Rufname/Username (Pflicht)
  → Voller Geburtsname (Optional)
  → Nachname aktuell (Optional)

Schritt 2: Geburtsdaten KOMBINIERT
  → Datum (Pflicht)
  → Zeit (Optional)
  → Ort (Optional, mit Geocoding)
```

---

## 🎯 Vorteile

1. ✅ **Schneller:** User durchläuft nur 2 Screens statt 3
2. ✅ **Übersichtlicher:** Alle Geburtsdaten auf einem Screen
3. ✅ **Logischer:** Name-Felder vereinfacht (3 statt 4)
4. ✅ **Spec-konform:** Entspricht GLOW_SPEC_V2.md
5. ✅ **Weniger Code:** 1 kombinierter Screen statt 2 separate

---

## 🔄 Datenbank-Schema (unverändert)

**profiles Tabelle:**
```sql
-- Name-Felder (bereits vorhanden)
display_name TEXT NOT NULL
full_first_names TEXT  -- Wird als fullBirthName verwendet
last_name TEXT          -- Wird als currentLastName verwendet
birth_name TEXT         -- Deprecated, wird auf NULL gesetzt

-- Geburtsdaten (bereits vorhanden)
birth_date DATE NOT NULL
birth_time TIME
birth_place TEXT
birth_latitude FLOAT
birth_longitude FLOAT
birth_timezone TEXT
```

**Wichtig:** Datenbank-Schema bleibt unverändert! Nur die UI/UX wurde angepasst.

---

## ⚠️ Migration

**Bestehende User (falls vorhanden):**
- Alte Felder bleiben kompatibel
- `full_first_names` → wird als `fullBirthName` interpretiert
- `last_name` → wird als `currentLastName` interpretiert
- `birth_name` → wird ignoriert (deprecated)

**Kein DB-Update nötig!**

---

## 🧪 Testing

- [ ] **Onboarding durchspielen** (2 Schritte)
- [ ] **Name-Felder prüfen** (3 Felder, richtige Labels)
- [ ] **Kombinierter Birthdata-Screen** (Datum + Zeit + Ort)
- [ ] **Geocoding funktioniert** (Ort suchen)
- [ ] **Speichern funktioniert** (Profil wird korrekt angelegt)
- [ ] **Navigation zu Home Screen** (nach Fertig-Button)

---

## 📝 Dokumentation aktualisiert

- ✅ `TODO.md` — Inkonsistenz gelöst
- ✅ `docs/glow/README.md` — Status aktualisiert
- ⏳ `docs/glow/CHANGELOG.md` — TODO: Release-Notes hinzufügen

---

## 🚀 Nächste Schritte

1. **Testing:** App starten und Onboarding durchspielen
2. **Bug-Fixes:** Falls Fehler auftauchen
3. **Screenshots:** Für Dokumentation
4. **CHANGELOG.md aktualisieren:** Release-Notes schreiben

---

**Datum:** 2026-02-08
**Dauer:** ~20 Minuten
**Ergebnis:** ✅ Onboarding auf 2 Schritte reduziert, Name-Felder vereinfacht
**Status:** Bereit zum Testen!
