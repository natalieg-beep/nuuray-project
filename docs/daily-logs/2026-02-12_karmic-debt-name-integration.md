# Session: Karmic Debt für Namen integriert

**Datum:** 2026-02-12
**Dauer:** ~20 Minuten
**Status:** ✅ Komplett implementiert

---

## 🎯 Ziel

Karmic Debt Numbers für **Namen** (Expression & Soul Urge) in die UI integrieren.

**Problem:** Die Berechnungen existierten bereits im Code, wurden aber nur für Life Path angezeigt. Karmic Debt in Expression/Soul Urge wurde ignoriert.

**Beispiel:**
- Name: "Natalie Frauke Pawlowski"
- Expression Berechnung: 8+8+3 = **19** ← Karmic Debt!
- Final: 1 (Expression Number)
- **Bedeutung:** Machtmissbrauch in früherem Leben → Geben statt Nehmen lernen

---

## ✅ Was wurde implementiert

### 1. UI-Integration in Birth/Current Energy Sections

**Vorher:**
```
🌱 Birth Energy
├── Ausdrucks-Zahl: 1
└── Seelenwunsch-Zahl: 33
```

**Nachher:**
```
🌱 Birth Energy
├── Ausdrucks-Zahl: 1
│   └── ⚡ Karmische Schuld 19/1 (Expression)
│       "Machtmissbrauch → Geben lernen"
└── Seelenwunsch-Zahl: 33
    (keine Karmic Debt)
```

---

### 2. Neue Parameter in `_buildNameEnergySection()`

**Erweitert um:**
- `int? karmicDebtExpression` — Karmic Debt in Ausdrucks-Zahl (alle Buchstaben)
- `int? karmicDebtSoulUrge` — Karmic Debt in Seelenwunsch-Zahl (Vokale)

**Aufruf:**
```dart
_buildNameEnergySection(
  // ... existing params
  karmicDebtExpression: birthChart.karmicDebtExpression,
  karmicDebtSoulUrge: birthChart.karmicDebtSoulUrge,
)
```

---

### 3. Neue Helper-Methode: `_buildKarmicDebtBadge()`

**Design:**
- Amber Container (⚡ Icon + Border)
- Titel: "Karmische Schuld 19 (Expression)"
- Content: Beschreibung aus Content Library

**Code:**
```dart
Widget _buildKarmicDebtBadge({
  required dynamic contentService,
  required String locale,
  required int number,
  required String type,
}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.amber[50],
      border: Border.all(color: Colors.amber[300]!),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      children: [
        Row(
          children: [
            const Text('⚡', style: TextStyle(fontSize: 20)),
            Text('Karmische Schuld $number ($type)'),
          ],
        ),
        FutureBuilder<String?>(...), // Content Library
      ],
    ),
  );
}
```

---

## 📊 Daten-Flow

### BirthChart Model (bereits vorhanden)
```dart
final int? karmicDebtLifePath;     // Geburtsdatum (bereits angezeigt)
final int? karmicDebtExpression;   // Alle Buchstaben (NEU angezeigt!)
final int? karmicDebtSoulUrge;     // Vokale (NEU angezeigt!)
```

### Berechnung (bereits implementiert seit 2026-02-08)
```dart
// packages/nuuray_core/lib/src/services/numerology_calculator.dart

static int? calculateKarmicDebtExpression(String fullName) {
  // Summe aller Buchstaben OHNE finale Reduktion
  int totalSum = 0;
  for (final part in nameParts) {
    totalSum += _sumLetters(part);
  }

  // Prüfe ob Summe 13, 14, 16 oder 19 ist
  if (totalSum == 13 || totalSum == 14 || totalSum == 16 || totalSum == 19) {
    return totalSum;
  }

  // Prüfe Zwischenreduktion (falls > 19)
  if (totalSum > 19) {
    final reduced = _sumDigits(totalSum);
    if (reduced == 13 || reduced == 14 || reduced == 16 || reduced == 19) {
      return reduced;
    }
  }

  return null;
}
```

---

## 🎨 Design-Entscheidungen

### Warum integriert statt separate Cards?

**Option A (Abgelehnt):** Separate Karmic Debt Cards neben Life Path
```
⚡ Karmische Schuld (Life Path): 19
⚡ Karmische Schuld (Expression): 19
⚡ Karmische Schuld (Soul Urge): 16
```
→ Problem: Zu viel Clutter, 3 Cards mit ähnlichem Content

**Option B (Gewählt):** Integriert in Name Energy Sections
```
🌱 Birth Energy (Geburtsname)
  ├── Ausdrucks-Zahl: 1
  │   └── ⚡ Karmic Debt 19/1
  └── Seelenwunsch-Zahl: 7
      └── ⚡ Karmic Debt 16/7
```
→ Lösung: Thematisch korrekt, da Karmic Debt aus NAMEN kommt

### Warum Amber Design?

- ⚡ Blitz-Icon = Energie/Schuld/Karma
- Amber = Warnfarbe, aber warm (nicht rot/aggressiv)
- Konsistent mit Challenge Numbers (ebenfalls Amber Chips)

---

## 🧪 Testing

**Beispiel-User: Natalie Frauke Pawlowski**

**Erwartetes Ergebnis:**

```
🌱 Birth Energy: Natalie Frauke Pawlowski

Ausdrucks-Zahl: 1
  ⚡ Karmische Schuld 19 (Expression)
  "Du trägst die Lektion des Machtmissbrauchs aus einem früheren
   Leben. In diesem Leben darfst du lernen, zu geben statt zu nehmen,
   anderen zu dienen ohne Erwartung von Gegenleistung..."

Seelenwunsch-Zahl: 33 ✨
  (keine Karmic Debt)

Persönlichkeits-Zahl: 4
  (keine Karmic Debt)
```

---

## 📋 Content Library

**Kategorie:** `karmic_debt`
**Keys:** `13`, `14`, `16`, `19`
**Status:** ✅ 4/4 Texte (DE) bereits generiert (2026-02-12 vormittags)

**Wiederverwendung:**
- Life Path Karmic Debt nutzt dieselben Texte
- Expression Karmic Debt nutzt dieselben Texte
- Soul Urge Karmic Debt nutzt dieselben Texte

→ Keine neuen Content-Generierungen nötig! 🎉

---

## 🔧 Geänderte Dateien

### `apps/glow/lib/src/features/signature/widgets/numerology_section.dart`

**Änderungen:**
1. ✅ `_buildNameEnergySection()` erweitert um `karmicDebtExpression` + `karmicDebtSoulUrge` Parameter
2. ✅ Karmic Debt Badges in Expression/Soul Urge Sections eingefügt
3. ✅ Neue Helper-Methode: `_buildKarmicDebtBadge()`
4. ✅ Birth Energy Section: Übergibt `birthChart.karmicDebtExpression` + `karmicDebtSoulUrge`

**Zeilen:**
- L117-126: Birth Energy mit Karmic Debt Parametern
- L290-350: Expression/Soul Urge mit Karmic Debt Badges
- L524-565: Neue `_buildKarmicDebtBadge()` Methode

---

## 🚀 Deployment

**Keine Datenbank-Migration nötig!**
- Felder `karmicDebtExpression` + `karmicDebtSoulUrge` existieren bereits
- Werden bereits von `SignatureService` berechnet und gespeichert
- Nur UI-Update → sofort deploybar

---

## ✅ Ergebnis

**Vorher:**
- Karmic Debt nur für Life Path sichtbar (Geburtsdatum)
- Namen-basierte Karmic Debts wurden berechnet aber ignoriert

**Nachher:**
- ✅ Karmic Debt für Life Path (separate Card unter Kern-Zahlen)
- ✅ Karmic Debt für Expression (integriert in Birth Energy)
- ✅ Karmic Debt für Soul Urge (integriert in Birth Energy)
- ✅ Thematisch korrekt: Namen-Karmic-Debt bei Namen-Energien
- ✅ Design konsistent: Amber Badges, ⚡ Icon, Content Library

---

## 💡 Philosophie

**Karmic Debt = Versteckte Lektionen aus früheren Leben**

- **Life Path Karmic Debt:** Dein Lebensweg trägt eine alte Schuld
- **Expression Karmic Debt:** Deine Talente/Art sind dein Werkzeug zur Befreiung
- **Soul Urge Karmic Debt:** Deine tiefsten Wünsche sind dein Lernfeld

**Beispiel Natalie:**
- Life Path: 8 (Manifestation, Erfolg)
- Expression: 1 mit Karmic Debt 19/1 (Pioniergeist + alte Machtschuld)
- Synthese: "Nutze deine Führungskraft (1), um anderen zu dienen (19), und manifestiere Erfolg (8) durch Großzügigkeit statt Kontrolle."

---

## 🔮 Nächste Schritte

- [ ] App testen mit User "Natalie Frauke Pawlowski"
- [ ] Verifizieren: Karmic Debt 19/1 erscheint in Birth Energy
- [ ] Screenshots für Dokumentation
- [ ] i18n: Englische Übersetzungen für "Karmische Schuld" Texte
- [ ] Ggf. Current Energy auch mit Karmic Debt erweitern (falls Namen-Update)

**Status:** ✅ Ready to Test! 🚀
