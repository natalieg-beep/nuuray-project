# NUURAY — Dashboard Mini-Widgets (Spezifikation)

> Ergänzung zum ARCHETYP_SYSTEM.md. Beschreibt die drei Mini-Widgets 
> unterhalb des Archetyps auf dem Glow Home Screen.

---

## Übersicht

Unter dem Archetyp-Header ("Die intuitive Strategin" + Signatur-Satz) werden 
drei gleichgroße, tappbare Karten in einer Row angezeigt. Jede Karte repräsentiert 
eines der drei Systeme.

```
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│    Karte 1       │  │    Karte 2       │  │    Karte 3       │
│    Western       │  │    Chinesisch    │  │    Numerologie   │
└──────────────────┘  └──────────────────┘  └──────────────────┘
```

Alle drei Karten sind tappbar und navigieren zur jeweiligen Detail-Seite 
(die "Deine Signatur"-Seite, die bereits existiert).

---

## Karte 1: Western Astrology

### Datenquellen
Alle Werte kommen aus dem bereits berechneten BirthChart-Objekt.

### Anzeige

```
[Sternzeichen-Icon]

SCHÜTZE                    ← Sonnenzeichen (immer vorhanden)

Mond: Waage                ← Mondzeichen (nur wenn Geburtszeit vorhanden)
Aszendent: Löwe            ← Aszendent (nur wenn Geburtszeit + -ort vorhanden)

Element: Feuer             ← Element des SONNENZEICHENS (nicht berechnet, 
                              einfaches Mapping: Widder/Löwe/Schütze → Feuer, 
                              Stier/Jungfrau/Steinbock → Erde, etc.)
```

### Regeln
- Sonnenzeichen ist IMMER vorhanden (braucht nur Geburtsdatum).
- Mondzeichen und Aszendent können null sein. Wenn null → Zeile weglassen, 
  nicht "Unbekannt" anzeigen.
- Element = Sonnenzeichen-Element. Festes Mapping, keine Berechnung:
  - Feuer: Widder, Löwe, Schütze
  - Erde: Stier, Jungfrau, Steinbock
  - Luft: Zwillinge, Waage, Wassermann
  - Wasser: Krebs, Skorpion, Fische
- KEIN "dominantes Element" berechnen. Einfach das Element des Sonnenzeichens zeigen.

---

## Karte 2: Chinesische Astrologie (Bazi)

### Datenquellen
Alle Werte kommen aus dem BirthChart-Objekt (Bazi-Berechnung).

### Anzeige

```
[Tierzeichen-Icon oder Element-Icon]

CHINESISCH

Gui · Yin-Wasser           ← Day Master: Heavenly Stem des Tages
                              Format: "[Stem-Name] · [Polarität]-[Element]"
                              
Element: Metall             ← Dominantes Element (aus allen 4 Säulen berechnet,
                              bereits im BirthChart vorhanden)
                              
Tier: Schlange              ← Jahrestier (Earthly Branch des JAHRES,
                              das chinesische Tierkreiszeichen)
```

### Wichtig: Day Master ≠ Dominantes Element
Diese zwei Werte können unterschiedlich sein. Das ist korrekt und kein Bug.
- **Day Master** beschreibt die Kern-Persönlichkeit (z.B. Gui = Yin-Wasser)
- **Dominantes Element** beschreibt die vorherrschende Energie im Gesamtchart 
  (z.B. Metall, weil es in mehreren Säulen vorkommt)
- Beide anzeigen, weil sie verschiedene Aussagen machen.

### Die 10 Day Master (Heavenly Stems)
Für die Anzeige muss der Stem-Name + Element + Polarität gemappt werden:

| Stem | Name | Polarität | Element | Anzeige-Format |
|------|------|-----------|---------|----------------|
| 甲 | Jia | Yang | Holz | Jia · Yang-Holz |
| 乙 | Yi | Yin | Holz | Yi · Yin-Holz |
| 丙 | Bing | Yang | Feuer | Bing · Yang-Feuer |
| 丁 | Ding | Yin | Feuer | Ding · Yin-Feuer |
| 戊 | Wu | Yang | Erde | Wu · Yang-Erde |
| 己 | Ji | Yin | Erde | Ji · Yin-Erde |
| 庚 | Geng | Yang | Metall | Geng · Yang-Metall |
| 辛 | Xin | Yin | Metall | Xin · Yin-Metall |
| 壬 | Ren | Yang | Wasser | Ren · Yang-Wasser |
| 癸 | Gui | Yin | Wasser | Gui · Yin-Wasser |

### Die 12 Jahrestiere
Das Jahrestier kommt aus dem Earthly Branch des Geburtsjahres. 
Wichtig: Der chinesische Jahreswechsel liegt NICHT am 1. Januar, 
sondern am Lichun (立春, meist 3.–5. Februar). Das ist bereits 
in der Bazi-Engine berücksichtigt.

| Branch | Tier (DE) | Tier (EN) |
|--------|-----------|-----------|
| 子 | Ratte | Rat |
| 丑 | Büffel | Ox |
| 寅 | Tiger | Tiger |
| 卯 | Hase | Rabbit |
| 辰 | Drache | Dragon |
| 巳 | Schlange | Snake |
| 午 | Pferd | Horse |
| 未 | Ziege | Goat |
| 申 | Affe | Monkey |
| 酉 | Hahn | Rooster |
| 戌 | Hund | Dog |
| 亥 | Schwein | Pig |

### Regeln
- Day Master ist IMMER vorhanden (braucht nur Geburtsdatum).
- Dominantes Element ist IMMER vorhanden.
- Jahrestier ist IMMER vorhanden.
- Alle Werte existieren bereits im BirthChart, kein neuer Berechnungscode nötig.

---

## Karte 3: Numerologie

### Datenquellen
Lebenszahl aus BirthChart. Namenszahl wird aus dem Rufnamen berechnet 
(Rufname = Username, ist Pflichtfeld im Onboarding).

### Anzeige

```
[Zahl als großes Zeichen oder abstraktes Icon]

NUMEROLOGIE

Lebenszahl: 8              ← Life Path Number (aus Geburtsdatum)
Namenszahl: 8              ← Expression Number (aus Rufname)

Erfolg · Manifestation     ← Keywords zur Lebenszahl (hardcoded Mapping)
```

### Keywords pro Lebenszahl
Hardcoded, i18n-fähig, 2-3 kurze Wörter:

| Lebenszahl | Keywords (DE) | Keywords (EN) |
|-----------|---------------|---------------|
| 1 | Mut · Neuanfang | Courage · New Beginnings |
| 2 | Harmonie · Empathie | Harmony · Empathy |
| 3 | Ausdruck · Freude | Expression · Joy |
| 4 | Struktur · Aufbau | Structure · Building |
| 5 | Freiheit · Wandel | Freedom · Change |
| 6 | Fürsorge · Heilung | Nurture · Healing |
| 7 | Tiefe · Spiritualität | Depth · Spirituality |
| 8 | Erfolg · Manifestation | Success · Manifestation |
| 9 | Weisheit · Mitgefühl | Wisdom · Compassion |
| 11 | Intuition · Vision | Intuition · Vision |
| 22 | Meisterschaft · Aufbau | Mastery · Building |
| 33 | Liebe · Heilung | Love · Healing |

### Namenszahl-Berechnung
Die Namenszahl (Expression Number) wird aus dem Rufnamen berechnet.
Der Rufname ist das Pflicht-Username-Feld aus dem Onboarding.

Berechnung: Jeder Buchstabe → Zahlenwert (Pythagoräisches System) → Quersumme.

| A=1 | B=2 | C=3 | D=4 | E=5 | F=6 | G=7 | H=8 | I=9 |
| J=1 | K=2 | L=3 | M=4 | N=5 | O=6 | P=7 | Q=8 | R=9 |
| S=1 | T=2 | U=3 | V=4 | W=5 | X=6 | Y=7 | Z=8 |     |

Meisterzahlen (11, 22, 33) auch hier NICHT weiter reduzieren.

Beispiel: NATALIE → 5+1+2+1+3+9+5 = 26 → 2+6 = 8

### Regeln
- Lebenszahl ist IMMER vorhanden.
- Namenszahl ist IMMER vorhanden (Rufname ist Pflicht).
- Wenn Lebenszahl und Namenszahl gleich sind (wie bei Natalie: 8 · 8),
  ist das eine besondere Konstellation. Für den MVP keine Sonderbehandlung,
  aber als TODO für später notieren.
- Keywords kommen aus der Lebenszahl, NICHT aus der Namenszahl.

---

## Onboarding-Hinweis: Namenszahl

Im Onboarding, beim Schritt wo der Rufname eingegeben wird, soll ein kurzer 
Hinweistext erscheinen, der erklärt, dass der Name für die Numerologie-Berechnung 
verwendet wird:

> "Dein Rufname verrät viel über deine Energie. In der Numerologie hat jeder 
>  Buchstabe einen Zahlenwert — daraus berechnen wir deine persönliche Namenszahl."

Dieser Text gehört in die i18n-Dateien (DE + EN).

---

## Beispiele (3 verschiedene Nutzerinnen)

### Natalie (Geburtsdatum: 3. Dezember 1983)
```
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│  ♐ SCHÜTZE       │  │  CHINESISCH      │  │  NUMEROLOGIE     │
│                  │  │                  │  │                  │
│  Mond: Waage     │  │  Xin · Yin-Metall│  │  Lebenszahl: 8   │
│  Aszendent: Löwe │  │  Element: Wasser  │  │  Namenszahl: 8   │
│  Element: Feuer  │  │  Tier: Schwein    │  │                  │
│                  │  │                  │  │  Erfolg ·        │
│                  │  │                  │  │  Manifestation   │
└──────────────────┘  └──────────────────┘  └──────────────────┘
  Archetyp: Die feine Strategin
```

### Lisa (Geburtsdatum: 15. März 1990, keine Geburtszeit)
```
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│  ♓ FISCHE        │  │  CHINESISCH      │  │  NUMEROLOGIE     │
│                  │  │                  │  │                  │
│                  │  │  Bing · Yang-Feuer│  │  Lebenszahl: 1   │
│  Element: Wasser │  │  Element: Holz    │  │  Namenszahl: 6   │
│                  │  │  Tier: Pferd      │  │                  │
│                  │  │                  │  │  Mut ·           │
│                  │  │                  │  │  Neuanfang       │
└──────────────────┘  └──────────────────┘  └──────────────────┘
  Archetyp: Die strahlende Pionierin
  (Kein Mond/Aszendent weil keine Geburtszeit)
```

### Elif (Geburtsdatum: 22. Oktober 2001, mit Geburtszeit)
```
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│  ♎ WAAGE         │  │  CHINESISCH      │  │  NUMEROLOGIE     │
│                  │  │                  │  │                  │
│  Mond: Skorpion  │  │  Gui · Yin-Wasser│  │  Lebenszahl: 7   │
│  Aszendent: Krebs│  │  Element: Metall  │  │  Namenszahl: 22  │
│  Element: Luft   │  │  Tier: Schlange   │  │                  │
│                  │  │                  │  │  Tiefe ·         │
│                  │  │                  │  │  Spiritualität   │
└──────────────────┘  └──────────────────┘  └──────────────────┘
  Archetyp: Die intuitive Sucherin
  (Namenszahl 22 = Meisterzahl, nicht reduziert)
```

---

## Zusammenfassung für die Implementierung

1. **Keine neuen Berechnungen nötig** — alle Werte existieren bereits im BirthChart.
2. **Neue Mappings nötig** (alle in nuuray_core, alle in i18n):
   - Sonnenzeichen → Element (4 Gruppen, trivial)
   - Day Master → Anzeige-Format "Name · Polarität-Element"
   - Jahres-Branch → Tiername
   - Lebenszahl → Keywords
3. **Namenszahl-Berechnung** ist neu (Pythagoräisches System aus Rufname). 
   Gehört in nuuray_core. Einfache Quersumme mit Meisterzahl-Schutz.
4. **Onboarding-Hinweis** für Namenszahl in i18n ergänzen.
5. **UI:** Drei gleichgroße Cards in einer Row, jede tappbar → Detail-Seite.
