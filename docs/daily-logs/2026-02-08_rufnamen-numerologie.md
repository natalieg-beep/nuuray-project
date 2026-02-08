# Rufnamen-Numerologie Feature

**Datum:** 2026-02-08
**Feature:** Display Name Number (Rufnamen-Numerologie)
**Status:** ✅ Implementiert

---

## 📋 Übersicht

Implementierung der Rufnamen-Numerologie, die den numerologischen Wert des Display-Names (Rufname) berechnet und in der Numerology Card anzeigt.

### Beispiel
- **Rufname:** "Natalie"
- **Berechnung:** N+A+T+A+L+I+E = 5+1+2+1+3+9+5 = 26 → 2+6 = **8**
- **Anzeige:** Wird direkt unter der Life Path Number angezeigt

---

## 🎯 User-Request

> "ich möchte noch eine Analyse der Namenszahl für den Rufnamen (Beispiel Natalie = 8) soll bitte in der Reihe unter der Lebenszahl mit aufgeführt werden. geht das? Wenn ja leg los + dokumentieren"

---

## ✅ Was wurde implementiert

### 1. **BirthChart Model erweitert**

**Datei:** `packages/nuuray_core/lib/src/models/birth_chart.dart`

```dart
// Numerologie - Kern-Zahlen
final int? lifePathNumber;
final int? displayNameNumber; // NEU: Rufname-Numerologie (z.B. "Natalie" = 8)
final int? birthdayNumber;
final int? attitudeNumber;
final int? personalYear;
final int? maturityNumber;
```

**Änderungen:**
- ✅ `displayNameNumber` Field hinzugefügt
- ✅ Constructor erweitert
- ✅ `fromJson()` erweitert
- ✅ `toJson()` erweitert

---

### 2. **SignatureService erweitert**

**Datei:** `packages/nuuray_core/lib/src/services/signature_service.dart`

```dart
static Future<BirthChart> calculateSignature({
  required String userId,
  required DateTime birthDate,
  DateTime? birthTime,
  double? birthLatitude,
  double? birthLongitude,
  String? birthTimezone,
  String? displayName,  // NEU
  String? birthName,
  String? currentName,
  @Deprecated('Use birthName instead') String? fullName,
}) async {
  // ...

  // Rufnamen-Numerologie (Display Name Number)
  // Beispiel: "Natalie" → N+A+T+A+L+I+E = 5+1+2+1+3+9+5 = 26 → 8
  int? displayNameNumber;
  if (displayName != null && displayName.trim().isNotEmpty) {
    displayNameNumber = NumerologyCalculator.calculateExpression(displayName.trim());
    log('🔢 Display Name Number (${displayName.trim()}): $displayNameNumber${displayNameNumber != null && NumerologyCalculator.isMasterNumber(displayNameNumber) ? " ✨" : ""}');
  }

  // ...
}
```

**Änderungen:**
- ✅ `displayName` Parameter hinzugefügt
- ✅ Rufnamen-Numerologie Berechnung implementiert
- ✅ Nutzt `NumerologyCalculator.calculateExpression()` (pythagoräisches System)
- ✅ Logging für Debug-Zwecke
- ✅ BirthChart mit displayNameNumber erweitert

---

### 3. **Signature Provider angepasst**

**Datei:** `apps/glow/lib/src/features/signature/providers/signature_provider.dart`

```dart
// "Deine Signatur" berechnen
final birthChart = await SignatureService.calculateSignature(
  userId: userProfile.id,
  birthDate: birthDate,
  birthTime: birthTime,
  birthLatitude: birthLatitude,
  birthLongitude: birthLongitude,
  birthTimezone: birthTimezone,
  displayName: userProfile.displayName,  // NEU
  birthName: birthName,
  currentName: currentName,
);
```

**Änderungen:**
- ✅ `displayName` aus UserProfile wird übergeben
- ✅ Automatische Berechnung beim Chart-Load

---

### 4. **NumerologyCard UI erweitert**

**Datei:** `apps/glow/lib/src/features/signature/widgets/numerology_card.dart`

**Neue UI-Komponente:**
```dart
// Display Name Number (unter Life Path)
if (displayNameNumber != null)
  Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.surfaceDark,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.15),
          ),
          child: Center(
            child: Text(
              '$displayNameNumber',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.numerologyDisplayName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.numerologyDisplayNameMeaning,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 10,
                    ),
              ),
            ],
          ),
        ),
        if (NumerologyCalculator.isMasterNumber(displayNameNumber)) ...[
          const SizedBox(width: 4),
          const Text('✨', style: TextStyle(fontSize: 16)),
        ],
      ],
    ),
  ),
```

**Position:**
- ✅ Direkt unter der Life Path Number
- ✅ Vor den Kern-Zahlen-Grid (Birthday, Attitude, Personal Year, Maturity)

**Design:**
- ✅ Kompakte horizontale Card mit rundem Zahlen-Badge
- ✅ Label + Bedeutung (zweizeilig)
- ✅ Meisterzahl-Indicator (✨) wenn 11, 22 oder 33
- ✅ Konsistentes Design mit AppColors

---

### 5. **i18n Labels hinzugefügt**

#### Deutsch (`app_de.arb`)
```json
"numerologyDisplayName": "Rufname",
"numerologyDisplayNameMeaning": "Deine gewählte Energie",
```

#### Englisch (`app_en.arb`)
```json
"numerologyDisplayName": "Display Name",
"numerologyDisplayNameMeaning": "Your chosen energy",
```

---

### 6. **Supabase Migration**

**Datei:** `supabase/migrations/006_add_display_name_number.sql`

```sql
-- Display Name Number Spalte hinzufügen
ALTER TABLE birth_charts
ADD COLUMN IF NOT EXISTS display_name_number INTEGER;

-- Kommentar hinzufügen
COMMENT ON COLUMN birth_charts.display_name_number IS 'Numerologie-Zahl des Rufnamens (1-9/11/22/33). Beispiel: "Natalie" = 8';
```

**Änderungen:**
- ✅ Neue Spalte `display_name_number` (INTEGER, nullable)
- ✅ Kommentar für Dokumentation

---

## 🔢 Berechnungs-Logik

### Pythagoräisches System

Die Rufnamen-Numerologie nutzt die gleiche Berechnungsmethode wie die Expression Number:

```
Buchstabe → Zahl (1-9):
A=1, B=2, C=3, D=4, E=5, F=6, G=7, H=8, I=9
J=1, K=2, L=3, M=4, N=5, O=6, P=7, Q=8, R=9
S=1, T=2, U=3, V=4, W=5, X=6, Y=7, Z=8
```

### Beispiele

**Beispiel 1: "Natalie"**
```
N = 5
A = 1
T = 2
A = 1
L = 3
I = 9
E = 5
-----
Summe: 26 → 2+6 = 8
```

**Beispiel 2: "Anna"**
```
A = 1
N = 5
N = 5
A = 1
-----
Summe: 12 → 1+2 = 3
```

**Beispiel 3: "Max"** (Meisterzahl!)
```
M = 4
A = 1
X = 6
-----
Summe: 11 ✨ (Meisterzahl, keine weitere Reduktion)
```

### Meisterzahlen

- **11:** Spiritueller Botschafter, Intuition ✨
- **22:** Meister-Manifestierer, Brückenbauer ✨
- **33:** Meister-Heiler, kosmische Liebe ✨

Meisterzahlen werden NICHT weiter reduziert!

---

## 📊 UI-Struktur

### Vorher (nur Life Path prominent)
```
┌─────────────────────────────────────┐
│  ┌───────────────────────────────┐  │
│  │  Life Path: 8                 │  │
│  │  "Macht & Manifestation"      │  │
│  └───────────────────────────────┘  │
│                                     │
│  Grid: Birthday, Attitude, etc.    │
└─────────────────────────────────────┘
```

### Nachher (mit Rufname)
```
┌─────────────────────────────────────┐
│  ┌───────────────────────────────┐  │
│  │  Life Path: 8                 │  │
│  │  "Macht & Manifestation"      │  │
│  └───────────────────────────────┘  │
│                                     │
│  ┌───────────────────────────────┐  │
│  │  [8]  Rufname                 │  │  ← NEU!
│  │       Deine gewählte Energie  │  │
│  └───────────────────────────────┘  │
│                                     │
│  Grid: Birthday, Attitude, etc.    │
└─────────────────────────────────────┘
```

---

## 🎨 Design-Details

### Farben
- **Badge Background:** `AppColors.primary.withOpacity(0.15)`
- **Badge Zahl:** `AppColors.primary` (bold)
- **Card Background:** `AppColors.surfaceDark`
- **Label:** `AppColors.textSecondary`
- **Meaning:** `AppColors.textPrimary`

### Abstände
- **Card Padding:** 16px horizontal, 12px vertical
- **Badge Size:** 40x40px (rund)
- **Spacing zwischen Life Path und Display Name:** 16px
- **Spacing zwischen Display Name und Grid:** 16px

### Typography
- **Zahl:** `titleMedium`, bold
- **Label:** `bodySmall`, w500
- **Meaning:** `bodySmall`, fontSize 10

---

## 🧪 Test-Szenarien

### Szenario 1: Normale Zahl
- **Input:** displayName = "Natalie"
- **Expected:** displayNameNumber = 8
- **UI:** Zeigt Badge mit "8", keine ✨

### Szenario 2: Meisterzahl
- **Input:** displayName = "Max"
- **Expected:** displayNameNumber = 11
- **UI:** Zeigt Badge mit "11", mit ✨

### Szenario 3: Kein Display Name
- **Input:** displayName = null oder ""
- **Expected:** displayNameNumber = null
- **UI:** Card wird nicht angezeigt

### Szenario 4: Umlaute
- **Input:** displayName = "Müller"
- **Expected:** displayNameNumber berechnet aus "MUELLER" (Ü → UE)
- **UI:** Zeigt korrekte Zahl

---

## 📂 Geänderte Dateien

### Core Package (nuuray_core)
1. `packages/nuuray_core/lib/src/models/birth_chart.dart`
   - ✅ `displayNameNumber` Field hinzugefügt
   - ✅ Constructor, fromJson, toJson erweitert

2. `packages/nuuray_core/lib/src/services/signature_service.dart`
   - ✅ `displayName` Parameter hinzugefügt
   - ✅ Rufnamen-Numerologie Berechnung implementiert
   - ✅ Logging für Debug

### UI Package (nuuray_ui)
3. `packages/nuuray_ui/lib/src/l10n/app_de.arb`
   - ✅ `numerologyDisplayName` hinzugefügt
   - ✅ `numerologyDisplayNameMeaning` hinzugefügt

4. `packages/nuuray_ui/lib/src/l10n/app_en.arb`
   - ✅ `numerologyDisplayName` hinzugefügt
   - ✅ `numerologyDisplayNameMeaning` hinzugefügt

### Glow App
5. `apps/glow/lib/src/features/signature/providers/signature_provider.dart`
   - ✅ `displayName` wird von UserProfile an SignatureService übergeben

6. `apps/glow/lib/src/features/signature/widgets/numerology_card.dart`
   - ✅ UI-Komponente für Display Name Number hinzugefügt
   - ✅ Position: Unter Life Path, vor Grid

### Backend (Supabase)
7. `supabase/migrations/006_add_display_name_number.sql`
   - ✅ Neue Migration für DB-Spalte

### Dokumentation
8. `docs/daily-logs/2026-02-08_rufnamen-numerologie.md`
   - ✅ Diese Datei

---

## 💡 Technische Highlights

### 1. Wiederverwendung existierender Logik
Statt neue Berechnungsmethoden zu schreiben, nutzen wir einfach:
```dart
NumerologyCalculator.calculateExpression(displayName)
```

Das ist genau die gleiche Logik wie für die Expression Number, macht Sinn weil:
- **Expression Number** = Numerologie des VOLLEN Namens
- **Display Name Number** = Numerologie des RUFNAMENS

Beide nutzen das pythagoräische System (alle Buchstaben summieren).

### 2. Automatische Normalisierung
Der `NumerologyCalculator` normalisiert automatisch:
- ✅ Uppercase-Konvertierung
- ✅ Umlaute ersetzen (Ä→AE, Ö→OE, Ü→UE, ß→SS)
- ✅ Sonderzeichen entfernen
- ✅ Nur A-Z behalten

### 3. Meisterzahl-Erkennung
Automatische Erkennung von 11, 22, 33:
```dart
NumerologyCalculator.isMasterNumber(displayNameNumber)
```

### 4. Null-Safety
- Wenn `displayName` leer oder null → `displayNameNumber` bleibt null
- UI zeigt Card nur wenn Wert vorhanden
- Keine Crashes oder Fehler

---

## 🔄 Datenfluss

```
User Profil (displayName)
  ↓
signature_provider.dart
  ↓ (übergibt displayName)
SignatureService.calculateSignature()
  ↓
NumerologyCalculator.calculateExpression(displayName)
  ↓ (pythagoräisches System)
displayNameNumber: int?
  ↓
BirthChart Model
  ↓
Supabase birth_charts Tabelle
  ↓
signatureProvider (cached)
  ↓
NumerologyCard Widget
  ↓
UI: Display Name Number Card
```

---

## 🎯 User Journey

### 1. Onboarding
- User gibt Rufname ein: "Natalie"
- Rufname wird in `profiles.display_name` gespeichert

### 2. Chart-Berechnung
- `SignatureService` liest `displayName` aus UserProfile
- Berechnet `displayNameNumber` = 8
- Speichert in `birth_charts.display_name_number`

### 3. Home Screen
- User scrollt zu "Deine Signatur"
- Sieht Numerology Card
- Life Path Number prominent (z.B. 8)
- **NEU:** Darunter Rufnamen-Nummer (z.B. 8)
- Danach Grid mit Birthday, Attitude, etc.

### 4. Bei Namensänderung
- User ändert Profil (Edit Profile Screen)
- Chart wird neu berechnet
- `displayNameNumber` wird aktualisiert
- UI aktualisiert sich automatisch (Provider Invalidation)

---

## ✅ Status

- ✅ **Implementiert:** Display Name Number Berechnung
- ✅ **Implementiert:** UI-Integration in NumerologyCard
- ✅ **Implementiert:** i18n (DE + EN)
- ✅ **Implementiert:** Supabase Migration
- ✅ **Dokumentiert:** Vollständig
- ✅ **MVP-Ready:** Ja

---

## 🚀 Nächste Schritte (Optional)

### Mögliche Erweiterungen
1. **Detailed View:** Tap auf Display Name Number → Detail-Screen mit Bedeutung
2. **Interpretation:** Claude API könnte personalisierte Interpretation generieren
3. **Vergleich:** Birth Energy vs. Current Energy vs. Display Name
4. **Statistik:** Häufigste Rufnamen-Zahlen bei Users

---

**Datum:** 2026-02-08
**Dauer:** ~30 Minuten
**Lines of Code:** ~150 Zeilen
**Status:** ✅ FERTIG & PRODUKTIONSREIF
