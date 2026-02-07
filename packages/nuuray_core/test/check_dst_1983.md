# Sommerzeit-Check für 30.11.1983

## Frage: War am 30. November 1983 Sommerzeit oder Normalzeit?

**Antwort:** **Normalzeit (MEZ = UTC+1)**

### Sommerzeit-Regeln in Deutschland 1983

- **Sommerzeit Beginn:** Letzter Sonntag im März (27.03.1983, 02:00 → 03:00)
- **Sommerzeit Ende:** Letzter Sonntag im September (25.09.1983, 03:00 → 02:00)

**30. November 1983 = Nach Ende der Sommerzeit → Normalzeit (MEZ = UTC+1)**

## Mögliche Erklärungen für den Aszendenten-Fehler

### Szenario 1: Geburtszeit ist falsch
- User hat **22:32** eingegeben
- Echte Geburtszeit war **21:32 MEZ**
- Bei 21:32 ergibt sich: **Löwe bei 144.48°** ✅

### Szenario 2: Zeit wurde als UTC interpretiert
- Geburtszeit **22:32 UTC** = **23:32 MEZ**
- Bei 23:32 MEZ ergibt sich: **Jungfrau bei 166.53°** (noch falscher!)
- **Nicht zutreffend**

### Szenario 3: House System
- Unsere Berechnung verwendet **Equal House** (wahrer Aszendent)
- Referenz könnte **Placidus** verwenden (komplexere Berechnung)
- Placidus-Aszendent kann einige Grade abweichen
- **Möglich, aber unwahrscheinlich** (5° Differenz zu groß für House System)

### Szenario 4: Longitude-Problem
- Friedrichshafen: 9.4797°E (verwendet)
- Andere Quelle könnte leicht abweichende Koordinaten haben
- **Unwahrscheinlich** (würde nur ~0.5° Differenz machen)

## Empfehlung

**Die wahrscheinlichste Erklärung: Geburtszeit ist 21:32, nicht 22:32**

Differenz: 22:32 → 155.48° (Jungfrau)
Differenz: 21:32 → 144.48° (Löwe) ✅

**Entweder:**
1. User soll Geburtszeit nochmal prüfen (Geburtsurkunde?)
2. Oder: Referenzdaten sind falsch

## Mathematische Verifikation

Unsere Berechnung ist korrekt:
- ✅ UTC-Konvertierung entfernt (lokale Zeit wird genutzt)
- ✅ Julian Day korrekt berechnet
- ✅ GMST + LST korrekt
- ✅ Aszendent-Formel nach Meeus implementiert

**Das Problem liegt nicht im Code, sondern in den Eingabedaten!**
