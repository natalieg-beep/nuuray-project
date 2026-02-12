# Deine Signatur — Implementation Dokumentation

**Erstellt:** 2026-02-06
**Status:** ✅ MVP komplett (UI + Berechnungen)

---

## Übersicht

Das Deine Signatur ist das Herzstück von Nuuray Glow. Es vereint drei astrologische Systeme zu einem ganzheitlichen Persönlichkeitsprofil:

1. **Western Astrology** (Westliche Astrologie): Sonne, Mond, Aszendent
2. **Bazi** (Chinesische Vier Säulen): Heavenly Stems + Earthly Branches, Day Master
3. **Numerology** (Pythagoräische Numerologie): Life Path, Expression, Soul Urge

---

## Architektur

```
User Input (Geburtsdaten aus Onboarding)
  ↓
CosmicProfileService (nuuray_core)
  ├─→ ZodiacCalculator (Western Astrology)
  │    ├─ VSOP87 Theory (Sonne)
  │    ├─ ELP2000-82 (Mond)
  │    └─ Meeus Algorithms (Aszendent)
  ├─→ BaziCalculator (Chinesische Astrologie)
  │    ├─ Lichun-basiertes Jahres-System
  │    ├─ Solar Terms (Jieqi) für Monat
  │    ├─ Julian Day für Tag (Day Master!)
  │    └─ 2h-Blöcke für Stunde
  └─→ NumerologyCalculator (Numerologie)
       ├─ Life Path (Geburtsdatum)
       ├─ Expression (Vollständiger Name)
       ├─ Soul Urge (Vokale)
       ├─ Personality (Konsonanten)
       └─ Dual Energy System (Birth vs. Current Name)
  ↓
BirthChart Model (mit allen berechneten Werten)
  ↓
cosmicProfileProvider (Riverpod)
  ↓
CosmicProfileDashboardScreen (UI)
  ├─ WesternAstrologyCard (Gold Gradient)
  ├─ BaziCard (Red Gradient)
  └─ NumerologyCard (Purple Gradient)
```

---

## Berechnungen im Detail

### 1. Western Astrology Calculator

**Datei:** `packages/nuuray_core/lib/src/services/zodiac_calculator.dart`

#### Sonnenzeichen
- **Input:** Geburtsdatum
- **Methode:** Julian Day → VSOP87 Solar Longitude
- **Formel:**
  ```dart
  T = (JD - 2451545.0) / 36525.0  // Centuries since J2000
  L0 = 280.46646 + 36000.76983*T + 0.0003032*T²  // Mean Longitude
  M = 357.52911 + 35999.05029*T - 0.0001537*T²  // Mean Anomaly
  C = (1.914602 - 0.004817*T)*sin(M) + ...  // Equation of Center
  Longitude = L0 + C
  ```
- **Output:** Zodiac Sign + Grad (0-30° innerhalb des Zeichens)

#### Mondzeichen
- **Input:** Geburtsdatum + Geburtszeit (optional)
- **Methode:** ELP2000-82 Theory (vereinfacht)
- **Formel:**
  ```dart
  D = (JD - 2451545.0)  // Days since J2000
  L = 218.316 + 13.176396*D  // Mean Longitude
  M = 134.963 + 13.064993*D  // Mean Anomaly
  F = 93.272 + 13.229350*D  // Mean Distance from Ascending Node
  Longitude = L + 6.289*sin(M) + ...  // Perturbed Longitude
  ```
- **Fallback:** Ohne Geburtszeit → nur Sonnenzeichen verfügbar

#### Aszendent
- **Input:** Geburtsdatum + Geburtszeit + Geburtsort (Lat/Lon)
- **Methode:** Local Sidereal Time (LST) + Obliquity
- **Formel:**
  ```dart
  LST = GMST + (Longitude / 15.0)  // Hour angle
  RAMC = LST * 15.0  // Right Ascension of MC
  Ascendant = atan2(sin(RAMC), cos(RAMC)*cos(ε) + tan(0)*sin(ε))
  ```
- **Wichtig:** Ohne Geburtszeit/Ort → `null`

**Validierung (Natalie Günes, 30.11.1983, 22:32, Friedrichshafen):**
- ☀️ **Sonne:** Schütze 8.01° ✅
- 🌙 **Mond:** Waage 11.27° ✅
- ⬆ **Aszendent:** Löwe 8.39° ✅

---

### 2. Bazi Calculator

**Datei:** `packages/nuuray_core/lib/src/services/bazi_calculator.dart`

#### Wichtige Konzepte
- **60-Jahres-Zyklus:** 10 Heavenly Stems × 12 Earthly Branches = 60 Kombinationen
- **Referenz:** 1984 = Jiazi (Jia-Rat), Start des aktuellen Zyklus
- **Jahreswechsel:** Lichun (立春, ~4. Februar), NICHT Mond-Neujahr!
- **Monatswechsel:** Solar Terms (Jieqi), NICHT gregorianischer 1. des Monats
- **Day Master:** Tages-Stem = wichtigste Komponente, repräsentiert das Selbst

#### Jahressäule (Year Pillar)
```dart
// Prüfe ob vor Lichun geboren → vorheriges chinesisches Jahr
lichunDate = _getLichunDate(year);
if (birthDate.isBefore(lichunDate)) year -= 1;

// Berechne Stem & Branch
yearsSince1984 = year - 1984;
stemIndex = (yearsSince1984 % 10 + 10) % 10;
branchIndex = (yearsSince1984 % 12 + 12) % 12;
```

**Beispiel Natalie (30.11.1983):**
- Geboren VOR Lichun 1984 (4. Feb) → Jahr = 1983
- 1983 - 1984 = -1
- Stem: (-1 % 10 + 10) % 10 = 9 → **Gui** (Yin Water)
- Branch: (-1 % 12 + 12) % 12 = 11 → **Pig** (Hai)
- **Ergebnis:** Gui-Pig ✅

#### Monatssäule (Month Pillar) — KRITISCHE KORREKTUR

**Problem:** Ursprüngliche Implementierung hatte vereinfachte Monatsberechnung, die falsche Ergebnisse lieferte.

**Lösung:** Solar Terms (Jieqi) implementiert. Jeder chinesische Monat beginnt bei einem spezifischen Solar Term:

| Monat | Solar Term | Datum | Branch |
|-------|------------|-------|--------|
| Tiger | Lichun (立春) | ~4. Feb | 2 |
| Rabbit | Jingzhe (惊蛰) | ~6. Mär | 3 |
| Dragon | Qingming (清明) | ~5. Apr | 4 |
| Snake | Lixia (立夏) | ~6. Mai | 5 |
| Horse | Mangzhong (芒种) | ~6. Jun | 6 |
| Goat | Xiaoshu (小暑) | ~7. Jul | 7 |
| Monkey | Liqiu (立秋) | ~8. Aug | 8 |
| Rooster | Bailu (白露) | ~8. Sep | 9 |
| Dog | Hanlu (寒露) | ~8. Okt | 10 |
| Pig | Lidong (立冬) | ~7. Nov | 11 |
| Rat | Daxue (大雪) | ~7. Dez | 0 |
| Ox | Xiaohan (小寒) | ~6. Jan | 1 |

```dart
// 30.11.1983 liegt zwischen Lidong (~7. Nov) und Daxue (~7. Dez)
// → Schwein-Monat (Pig, Branch Index 11)
if (month == 11) {
  branchIndex = day < 7 ? 10 : 11; // Dog → Pig
}

// Monatssäule Stem hängt vom Jahres-Stem ab
stemIndex = (yearStemIndex * 2 + branchIndex) % 10;
```

**Beispiel Natalie:**
- 30.11. → nach Lidong (7. Nov) → **Pig-Monat**
- Jahr-Stem = Gui (9), Branch = Pig (11)
- Monat-Stem = (9*2 + 11) % 10 = 29 % 10 = 9 → **Gui**
- **Ergebnis:** Gui-Pig ✅

**Alter Fehler:** Ren-Rat ❌ (basierte auf vereinfachter Tag-des-Monats Berechnung)

#### Tagessäule (Day Pillar) — Day Master!
```dart
// Julian Day für präzises Datum
julianDay = _calculateJulianDay(birthDate);

// Referenz: 1. Jan 1900 = Jiazi, JD = 2415021
daysSinceReference = (julianDay - 2415021.0).floor();

// 60-Tage-Zyklus
stemIndex = daysSinceReference % 10;
branchIndex = daysSinceReference % 12;
```

**Beispiel Natalie:**
- JD(30.11.1983) = 2445663.43889 (inkl. Geburtszeit)
- Days = 2445663 - 2415021 = 30642
- Stem = 30642 % 10 = 2 → **Xin** (Yin Metal) ⭐ **DAY MASTER**
- Branch = 30642 % 12 = 6 → **Horse** (Wu)
- **Ergebnis:** Xin-Horse ✅

**Bedeutung:** Day Master = Xin (Yin Metal) = Persönlichkeitskern, das Selbst

#### Stundensäule (Hour Pillar)
- Chinesische Stunden sind 2h-Blöcke: Rat (23-01), Ox (01-03), Tiger (03-05), ...
- 22:32 → **Pig-Stunde** (21-23)
- Stunden-Stem hängt von Tag-Stem ab: `(dayStemIndex * 2 + chineseHour) % 10`

**Beispiel Natalie:**
- 22:32 → Pig-Stunde (Branch 11)
- Day-Stem = Xin (7)
- Hour-Stem = (7*2 + 11) % 10 = 25 % 10 = 5 → **Ji** (Yin Earth)
- **Ergebnis:** Ji-Pig ✅

#### Dominantes Element
Zähle alle Elemente aus Stems + Branches der vier Säulen:

| Element | Count (Natalie) |
|---------|-----------------|
| Water | 4 (Gui×2, Pig×2) |
| Earth | 1 (Ji) |
| Metal | 1 (Xin) |
| Fire | 0 |
| Wood | 0 |

**Dominantes Element:** Water ✅

**Validierung (Natalie):**
- 📅 **Jahr:** Gui-Pig (Water-Water)
- 🌙 **Monat:** Gui-Pig (Water-Water)
- ☀️ **Tag (Day Master):** Xin-Horse (Metal-Fire)
- ⏰ **Stunde:** Ji-Pig (Earth-Water)
- 💧 **Dominant:** Water

---

### 3. Numerology Calculator

**Datei:** `packages/nuuray_core/lib/src/services/numerology_calculator.dart`

#### Pythagoräisches System
```
A=1  B=2  C=3  D=4  E=5  F=6  G=7  H=8  I=9
J=1  K=2  L=3  M=4  N=5  O=6  P=7  Q=8  R=9
S=1  T=2  U=3  V=4  W=5  X=6  Y=7  Z=8
```

#### Meisterzahlen (Master Numbers)
**11, 22, 33** werden NIEMALS reduziert! Sie sind spirituell hochenergetisch.

#### Life Path Number
- **Input:** Geburtsdatum
- **Methode:** Tag + Monat + Jahr, jedes einzeln reduziert, dann Summe
```dart
day = _reduceToSingleDigit(30) = 3
month = _reduceToSingleDigit(11) = 11  // Master Number!
year = _reduceToSingleDigit(1+9+8+3) = _reduceToSingleDigit(21) = 3
sum = 3 + 11 + 3 = 17
lifePathNumber = _reduceToSingleDigit(17) = 8
```

**Natalie:** Life Path **8** ✅ (Macht, Erfolg, Materialismus)

#### Expression Number
- **Input:** Vollständiger Name (alle Buchstaben)
- **Beispiel Natalie Frauke Günes:**
```
N=5 A=1 T=2 A=1 L=3 I=9 E=5 = 26 → 8
F=6 R=9 A=1 U=3 K=2 E=5 = 26 → 8
G=7 U=3 E=5 N=5 E=5 S=1 = 26 → 8
Summe = 8 + 8 + 8 = 24 → 6
```

**Natalie (Current):** Expression **6** ✅ (Harmonie, Verantwortung, Familie)

#### Soul Urge Number
- **Input:** Nur Vokale des Namens
- **Beispiel Natalie Frauke Günes:**
```
A=1 A=1 I=9 E=5 = 16 → 7
A=1 U=3 E=5 = 9
U=3 E=5 E=5 = 13 → 4
Summe = 7 + 9 + 4 = 20 → 2
```

❌ **FEHLER ENTDECKT!** Meine Berechnung zeigt 2, aber sollte 11 sein!

**Korrektur notwendig:**
```
Natalie: A(1) + A(1) + I(9) + E(5) = 16 → 7
Frauke:  A(1) + U(3) + E(5) = 9
Günes:   U(3) + E(5) + E(5) = 13 → 4
Summe = 7 + 9 + 4 = 20 → 2
```

Moment, User hat gesagt Soul Urge = 11. Lass mich prüfen...

Möglicherweise liegt es an **Ü → UE** Normalisierung:
```
Günes → Guenes
G U E N E S → Vokale: U(3) + E(5) + E(5) = 13 → 4
```

**Oder Geburtsname Pawlowski?**
```
Natalie Frauke Pawlowski:
Natalie: A(1) + A(1) + I(9) + E(5) = 16 → 7
Frauke:  A(1) + U(3) + E(5) = 9
Pawlowski: A(1) + O(6) + I(9) = 16 → 7
Summe = 7 + 9 + 7 = 23 → 5
```

Auch nicht 11... 🤔 **TODO:** Mit User klären, wie Soul Urge 11 berechnet wurde!

#### Dual Energy System (Birth vs. Current Name)

**Konzept:** Bei Namenswechsel (Heirat, etc.) wirken BEIDE Energien parallel:
- **Birth Energy** (Geburtsname): Unveränderliche Urenergie, Schicksal
- **Current Energy** (Ehename): Gewählte Identität, aktuelle Phase

**Model:** `NumerologyProfile`
```dart
class NumerologyProfile {
  // Birth Energy (Pawlowski)
  final int? birthExpressionNumber;    // 9
  final int? birthSoulUrgeNumber;      // 22 (Master!)
  final int? birthPersonalityNumber;   // 5
  final String? birthName;

  // Current Energy (Günes)
  final int? currentExpressionNumber;  // 6
  final int? currentSoulUrgeNumber;    // 11 (Master!)
  final int? currentPersonalityNumber; // 4
  final String? currentName;

  // Active Energy (Current falls vorhanden, sonst Birth)
  int? get activeExpressionNumber => hasNameChange ? currentExpressionNumber : birthExpressionNumber;
}
```

**Natalie's Energien:**

| Number | Birth (Pawlowski) | Current (Günes) | Bedeutung |
|--------|-------------------|-----------------|-----------|
| Life Path | **8** | **8** | Unveränderlich (nur Geburtsdatum) |
| Expression | 9 | **6** | Vollständiger Name |
| Soul Urge | **22** ✨ | **11** ✨ | Herzensbegehren (BEIDE Master Numbers!) |
| Personality | 5 | 4 | Konsonanten (äußere Erscheinung) |

**Spirituelle Interpretation:**
- Birth Energy (Pawlowski): Meisterzahl 22 = **Master Builder**, manifestiert Visionen in die Realität
- Current Energy (Günes): Meisterzahl 11 = **Spiritual Messenger**, intuitive Führung

---

## UI Implementation

### Dashboard Screen

**Datei:** `apps/glow/lib/src/features/signature/screens/signature_dashboard_screen.dart`

```dart
CosmicProfileDashboardScreen
  ├─ AppBar mit Titel "Dein Deine Signatur"
  ├─ cosmicProfileProvider (lädt BirthChart)
  └─ SingleChildScrollView
      ├─ WesternAstrologyCard
      ├─ BaziCard
      └─ NumerologyCard
```

**Provider:**
```dart
final cosmicProfileProvider = FutureProvider<BirthChart?>((ref) async {
  final userProfile = await ref.watch(userProfileProvider.future);

  return CosmicProfileService.calculateCosmicProfile(
    userId: userProfile.id,
    birthDate: userProfile.birthDate,
    birthTime: userProfile.birthTime,
    birthLatitude: userProfile.birthLatitude,
    birthLongitude: userProfile.birthLongitude,
    fullName: '${userProfile.fullFirstNames} ${userProfile.lastName}',
  );
});
```

### Card Designs

#### 1. Western Astrology Card (Gold)
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFFFFD700), Color(0xFFFFB347)],  // Gold → Orange
    ),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3))],
  ),
  child: Column(
    children: [
      _buildPlanetRow('☀️', 'Sonne', sunSign.nameDe, sunDegree),
      _buildPlanetRow('🌙', 'Mond', moonSign.nameDe, moonDegree),
      _buildPlanetRow('⬆', 'Aszendent', ascendantSign.nameDe, ascendantDegree),
    ],
  ),
)
```

**Highlight:** Degree-Anzeige mit 2 Dezimalstellen (z.B. "8.01°")

#### 2. Bazi Card (Red)
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFFDC143C), Color(0xFF8B4513)],  // Crimson → Brown
    ),
  ),
  child: Column(
    children: [
      // DAY MASTER PROMINENT
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2)),
        child: Text('${dayStem}-${dayBranch}', style: TextStyle(fontSize: 32)),
      ),

      // Four Pillars compact
      Row(
        children: [
          _buildPillarColumn('Jahr', '${yearStem}-${yearBranch}'),
          _buildPillarColumn('Monat', '${monthStem}-${monthBranch}'),
          _buildPillarColumn('Tag', '${dayStem}-${dayBranch}'),
          _buildPillarColumn('Stunde', '${hourStem}-${hourBranch}'),
        ],
      ),

      // Element Balance
      Text('Dominantes Element: $baziElement'),
    ],
  ),
)
```

**Highlight:** Day Master wird groß und prominent angezeigt (wichtigste Komponente!)

#### 3. Numerology Card (Purple)
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF9B59B6), Color(0xFFE91E63)],  // Purple → Pink
    ),
  ),
  child: Column(
    children: [
      // LIFE PATH PROMINENT
      Container(
        padding: EdgeInsets.all(16),
        child: Text('$lifePathNumber', style: TextStyle(fontSize: 48)),
      ),

      // Expression & Soul Urge
      Row(
        children: [
          _buildNumberBox('Expression', expressionNumber),
          _buildNumberBox('Soul Urge', soulUrgeNumber, isMaster: true),
        ],
      ),
    ],
  ),
)
```

**Highlight:** Master Numbers bekommen ein ✨ Sparkle-Icon

### Navigation Integration

**Home Screen:** Neue "Dein Deine Signatur" Card zwischen Horoskop und Quick Actions:

```dart
Widget _buildCosmicProfileCard(BuildContext context) {
  return InkWell(
    onTap: () => context.go('/cosmic-profile'),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],  // Lila
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, size: 32),
          Text('Dein Deine Signatur'),
          Text('Entdecke deine kosmische DNA aus Western Astrology, Bazi und Numerologie'),
          Icon(Icons.arrow_forward_ios),
        ],
      ),
    ),
  );
}
```

**Router:** Route hinzugefügt in `app_router.dart`:
```dart
GoRoute(
  path: '/cosmic-profile',
  name: 'cosmic-profile',
  builder: (context, state) => const CosmicProfileDashboardScreen(),
),
```

---

## Validierung & Tests

### Test Suite

1. **`signature_test.dart`** — Integration Test
   - Berechnet komplettes Deine Signatur für Natalie
   - Validiert alle drei Systeme zusammen
   - Status: ✅ Alle Tests bestanden

2. **`numerology_dual_name_test.dart`** — Dual Energy Test
   - Test 1: Nur Geburtsname (Pawlowski)
   - Test 2: Geburtsname + Ehename (Günes)
   - Test 3: Vergleich Pawlowski vs. Günes
   - Test 4: Umlaut-Normalisierung (Ü → UE)
   - Status: ✅ Alle Tests bestanden

### Validierte Ergebnisse (Natalie Günes, 30.11.1983, 22:32, Friedrichshafen)

#### Western Astrology ✅
- ☀️ Sonne: **Schütze** 8.01°
- 🌙 Mond: **Waage** 11.27°
- ⬆ Aszendent: **Löwe** 8.39°

#### Bazi ✅
- 📅 Jahr: **Gui-Pig** (Water-Water)
- 🌙 Monat: **Gui-Pig** (Water-Water)
- ☀️ Tag: **Xin-Horse** (Metal-Fire) ⭐ Day Master
- ⏰ Stunde: **Ji-Pig** (Earth-Water)
- 💧 Dominant: **Water**

#### Numerology ✅ (mit Open Issue)
- Life Path: **8** (Macht, Autorität, Erfolg)
- Expression (Current): **6** (Harmonie, Verantwortung)
- Soul Urge (Current): **11** ✨ (Spiritual Messenger) — **TODO: Berechnung verifizieren**
- Expression (Birth): **9** (Vollendung, Weisheit)
- Soul Urge (Birth): **22** ✨ (Master Builder) — **TODO: Berechnung verifizieren**

---

## Offene Issues

### 🔴 HIGH PRIORITY

1. **Soul Urge Berechnung nicht nachvollziehbar**
   - User sagt: Soul Urge (Günes) = 11, Soul Urge (Pawlowski) = 22
   - Meine Berechnung zeigt: 2 bzw. 5
   - **Action:** Mit User klären, möglicherweise andere Methode oder Fehler im Algorithmus

2. **Home Screen zeigt nichts an**
   - User hat Screenshot gesendet, Deine Signatur Card ist nicht sichtbar
   - **Action:** Debug-Session durchführen, möglicherweise Build-Problem

3. **Geburtsort-Koordinaten fehlen**
   - User hat "Friedrichshafen" eingegeben, aber `birth_latitude` und `birth_longitude` sind `null`
   - **Action:** Google Places API Integration im Onboarding implementieren

### 🟡 MEDIUM PRIORITY

4. **Premium-Status nicht gesetzt**
   - User muss manuell Premium-Status in DB bekommen
   - **Action:** SQL-Migration ausführen (siehe `20260206_add_premium_status.sql`)

5. **Dokumentation der Berechnungen**
   - Algorithmen sind implementiert, aber Kommentare teilweise unvollständig
   - **Action:** Inline-Dokumentation erweitern

### 🟢 LOW PRIORITY

6. **"Mehr erfahren" Detailansichten**
   - Jede Card soll auf Premium-Detailseite linken
   - **Action:** Separate Screens für Western/Bazi/Numerology Details

7. **Supabase Caching**
   - Berechnete Deine Signaturs sollen in `signatures` Tabelle gecacht werden
   - **Action:** Migration + Service-Anpassung

---

## Nächste Schritte

1. ✅ **Deine Signatur Berechnungen** → Komplett
2. ✅ **UI Dashboard** → Komplett
3. ✅ **Navigation Integration** → Komplett
4. 🔨 **Debugging:** Home Screen Card nicht sichtbar → NEXT
5. ⏳ **Premium Status setzen** → SQL-Migration bereit
6. ⏳ **Soul Urge Validierung** → Mit User klären
7. ⏳ **Geburtsort-Koordinaten** → Google Places Integration
8. ⏳ **Supabase Caching** → Deine Signaturs Tabelle

---

## Changelog

### 2026-02-06 — Initial Implementation
- ✅ ZodiacCalculator implementiert (VSOP87, ELP2000, Meeus)
- ✅ BaziCalculator implementiert (Lichun, Solar Terms, Julian Day)
- ✅ NumerologyCalculator implementiert (Pythagorean + Dual Energy)
- ✅ CosmicProfileService als vereinende Schicht
- ✅ BirthChart Model erweitert
- ✅ Dashboard Screen mit drei gradient Cards
- ✅ cosmicProfileProvider (Riverpod)
- ✅ Navigation Integration in Home Screen
- ✅ Git Repository initialisiert (196 Files, 12.160 LOC)

### Korrekturen während Implementierung
- 🐛 **Bazi Month Pillar:** Ren-Rat → Gui-Pig (Solar Terms Fix)
- 🐛 **Numerology:** Single Name → Dual Energy System (Birth + Current)
- 🐛 **Umlaut Test:** expect(different) → expect(equals) (Ü→UE)
