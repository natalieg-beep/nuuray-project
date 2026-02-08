# 🌙 NUURAY GLOW — Vollständige Projektbeschreibung

**App:** Nuuray Glow — Kosmische Unterhaltung
**Tagline:** "Dein persönliches Horoskop aus drei Welten"
**Zielgruppe:** Frauen 20-40, die Horoskope lieben aber Tiefe suchen
**USP:** Einzigartige Synthese aus Westlicher Astrologie + Bazi + Numerologie

---

## 📋 Inhaltsverzeichnis

1. [Das Konzept](#1-das-konzept)
2. [Die drei astrologischen Systeme](#2-die-drei-astrologischen-systeme)
3. [Die Synthese — Wie alles zusammenkommt](#3-die-synthese--wie-alles-zusammenkommt)
4. [Design & User Experience](#4-design--user-experience)
5. [Screen-Architektur](#5-screen-architektur)
6. [Freemium vs Premium](#6-freemium-vs-premium)
7. [Onboarding Journey](#7-onboarding-journey)
8. [Datenbank-Schema](#8-datenbank-schema)
9. [API-Integration](#9-api-integration)
10. [Content-Strategie](#10-content-strategie)
11. [Sprachen & Lokalisierung](#11-sprachen--lokalisierung)
12. [Entwicklungs-Roadmap](#12-entwicklungs-roadmap)

---

## 1. Das Konzept

### Was macht Nuuray Glow anders?

**Problem:** Horoskop-Apps sind entweder...
- Generisch (gleicher Text für Millionen Menschen)
- Oberflächlich (nur Sternzeichen, keine Tiefe)
- Einseitig (nur westliche Astrologie)

**Lösung:** Nuuray Glow vereint **drei Weisheitssysteme**:
1. **Westliche Astrologie** — Persönlichkeitsstruktur (Sonne, Mond, Aszendent)
2. **Bazi (Vier Säulen)** — Energetische Konstitution (Elemente, Day Master)
3. **Numerologie** — Lebensweg und Talente (Lebenszahl, Seelenwunsch)

Diese drei Systeme werden **nicht nebeneinander gestellt**, sondern zu einer **stimmigen Erzählung verwoben**.

### Der Kern-Workflow

```
User gibt Geburtsdaten ein
    ↓
App berechnet "Deine Signatur" (alle 3 Systeme)
    ↓
Claude API generiert personalisierte Texte
    ↓
User erhält täglich:
    ✨ Tageshoroskop (persönlich, nicht generisch)
    🌙 Mondphasen-Energie
    🔮 Wochenausblick (Premium)
    📅 Monatsenergie (Premium)
    🎯 Jahresvorschau (Premium, einmalig)
    💕 Partner-Check (Premium)
```

---

## 2. Die drei astrologischen Systeme

### 2.1 Westliche Astrologie

**Was wird berechnet:**

| Element | Beschreibung | Berechnung |
|---------|--------------|------------|
| **Sonnenzeichen** | Bewusste Persönlichkeit | Aus Geburtsdatum (welches der 12 Zeichen) |
| **Mondzeichen** | Emotionale Natur, Bedürfnisse | Mondposition am Geburtstag (wechselt alle ~2,5 Tage) |
| **Aszendent** | Äußere Erscheinung, erste Reaktion | Erfordert Geburtszeit + Geburtsort (Koordinaten) |

**Alle drei mit Gradzahl** (z.B. "Schütze 8.01°")

#### Technische Implementierung

**Sonnenzeichen:**
```
Geburtsdatum → Tag im Jahr (1-365)
    ↓
Lookup-Tabelle:
    21. März - 19. April → Widder
    20. April - 20. Mai → Stier
    ...
```

**Mondzeichen:**
```
Geburtsdatum + Geburtszeit
    ↓
Berechne Mondposition (Längengrad 0-360°)
    ↓
Teile durch 30° → Welches Zeichen (0° Widder - 360°)
```

**Aszendent:**
```
Geburtszeit + Geburtsort (Lat/Lng)
    ↓
Berechne Julian Day Number
    ↓
Berechne Local Sidereal Time (LST)
    ↓
Berechne Right Ascension of MC (RAMC)
    ↓
Aszendent = arctan(tan(RAMC) / cos(obliquity + latitude))
    ↓
Ergebnis: 0-360° → Zeichen + Grad
```

**Wichtig:** Die Berechnung nutzt astronomische Formeln nach Jean Meeus "Astronomical Algorithms"

**Datenquellen:**
- Sonnenzeichen: Festgelegte Datumsgrenzen
- Mondzeichen: Astronomische Berechnung (Mondposition)
- Aszendent: Astronomische Berechnung (erfordert exakte Zeit + Koordinaten)

#### Was sagen die drei aus?

| Element | Aussage | Beispiel |
|---------|---------|----------|
| **Sonne** | "Wer bin ich im Kern?" | Schütze: Abenteuerlust, Optimismus, Wissensdurst |
| **Mond** | "Was brauche ich emotional?" | Waage: Harmonie, Schönheit, Balance |
| **Aszendent** | "Wie wirke ich auf andere?" | Löwe: Selbstbewusst, strahlend, dramatisch |

---

### 2.2 Bazi (Vier Säulen des Schicksals)

**Was ist Bazi?**

Bazi (八字 bāzì) = "Acht Zeichen" ist ein chinesisches astrologisches System, das die **energetische Konstitution** eines Menschen beschreibt. Es basiert auf dem chinesischen Kalender (nicht dem gregorianischen!).

**Die Vier Säulen:**

Jede Säule besteht aus:
- **Heavenly Stem** (天干 tiāngān) — 10 Elemente (Yang/Yin × 5 Elemente)
- **Earthly Branch** (地支 dìzhī) — 12 Tierkreiszeichen (Ratte, Büffel, Tiger...)

| Säule | Berechnet aus | Aussage | Zeitspanne |
|-------|---------------|---------|------------|
| **Jahr** | Geburtsjahr | Äußere Identität, Herkunft, öffentliches Image | Gesamtes Leben |
| **Monat** | Geburtsmonat | Karriere, Beziehungen, soziales Umfeld | 30-60 Jahre |
| **Tag** | Geburtstag | Kern-Persönlichkeit (**Day Master**) | Gesamtes Leben |
| **Stunde** | Geburtszeit | Innere Welt, spätes Leben, Nachkommen | 60+ Jahre |

#### Die Fünf Elemente

| Element | Yang | Yin | Eigenschaften |
|---------|------|-----|---------------|
| 木 Holz | 甲 Jiǎ | 乙 Yǐ | Wachstum, Kreativität, Flexibilität |
| 火 Feuer | 丙 Bǐng | 丁 Dīng | Leidenschaft, Charisma, Transformation |
| 土 Erde | 戊 Wù | 己 Jǐ | Stabilität, Verlässlichkeit, Pflege |
| 金 Metall | 庚 Gēng | 辛 Xīn | Struktur, Präzision, Gerechtigkeit |
| 水 Wasser | 壬 Rén | 癸 Guǐ | Weisheit, Intuition, Anpassungsfähigkeit |

#### Der Day Master (日主 rìzhǔ)

**Das Wichtigste in Bazi!**

Der **Day Master** ist der Heavenly Stem der Tagessäule. Er repräsentiert die Kern-Persönlichkeit.

**Beispiel:**
- Geburt: 6. Juli 2006
- Tagessäule: 癸亥 (Guǐ Hài)
- Day Master: **癸 (Guǐ)** = Yin-Wasser

**Interpretation:** Person ist wie Nebel oder Tau — sanft, anpassungsfähig, intuitiv, aber auch geheimnisvoll und schwer zu fassen.

#### Element-Balance

Bazi analysiert, welche Elemente **stark** oder **schwach** im Chart sind:

```
Beispiel-Chart:
Jahr:  丙申 (Feuer-Affe)   → Feuer, Metall
Monat: 甲午 (Holz-Pferd)   → Holz, Feuer
Tag:   癸亥 (Wasser-Schwein) → Wasser (Day Master!)
Stunde: 甲寅 (Holz-Tiger)  → Holz

Balance:
🔥 Feuer: 2
🌳 Holz: 3
💧 Wasser: 2
⛰️ Erde: 0 ← FEHLT!
⚙️ Metall: 1
```

**Interpretation:** Diese Person braucht mehr **Erde-Energie** (Stabilität, Erdung) im Leben.

#### Technische Berechnung

**Wichtig:** Der chinesische Kalender beginnt NICHT am 1. Januar!

**Jahr-Wechsel:** 立春 (Lìchūn) = "Beginn des Frühlings" (meist 3.-5. Februar)

**Beispiel:**
- Geboren: 3. Februar 2006 (NACH Lichun 2006)
  → Bazi-Jahr: 2006 (Feuer-Hund)
- Geboren: 2. Februar 2006 (VOR Lichun 2006)
  → Bazi-Jahr: 2005 (Holz-Hahn)

**Berechnung (vereinfacht):**

```
1. Konvertiere Geburtsdatum in chinesischen Kalender
2. Bestimme Jahr-Säule (Lichun-basiert)
3. Bestimme Monat-Säule (Solar Terms basiert)
4. Bestimme Tag-Säule (60-Tage-Zyklus seit 1. Jan 1900)
5. Bestimme Stunden-Säule (2-Stunden-Blöcke)
```

**Datenquelle für Implementierung:**
- Lookup-Tables für 60-Tage-Zyklus (Jiǎzǐ-Zyklus)
- Solar Terms Kalender (24 Jahreszeiten-Marker)
- Zeitzone-Korrektur (Geburtszeit in lokaler Zeit!)

#### Was wird in Nuuray Glow verwendet?

**Kern-Daten:**
1. **Day Master** (Heavenly Stem der Tagessäule) — "Wer bin ich energetisch?"
2. **Dominantes Element** — Welches Element ist am stärksten?
3. **Fehlendes Element** — Welches Element fehlt? (für Empfehlungen)
4. **Alle 4 Säulen** (für Vollständigkeit im Profil)

**NICHT verwendet (warum?):**

| Feature | Warum nicht im MVP? |
|---------|---------------------|
| **10 Gods (十神)** | • 10 komplexe Archetypen (Direct Officer, Eating God, etc.)<br>• Erfordern tiefes Bazi-Wissen zum Verstehen<br>• Claude-Prompts würden zu lang & komplex<br>• User-Verwirrung ohne Kontext<br>→ **Später als Premium-Feature** |
| **Luck Pillars (大运)** | • 10-Jahres-Zyklen über gesamtes Leben<br>• Komplex zu berechnen (Geschlecht + Yang/Yin-Jahr abhängig)<br>• Interpretation erfordert Clash-Analyse mit Birth Chart<br>• Zu viel Info auf einmal<br>→ **Später als Jahresvorschau-Feature** |
| **Hidden Stems (藏干)** | • Jeder Branch versteckt 1-3 Stems<br>• Macht Element-Balance extrem komplex<br>• Nutzen für Laien fraglich<br>• Braucht professionelle Bazi-Beratung<br>→ **Evtl. nie, zu spezialisiert** |

**Für MVP reicht:**
- Day Master (Kern-Persönlichkeit) ✅
- Vier Säulen komplett (Kontext) ✅
- Element-Balance (stark/schwach) ✅
- **Das ist verständlich** und Claude kann damit **gute Synthese-Texte** schreiben!

---

### 2.3 Numerologie

**Was ist Numerologie?**

Numerologie nutzt **Zahlen aus Namen und Geburtsdatum**, um die Lebensaufgabe und Talente zu beschreiben.

**Welches System?**

Wir nutzen das **pythagoräische System** (westliche Numerologie), NICHT das kabbalistische oder chaldäische.

#### Die Buchstaben-Wert-Tabelle

```
1: A, J, S
2: B, K, T
3: C, L, U
4: D, M, V
5: E, N, W
6: F, O, X
7: G, P, Y
8: H, Q, Z
9: I, R
```

#### Die Kernzahlen in Nuuray Glow

**Basis-Zahlen (immer berechnet):**

| Zahl | Deutsch | Englisch | Berechnung | Aussage |
|------|---------|----------|------------|---------|
| 1 | **Lebensweg** | Life Path | Quersumme des **Geburtsdatums** | "Wozu bin ich hier?" — Lebensaufgabe |
| 2 | **Geburtstag** | Birthday | **Tag** des Geburtstages (1-31) reduziert | "Meine natürliche Energie" |
| 3 | **Haltung** | Attitude | Quersumme von **Geburtstag + Geburtsmonat** | "Meine Grundhaltung" |
| 4 | **Persönliches Jahr** | Personal Year | Quersumme von **Geburtstag + Geburtsmonat + Aktuelles Jahr** | "Thema dieses Jahres" |
| 5 | **Reife** | Maturity | Quersumme von **Lebensweg + Ausdruck** | "Wer werde ich im Alter?" |

**Name-basierte Zahlen (Dual-Energy System):**

| Zahl | Deutsch | Englisch | Berechnung | Aussage |
|------|---------|----------|------------|---------|
| **Birth Energy** | Urenergie | Birth Name | Vornamen + Geburtsname | "Meine angeborenen Eigenschaften" |
| • Ausdruck | | Expression | Quersumme des **vollen Geburtsnamens** | "Meine Talente bei Geburt" |
| • Seelenwunsch | | Soul Urge | Quersumme der **Vokale** im Geburtsnamen | "Meine wahren Sehnsüchte" |
| • Persönlichkeit | | Personality | Quersumme der **Konsonanten** im Geburtsnamen | "Wie ich geboren wirke" |
| **Current Energy** | Aktuelle Energie | Current Name | Vornamen + Aktueller Nachname | "Meine aktuelle Energie" |
| • Ausdruck | | Expression | Quersumme des **aktuellen Namens** | "Meine heutigen Talente" |
| • Seelenwunsch | | Soul Urge | Quersumme der **Vokale** im aktuellen Namen | "Was ich heute will" |
| • Persönlichkeit | | Personality | Quersumme der **Konsonanten** im aktuellen Namen | "Wie ich heute wirke" |

**Erweiterte Numerologie (immer berechnet, in UI angezeigt):**

| Feature | Icon | Deutsch | Englisch | Berechnung | Aussage |
|---------|------|---------|----------|------------|---------|
| **Karmic Debt** | ⚡ | Karmische Schuldzahl | Karmic Debt Numbers | Prüfung auf 13/14/16/19 während Reduktion | "Alte Seelen-Lektionen" |
| **Challenges** | 🎯 | Herausforderungen | Challenge Numbers | 4 Phasen: Subtraktion von Geburtsdatum-Teilen | "Lebensaufgaben in 4 Phasen" |
| **Karmic Lessons** | 📚 | Karmische Lektionen | Karmic Lessons | Fehlende Zahlen 1-9 im Namen | "Was muss ich lernen?" |
| **Bridges** | 🌉 | Brückenzahlen | Bridge Numbers | Differenz zwischen Kernzahlen | "Wie verbinde ich meine Energien?" |

**Karmic Debt Details:**
- **13/4**: Faulheit → Disziplin lernen
- **14/5**: Überindulgenz → Balance finden
- **16/7**: Ego & Fall → Demut entwickeln
- **19/1**: Machtmissbrauch → Geben lernen

**Challenge Phases (4 Phasen):**
- **Phase 1** (0-30 Jahre): Jugend-Herausforderung
- **Phase 2** (30-40 Jahre): Erwachsenen-Herausforderung
- **Phase 3** (40-60 Jahre): Reife-Herausforderung
- **Phase 4** (60+ Jahre): Lebensziel-Herausforderung
- **Challenge 0**: Alte Seele (keine Herausforderung mehr)

#### Methode B: Meisterzahlen-erhaltend

**Wichtig:** Wir nutzen **Methode B** (Gesamt-Addition), nicht Methode A!

**Warum?**

Meisterzahlen (11, 22, 33) haben besondere spirituelle Bedeutung und sollten NICHT reduziert werden.

**Beispiel: Soul Urge für "Natalie Frauke Günes"**

**Methode A** (pro Namensteil reduzieren, DANN addieren):
```
Natalie → A+A+I+E = 1+1+9+5 = 16 → 1+6 = 7
Frauke  → A+U+E = 1+3+5 = 9
Günes   → U+E = 3+5 = 8
GESAMT: 7+9+8 = 24 → 2+4 = 6 ❌
```

**Methode B** (ALLE Vokale addieren, DANN einmal reduzieren):
```
A+A+I+E+A+U+E+U+E = 1+1+9+5+1+3+5+3+5 = 33 ✨
33 ist Meisterzahl → NICHT reduzieren!
Soul Urge = 33 ✅
```

**Regel:** Reduziere nur am Ende, wenn KEINE Meisterzahl entsteht.

#### Meisterzahlen (Master Numbers)

| Zahl | Bedeutung |
|------|-----------|
| **11** | Spirituelle Intuition, Erleuchtung, Kanal |
| **22** | Meister-Baumeister, Vision + Umsetzung |
| **33** | Meister-Lehrer, bedingungslose Liebe, Heilung |

**Wenn eine Meisterzahl entsteht:** NICHT weiter reduzieren!

#### Technische Berechnung

**Life Path (Lebensweg):**
```
Geburtsdatum: 30.11.1992

Methode B:
3+0+1+1+1+9+9+2 = 26 → 2+6 = 8 ✅

NICHT:
30 → 3+0 = 3
11 → (Meisterzahl, nicht reduzieren)
1992 → 1+9+9+2 = 21 → 2+1 = 3
3+11+3 = 17 → 1+7 = 8 ← Würde auch klappen, aber Methode B ist klarer
```

**Expression (Ausdruck):**
```
Name: Natalie Günes
N=5, A=1, T=2, A=1, L=3, I=9, E=5, G=7, U=3, N=5, E=5, S=1

5+1+2+1+3+9+5+7+3+5+5+1 = 47 → 4+7 = 11 ✨ (Meisterzahl!)
```

**Soul Urge (Seelenwunsch):**
```
Nur Vokale: A, A, I, E, U, E (Y zählt als Vokal wenn kein anderer Vokal im Wortteil)
A+A+I+E+U+E = 1+1+9+5+3+5 = 24 → 2+4 = 6
```

**Personality (Persönlichkeit):**
```
Nur Konsonanten: N, T, L, G, N, S
N+T+L+G+N+S = 5+2+3+7+5+1 = 23 → 2+3 = 5
```

---

## 3. Die Synthese — Wie alles zusammenkommt

### 3.1 Das Problem mit Multi-System-Astrologie

**Typische Horoskop-Apps zeigen:**
```
📋 Dein Sternzeichen: Schütze
"Du bist optimistisch und abenteuerlustig..."

📋 Dein Bazi Day Master: Yin-Wasser
"Du bist intuitiv und anpassungsfähig..."

📋 Deine Lebenszahl: 8
"Du bist ehrgeizig und materiell erfolgreich..."
```

**Problem:** Drei separate Texte, die sich widersprechen können!

**Beispiel:**
- Schütze = extrovertiert, direkt, abenteuerlich
- Yin-Wasser = introvertiert, zurückhaltend, sanft
- Lebenszahl 8 = ehrgeizig, machtorientiert, praktisch

**Wie soll der User das verstehen?** 🤷‍♀️

### 3.2 Nuuray Glow Lösung: Synthese als Erzählung

**Unser Ansatz:**

Alle drei Systeme werden zu **einer stimmigen Geschichte** verwoben, die die **Nuancen** erklärt:

**Beispiel-Synthese für obiges Profil:**

```
Du trägst die Abenteuerlust des Schützen in dir (☀️ Sonne) —
aber deine emotionale Natur ist wie Yin-Wasser (🌊 Bazi):
still, tief, intuitiv.

Nach außen wirkst du vielleicht zurückhaltend,
doch in dir brennt ein Feuer der Neugier.

Deine Lebenszahl 8 (🔢 Numerologie) zeigt:
Du KANNST Erfolg manifestieren — aber nur,
wenn du deiner stillen Intuition vertraust,
statt dich zu zwingen, extrovertiert zu sein.

Deine Kraft liegt in der Synthese:
Die Vision des Schützen + die Weisheit des Wassers
+ die Umsetzungskraft der 8 = Dein einzigartiger Weg.
```

**Das ist NICHT drei separate Texte — es ist EINE Erzählung!**

### 3.3 Wie wird die Synthese generiert?

**Durch die Claude API!**

Der Prompt bekommt:
1. Western Astrology (Sonne, Mond, Aszendent mit Gradzahlen)
2. Bazi (Day Master, Elemente-Balance)
3. Numerology (5 Kernzahlen)
4. Kontext (Tagesenergie, Mondphase)

**Claude API Aufgabe:**
- Finde die **Gemeinsamkeiten** zwischen den Systemen
- Erkläre die **scheinbaren Widersprüche** als Nuancen
- Webe alles zu einer **persönlichen Geschichte**

**Ton:** Unterhaltsam, staunend, ermutigend (wie eine kluge Freundin beim Kaffee)

### 3.4 Content-Typen

| Content | Freemium | Premium | Synthese-Tiefe |
|---------|----------|---------|----------------|
| **Tageshoroskop** | ✅ Basis-Version | ✅ Personalisiert | Sonne + Mondphase + Tagesenergie |
| **Wochenausblick** | ❌ | ✅ | Sonne + Mond + Bazi Day Master |
| **Monatsenergie** | ❌ | ✅ | Alle 3 Systeme vollständig |
| **Jahresvorschau** | ❌ | ✅ OTP (einmalig) | Alle 3 Systeme + Transite + Luck Pillars |
| **Partner-Check** | ❌ | ✅ | Sonne + Mond beider Partner + Elemente |

---

## 4. Design & User Experience

### 4.1 Design-Prinzipien

**Warm, Golden, Unterhaltsam** — aber nicht kitschig!

**Farbpalette:**
```
Primary:    #D4AF37 (Gold)        — Hauptakzent, Buttons
Secondary:  #F5E6D3 (Champagner)  — Hintergründe, Cards
Accent:     #8B7355 (Bronze)      — Sekundäre Akzente
Background: #FFFBF5 (Crème)       — App-Hintergrund
Text Dark:  #2C2416 (Dunkelbraun) — Haupttext
Text Light: #8B7355 (Bronze)      — Sekundärtext
```

**Typografie:**
- Headlines: **Playfair Display** (elegant, serif)
- Body: **Inter** (klar, lesbar, sans-serif)

**Stil:**
- Viel Weißraum (keine überladenen Screens!)
- Subtile Gradienten (Gold → Champagner)
- Abgerundete Ecken (16px Radius)
- Schatten: Weich, subtil
- Icons: Line-Style (nicht filled)

### 4.2 Visual Hierarchy

**Informations-Dichte:** Mittel

Nicht zu minimalistisch (langweilig), nicht zu voll (überfordernd)

**Screen-Struktur:**
```
┌─────────────────────────┐
│ Header (Name + Greeting)│ ← Persönlich
├─────────────────────────┤
│                         │
│   Feature Card          │ ← Fokus (groß, prominent)
│   (Tageshoroskop)       │
│                         │
├─────────────────────────┤
│ Mondphase │ Tagesenergie│ ← Kompakt, nebeneinander
├─────────────────────────┤
│ Quick Actions           │ ← Klein, funktional
└─────────────────────────┘
```

**Card-Design:**
```
┌───────────────────────────┐
│ 🌙 TAGESHOROSKOP          │ ← Icon + Titel
├───────────────────────────┤
│                           │
│ Claude-generierter Text   │ ← Max. 3-4 Zeilen
│ mit Synthese...           │
│                           │
├───────────────────────────┤
│         [Mehr lesen] →    │ ← CTA wenn länger
└───────────────────────────┘
```

### 4.3 Animation & Micro-Interactions

**Subtil, elegant — kein "Disney-Effekt"**

- Card Tap: Leichtes Scale (1.02) + Schatten erhöhen
- Screen Transitions: Slide (links/rechts) mit Fade
- Loading: Shimmer-Effekt (kein Spinner!)
- Success: Sanftes Fade-In mit Icon-Bounce
- Error: Sanftes Shake + Rot-Highlight

**Beispiel: Onboarding-Schritt weiter**
```
Button geklickt
  → Scale to 0.98 (feedback)
  → Aktueller Screen slide-out links
  → Neuer Screen slide-in rechts
  → Weich (300ms Cubic-Bezier)
```

---

## 5. Screen-Architektur

### 5.1 Screen-Übersicht

| Screen | Zweck | Authentifizierung | Navigation |
|--------|-------|-------------------|------------|
| **Splash** | Loading + Auto-Routing | Nein | → Auth/Onboarding/Home |
| **Login/Signup** | Email-Auth | Nein | → Onboarding oder Home |
| **Onboarding (2 Schritte)** | Geburtsdaten erfassen | Ja (vorher Login) | → Home |
| **Home** | Dashboard + Tageshoroskop | Ja | BottomNav: Home |
| **Deine Signatur** | Vollständiges Profil | Ja | BottomNav: Profil |
| **Daily Horoscope Detail** | Ausführliches Tageshoroskop | Ja | Von Home |
| **Moon Calendar** | Mondphasen-Kalender | Ja | Von Home |
| **Partner Check** | Kompatibilitäts-Analyse | Ja (Premium) | Von Home |
| **Settings** | Account, Sprache, Premium | Ja | Von Profil |

### 5.2 Screen-Details

#### Splash Screen

**Dauer:** 1-2 Sekunden
**Funktion:** Auth-State prüfen + Routing

```
Logik:
1. Ist User eingeloggt?
   Nein → Login Screen
   Ja → Weiter zu 2
2. Hat User ein Profil (Onboarding abgeschlossen)?
   Nein → Onboarding Screen
   Ja → Home Screen
```

**Design:**
- NUURAY Logo (groß, zentriert)
- Untertitel: "Mondlicht"
- Sanftes Pulsieren (Logo)
- Gold-Gradient Hintergrund

---

#### Login/Signup Screen

**Funktionen:**
- Email + Passwort (Supabase Auth)
- "Passwort vergessen" Link
- "Noch kein Account? Registrieren"

**Design:**
- Minimalistisch (nur Formular)
- Logo oben
- CTA-Button: Gold (Primary Color)

**Wichtig:** KEINE Social Logins im MVP (Apple Sign-In später)

---

#### Onboarding (2 Schritte)

**Schritt 1: Name & Identität**
```
┌─────────────────────────┐
│ Schritt 1 von 2         │ ← Progress Indicator
├─────────────────────────┤
│ Wie sollen wir dich     │ ← Headline
│ nennen?                 │
│                         │
│ Rufname / Username      │ ← PFLICHT
│ [Natalie         ]      │
│                         │
│ Vornamen lt. Geburts-   │ ← OPTIONAL
│ urkunde                 │
│ [Natalie Frauke  ]      │
│ ℹ️ Alle Vornamen für     │
│    präzise Numerologie   │
│                         │
│ Geburtsname (Maiden)    │ ← OPTIONAL
│ [Pawlowski       ]      │
│ ℹ️ Nachname vor Heirat   │
│                         │
│ Aktueller Nachname      │ ← OPTIONAL
│ [Günes           ]      │
│ ℹ️ Falls geändert nach   │
│    Heirat/Namensänderung │
│                         │
│         [Weiter]        │ ← CTA
└─────────────────────────┘
```

**Wichtig:**
- **Rufname/Username:** PFLICHT (wird überall in der App angezeigt)
- **Vornamen lt. Geburtsurkunde:** OPTIONAL (alle Vornamen für Numerologie)
- **Geburtsname:** OPTIONAL (Nachname vor Heirat/Namensänderung)
- **Aktueller Nachname:** OPTIONAL (heutiger Nachname)

**Numerologie-Konzept (Dual-Energy):**
- **Birth Energy (Urenergie):** `Vornamen + Geburtsname` (z.B. "Natalie Frauke Pawlowski")
- **Current Energy (Aktuelle Energie):** `Vornamen + Aktueller Nachname` (z.B. "Natalie Frauke Günes")
- Wenn Namen identisch sind, wird nur Birth Energy angezeigt

**Schritt 2: Geburtsdaten (alles kombiniert)**
```
┌─────────────────────────┐
│ Schritt 2 von 2         │
├─────────────────────────┤
│ Wann & wo wurdest du    │
│ geboren?                │
│                         │
│ Geburtsdatum            │
│ [__.__.____]            │ ← Date Picker
│                         │
│ 🕐 Geburtszeit (optional)│
│ [__:__]                 │ ← Time Picker
│ ℹ️ Für Aszendent         │
│                         │
│ 📍 Geburtsort (optional)│
│ [Ort eingeben...    ]   │ ← Text Input
│         [Ort suchen]    │ ← Button (Google Places)
│                         │
│ ✓ Friedrichshafen, DE   │ ← Erfolg (grün)
│   47.65°, 9.48°         │
│   Europe/Berlin         │
│                         │
│ ⚠️ Ohne Geburtsort &    │ ← Hinweis wenn übersprungen
│    -zeit kann dein      │
│    Aszendent nicht      │
│    berechnet werden.    │
│                         │
│ [Überspringen]          │ ← Optional
│         [Fertig]        │ ← CTA
└─────────────────────────┘
```

**Wichtig:**
- Überspringen ist OK → Hinweis dass Aszendent fehlt
- Google Places Geocoding via Edge Function (server-seitig)
- Koordinaten + Timezone werden in DB gespeichert

---

#### Home Screen

**Struktur:**
```
┌─────────────────────────┐
│ Guten Morgen, Natalie! ☀️│ ← Tageszeit-abhängig
├─────────────────────────┤
│ 🌟 DEINE SIGNATUR       │ ← Dashboard (immer sichtbar!)
│ Schütze ☀️ • Waage 🌙 • Löwe ⬆️│
│ 癸 Yin-Wasser • Lebensweg 8│
│        [Mehr erfahren →]│ ← Führt zu Detail-Screen
├─────────────────────────┤
│                         │
│ 🌙 TAGESHOROSKOP        │ ← Card (groß)
│ Heute ist ein Tag...    │
│ [Mehr lesen →]          │
│                         │
├──────────┬──────────────┤
│ 🌓 Mond  │ ⚡ Energie   │ ← Kompakt
│ Zunehmend│ Holz-Tag     │
└──────────┴──────────────┘
│                         │
│ QUICK ACTIONS           │
│ [💕 Partner] [📅 Kalender]│
└─────────────────────────┘
```

**Features:**
- **"Deine Signatur" Dashboard:** Immer sichtbar, kompakt (2-3 Zeilen)
- Personalisierte Begrüßung (Name + Tageszeit)
- Tageshoroskop-Preview (3-4 Zeilen)
- Mondphase aktuell
- Tagesenergie (Bazi)
- Quick Actions zu Premium-Features

**Warum "Deine Signatur" immer sichtbar?**
- Kern der App (darf nicht versteckt sein!)
- Täglicher Reminder ihrer Einzigartigkeit
- Schneller Zugriff auf vollständiges Profil
- Minimal genug um nicht zu stören

**Navigation:**
- Bottom Nav: [Home] [Profil] [Mehr]

---

#### Deine Signatur (Detail-Screen)

**Von Home Dashboard "Mehr erfahren" erreichbar**

**Drei Cards:**

**Card 1: Western Astrology**
```
┌─────────────────────────┐
│ 🌟 WESTLICHE ASTROLOGIE │
├─────────────────────────┤
│ ☀️ Sonne: Schütze 8.01° │
│ 🌙 Mond: Waage 11.27°   │
│ ⬆️ Aszendent: Löwe 8.39°│
│                         │
│ [Mehr erfahren →]       │ ← Premium: Synthese-Text
└─────────────────────────┘
```

**Card 2: Bazi**
```
┌─────────────────────────┐
│ 🀄 BAZI (VIER SÄULEN)   │
├─────────────────────────┤
│ Day Master: 癸 Yin-Wasser│
│                         │
│ Jahr:  丙申 (Feuer-Affe) │
│ Monat: 甲午 (Holz-Pferd) │
│ Tag:   癸亥 (Wasser-Schw.)│
│ Stunde: 甲寅 (Holz-Tiger)│
│                         │
│ Element-Balance:        │
│ 🌳 Holz: ███░░ Stark    │
│ 🔥 Feuer: ██░░░ Mittel  │
│ 💧 Wasser: ██░░░ Mittel │
│ ⛰️ Erde: ░░░░░ Fehlt!   │
│ ⚙️ Metall: █░░░░ Schwach│
│                         │
│ [Mehr erfahren →]       │
└─────────────────────────┘
```

**Card 3: Numerologie**
```
┌─────────────────────────┐
│ 🔢 NUMEROLOGIE          │
├─────────────────────────┤
│ ● Lebensweg: 1          │ ← Prominent
│   Führung & Pioniergeist│
│                         │
│ [Geburtstag] [Haltung]  │ ← Kompakte Chips
│ [Jahr 2026] [Reife]     │
│                         │
│ 🌟 Urenergie (expandable)│ ← Birth Energy
│ Natalie Frauke Pawlowski│
│ └─ Ausdruck: 11 ✨      │
│ └─ Seelenwunsch: 33 ✨  │
│ └─ Persönlichkeit: 5    │
│                         │
│ ✨ Aktuelle Energie     │ ← Current Energy
│    (expandable)         │   (nur wenn Name geändert)
│ Natalie Frauke Günes    │
│ └─ Ausdruck: 8          │
│ └─ Seelenwunsch: 6      │
│ └─ Persönlichkeit: 2    │
│                         │
│ ─── Erweiterte Numerologie ───│
│                         │
│ ⚡ Karmic Debt          │
│ └─ Lebensweg: 19        │
│    Machtmissbrauch →    │
│    Geben lernen         │
│                         │
│ 🎯 Challenges           │
│ [Phase 1: 3] [Phase 2: 1]│
│ [Phase 3: 2] [Phase 4: 0]│ ← 0 = grün (alte Seele)
│                         │
│ 📚 Karmic Lessons       │
│ [2] [4] [6] [8]         │ ← Fehlende Zahlen
│                         │
│ 🌉 Bridges              │
│ └─ Lebensweg ↔ Ausdruck: 3│
│    Verbinde Weg & Talent│
│                         │
│ [Mehr erfahren →]       │
└─────────────────────────┘
```

**Features:**
- **Kern-Zahlen:** Life Path prominent, andere als Chips
- **Dual-Energy System:** Birth Energy (Urenergie) + Current Energy (nur bei Namensänderung)
- **Expandable Sections:** Name Energies klappbar
- **Erweiterte Numerologie:**
  - ⚡ Karmic Debt Numbers (13/14/16/19)
  - 🎯 Challenge Numbers (4 Phasen, Challenge 0 grün hervorgehoben)
  - 📚 Karmic Lessons (fehlende Zahlen 1-9)
  - 🌉 Bridge Numbers (Verbindungen zwischen Kernzahlen)
- **Meisterzahlen:** 11, 22, 33 mit ✨ markiert

**Expandable:**
- Tap auf Card → Detail-View mit Erklärungen
- Premium: Synthese-Text (Claude API generiert)

**Zusätzlich auf diesem Screen:**
- **[Profil bearbeiten]** Button (Geburtsdaten korrigieren)
- **Teilen-Funktion** (Screenshot von Signatur)

**Navigation:**
- Bottom Nav: [Home] **[Profil]** [Mehr] ← Aktiv

---

#### Daily Horoscope Detail Screen

**Von Home Screen erreichbar via "Mehr lesen"**

```
┌─────────────────────────┐
│ ← Zurück                │
├─────────────────────────┤
│ TAGESHOROSKOP           │
│ Freitag, 7. Februar     │
├─────────────────────────┤
│                         │
│ 🌙 Mondphase: Zunehmend │
│ ⚡ Energie: Holz-Tag     │
│                         │
│ Dein persönliches       │
│ Horoskop für heute:     │
│                         │
│ [Claude-generierter     │
│  Text, ~200-300 Wörter] │
│                         │
│ Heute Abend (Premium):  │
│ [🔒 Freischalten]       │
│                         │
└─────────────────────────┘
```

**Freemium vs Premium:**
- Freemium: Basis-Text (1 Absatz, ~50 Wörter)
- Premium: Vollständiger Text (3-4 Absätze, ~250 Wörter) + Abend-Update

---

#### Moon Calendar Screen

**Mondphasen-Kalender mit Tracking**

```
┌─────────────────────────┐
│ MONDKALENDER            │
├─────────────────────────┤
│    Februar 2026         │
│ Mo Di Mi Do Fr Sa So    │
│        1  2  3  4  5  6 │ ← Symbole
│ 7  8 🌑 🌒 🌓 🌔 🌕 🌖 │   (Mondphasen)
│ ...                     │
├─────────────────────────┤
│ Heute: Zunehmender Mond │
│ 🌓 7. Tag nach Neumond  │
│                         │
│ Beste Zeit für:         │
│ • Neue Projekte starten │
│ • Beziehungen stärken   │
│                         │
│ [Mehr lesen →] (Premium)│
└─────────────────────────┘
```

**Features:**
- Mondphase für jeden Tag
- Tap auf Tag → Detail mit Empfehlungen
- Premium: Ausführliche Mondphasen-Tipps

---

#### Partner Check Screen (Premium)

**Kompatibilitäts-Analyse**

```
┌─────────────────────────┐
│ PARTNER-CHECK 💕        │
├─────────────────────────┤
│ Dein Partner:           │
│ [Name       ]           │ ← Input
│ [__.__.____]            │ ← Geburtsdatum
│                         │
│     [Analysieren]       │
├─────────────────────────┤
│                         │
│ ERGEBNIS:               │
│ ⭐⭐⭐⭐⭐ 85% Match!    │
│                         │
│ Deine Schütze-Sonne     │
│ harmoniert mit seinem   │
│ Löwe-Mond...            │
│                         │
│ [Claude-generierte      │
│  Kompatibilitäts-       │
│  Analyse, ~300 Wörter]  │
│                         │
└─────────────────────────┘
```

**Berechnung:**
- Sonne-Mond-Aspekte (Trigon, Quadrat, etc.)
- Element-Kompatibilität (Bazi)
- Numerologie Life Path Harmonie

---

#### Settings Screen

**Account-Verwaltung + Premium**

```
┌─────────────────────────┐
│ EINSTELLUNGEN           │
├─────────────────────────┤
│ Account                 │
│ • Email ändern          │
│ • Passwort ändern       │
│ • Profil bearbeiten     │
├─────────────────────────┤
│ Premium                 │
│ • Status: Free          │
│ • [Premium werden →]    │
├─────────────────────────┤
│ App                     │
│ • Sprache: Deutsch      │
│ • Benachrichtigungen    │
│ • Theme: Hell           │
├─────────────────────────┤
│ Sonstiges               │
│ • Datenschutz           │
│ • AGB                   │
│ • Impressum             │
│ • [Logout]              │
└─────────────────────────┘
```

---

## 6. Freemium vs Premium

### 6.1 Freemium (kostenlos)

**Ziel:** Nutzer anlocken, Kern-Feature zeigen, Mehrwert demonstrieren

| Feature | Beschreibung | Einschränkung |
|---------|--------------|---------------|
| **Tageshoroskop** | Basis-Version | Nur 1 Absatz (~50 Wörter), keine Abend-Updates |
| **Cosmic Profile** | Anzeige aller Daten | Keine Synthese-Texte |
| **Mondphasen** | Aktueller Tag | Keine Kalender-Übersicht |
| **Home Screen** | Vollständig | Quick Actions führen zu Premium-Prompt |

**Werbung:** NEIN! Keine Ads, saubere Erfahrung.

**Call-to-Action:** Dezent (kein nervendes Popup)
- "🔒 Mit Premium freischalten" bei gesperrten Features
- "✨ Premium werden" in Settings

---

### 6.2 Premium (Abo)

**Preis:** 4,99 €/Monat oder 39,99 €/Jahr (~3,33 €/Monat)

**Features:**

| Feature | Freemium | Premium |
|---------|----------|---------|
| **Tageshoroskop** | Basis (1 Absatz) | Vollständig (3-4 Absätze) + Abend-Update |
| **Wochenausblick** | ❌ | ✅ Sonntags generiert |
| **Monatsenergie** | ❌ | ✅ Jeden 1. des Monats |
| **Jahresvorschau** | ❌ | ✅ Einmalig beim Premium-Kauf, dann jedes Jahr am 1.1. |
| **Partner-Check** | ❌ | ✅ Unbegrenzt |
| **Freundinnen-Check** | ❌ | ✅ Freundschafts-Kompatibilität |
| **Mondphasen-Kalender** | Nur heute | ✅ Vollständiger Monat |
| **"Deine Signatur" Synthese** | ❌ | ✅ Claude-generierte Texte |
| **Push-Benachrichtigungen** | ❌ | ✅ Tägliches Horoskop morgens |

**Jahresvorschau-Besonderheit:**
- Wird **On-Demand** generiert wenn User Premium kauft (nicht automatisch für alle)
- ~2000 Wörter (ca. 8-10 Minuten Lesezeit)
- Enthält: Transite, Luck Pillars (Bazi), persönliches Jahr (Numerologie)
- **Cache:** Einmal generiert, 365 Tage gültig
- Kosten: ~$0.50 pro User (Claude Opus!)

**Zusätzlich (optional, später):**
- PDF-Reports als **One-Time Purchase** (9,99-19,99 €)
  - Jahresvorschau als PDF (zum Ausdrucken)
  - Vollständiges Birth Chart als PDF

---

### 6.3 Paywall-Strategie

**Soft Paywall** — kein aggressives Nerven!

**Ansatz:**
1. **Freemium ist wertvoll** — Nutzer bekommen echten Mehrwert kostenlos
2. **Premium ist verlockend** — deutlicher Unterschied, aber nicht frustrierend
3. **Trial:** 7 Tage kostenlos testen (Apple StoreKit / Google Play)

**Trigger für Premium-Prompt:**
- Tap auf "Mehr lesen" bei Tageshoroskop → Bottom Sheet mit Preview
- Tap auf "Partner-Check" → "Dieses Feature ist Premium"
- Tap auf "Mehr erfahren" bei Cosmic Profile Cards

**Bottom Sheet Design:**
```
┌─────────────────────────┐
│ ✨ Mit Premium           │
│                         │
│ ✓ Vollständiges         │
│   Tageshoroskop         │
│ ✓ Wochenausblick        │
│ ✓ Partner-Check         │
│ ...                     │
│                         │
│ 7 Tage kostenlos testen │
│ Dann 4,99 €/Monat       │
│                         │
│   [Jetzt testen →]      │
│   [Vielleicht später]   │
└─────────────────────────┘
```

**Wichtig:** KEINE Tricks!
- Kein Auto-Renewal ohne klaren Hinweis
- Jederzeit kündbar
- Transparente Preise

---

## 7. Onboarding Journey

### 7.1 Ziel

**Innerhalb von 2-3 Minuten:**
1. User versteht das Konzept (3 Systeme = 1 Synthese)
2. User gibt Geburtsdaten ein
3. User sieht sofort Ergebnis ("Deine Signatur")
4. User ist begeistert und will mehr (Tageshoroskop)

### 7.2 Flow

```
App öffnen
  → Splash (1-2s)
  → Login/Signup (30s)
  → Onboarding Intro (optional, 15s)
  → Onboarding Schritt 1: Name (30s)
  → Onboarding Schritt 2: Geburtsdaten (60s inkl. Google Places)
  → Berechnung läuft (3-5s)
  → Home Screen mit "Deine Signatur" Dashboard
  → "🎉 Deine Signatur ist fertig!" (Celebration)
```

**Total: ~2-3 Minuten** (schneller als vorher!)

### 7.3 Onboarding Intro (Optional)

**Screen vor Schritt 1** (kann übersprungen werden):

```
┌─────────────────────────┐
│                         │
│    🌙 NUURAY GLOW       │
│                         │
│ Dein Horoskop aus       │
│ drei Welten:            │
│                         │
│ 🌟 Westliche Astrologie │
│ 🀄 Chinesisches Bazi    │
│ 🔢 Numerologie          │
│                         │
│ = Eine einzigartige     │
│   Synthese, nur für dich│
│                         │
│     [Los geht's →]      │
│     [Überspringen]      │
└─────────────────────────┘
```

**Swipeable (3 Screens):**
1. Konzept erklären
2. Beispiel zeigen (Testimonial)
3. "Bereit? Lass uns starten!"

---

### 7.4 Post-Onboarding Celebration

**Nach Profil-Speicherung:**

```
┌─────────────────────────┐
│         🎉              │
│                         │
│ Deine Signatur          │
│ ist fertig!             │
│                         │
│ [Animation: Sterne ✨]  │
│                         │
│ Entdecke jetzt dein     │
│ persönliches Horoskop...│
│                         │
│     [Weiter →]          │
└─────────────────────────┘
```

**Dann:** Direkt zum Home Screen → "Deine Signatur" Dashboard ist sichtbar

**First-Time User Experience:**
- "Deine Signatur" Dashboard zeigt Highlight-Animation
- Tooltip: "Tippe hier für Details zu deiner einzigartigen Signatur"
- Nach 3s verschwindet Tooltip automatisch

---

## 8. Datenbank-Schema

### 8.1 Supabase Tabellen

#### `users` (Supabase Auth, automatisch)

Wird von Supabase verwaltet, keine eigenen Änderungen nötig.

---

#### `profiles`

**Zweck:** User-Profil mit Geburtsdaten

| Feld | Typ | Beschreibung | Nullable |
|------|-----|--------------|----------|
| `id` | UUID | PK, ref `auth.users.id` | NOT NULL |
| `created_at` | TIMESTAMPTZ | Erstellungszeitpunkt | NOT NULL |
| `updated_at` | TIMESTAMPTZ | Letzte Änderung | NOT NULL |
| **Name-Felder** | | | |
| `display_name` | TEXT | Rufname/Username (wie User genannt werden will) | NOT NULL |
| `full_first_names` | TEXT | Vornamen lt. Geburtsurkunde (z.B. "Natalie Frauke") | NULL |
| `birth_name` | TEXT | Geburtsname / Maiden Name (Nachname vor Heirat) | NULL |
| `last_name` | TEXT | Aktueller Nachname (nach Heirat/Namensänderung) | NULL |
| **Geburtsdaten** | | | |
| `birth_date` | DATE | Geburtsdatum | NOT NULL |
| `birth_time` | TIME | Geburtszeit (optional) | NULL |
| `birth_place` | TEXT | Geburtsort (Text) | NULL |
| `birth_latitude` | FLOAT | Geburtsort Breitengrad | NULL |
| `birth_longitude` | FLOAT | Geburtsort Längengrad | NULL |
| `birth_timezone` | TEXT | Zeitzone (z.B. "Europe/Berlin") | NULL |
| **Präferenzen** | | | |
| `language` | TEXT | DE oder EN | NOT NULL, Default: 'DE' |
| `premium_status` | BOOLEAN | Ist Premium-User? | NOT NULL, Default: FALSE |
| `premium_until` | TIMESTAMPTZ | Premium-Abo läuft bis | NULL |

**Numerologie-Logik (Dual-Energy System):**
- **Birth Energy (Urenergie):** `full_first_names` + `birth_name`
- **Current Energy (Aktuelle Energie):** `full_first_names` + `last_name`
- Wenn Namen identisch sind, wird nur Birth Energy angezeigt

**Beispiel:**
```
display_name: "Natalie"
full_first_names: "Natalie Frauke"
birth_name: "Pawlowski"  (Geburtsname vor Heirat)
last_name: "Günes"  (aktueller Nachname nach Heirat)

→ Birth Energy berechnet aus: "Natalie Frauke Pawlowski"  (Geburtsname!)
→ Current Energy berechnet aus: "Natalie Frauke Günes"  (aktueller Name)
```

**RLS (Row Level Security):**
```sql
-- User sieht nur eigenes Profil
CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

-- User kann eigenes Profil aktualisieren
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);
```

---

#### `birth_charts`

**Zweck:** Berechnete astrologische Daten ("Deine Signatur" - Cache)

**Hinweis:** Tabellenname ist `birth_charts` (nicht `signature_profiles`), da die Umbenennung noch aussteht.

| Feld | Typ | Beschreibung | Nullable |
|------|-----|--------------|----------|
| `id` | UUID | PK | NOT NULL |
| `user_id` | UUID | FK → `profiles.id` | NOT NULL |
| `created_at` | TIMESTAMPTZ | Erste Berechnung | NOT NULL |
| `updated_at` | TIMESTAMPTZ | Letzte Neuberechnung | NOT NULL |
| **Western Astrology** | | | |
| `sun_sign` | TEXT | Sonnenzeichen (z.B. "sagittarius") | NOT NULL |
| `sun_degree` | DOUBLE PRECISION | Grad im Zeichen (0-30) | NULL |
| `moon_sign` | TEXT | Mondzeichen | NULL |
| `moon_degree` | DOUBLE PRECISION | Grad im Zeichen | NULL |
| `ascendant_sign` | TEXT | Aszendent | NULL |
| `ascendant_degree` | DOUBLE PRECISION | Grad im Zeichen | NULL |
| **Bazi** | | | |
| `bazi_year_stem` | TEXT | Heavenly Stem Jahr | NULL |
| `bazi_year_branch` | TEXT | Earthly Branch Jahr | NULL |
| `bazi_month_stem` | TEXT | Heavenly Stem Monat | NULL |
| `bazi_month_branch` | TEXT | Earthly Branch Monat | NULL |
| `bazi_day_stem` | TEXT | Day Master (wichtig!) | NULL |
| `bazi_day_branch` | TEXT | Earthly Branch Tag | NULL |
| `bazi_hour_stem` | TEXT | Heavenly Stem Stunde | NULL |
| `bazi_hour_branch` | TEXT | Earthly Branch Stunde | NULL |
| `bazi_element` | TEXT | Dominantes Element | NULL |
| **Numerologie - Kern** | | | |
| `life_path_number` | INTEGER | Lebenszahl (1-9, 11, 22, 33) | NULL |
| `birthday_number` | INTEGER | Geburtstagszahl | NULL |
| `attitude_number` | INTEGER | Haltungszahl | NULL |
| `personal_year` | INTEGER | Persönliches Jahr | NULL |
| `maturity_number` | INTEGER | Reifezahl | NULL |
| **Numerologie - Birth Energy** | | | |
| `birth_expression_number` | INTEGER | Ausdruck (Geburtsname) | NULL |
| `birth_soul_urge_number` | INTEGER | Seelenwunsch (Geburtsname) | NULL |
| `birth_personality_number` | INTEGER | Persönlichkeit (Geburtsname) | NULL |
| `birth_name` | TEXT | Geburtsname (vollständig) | NULL |
| **Numerologie - Current Energy** | | | |
| `current_expression_number` | INTEGER | Ausdruck (aktueller Name) | NULL |
| `current_soul_urge_number` | INTEGER | Seelenwunsch (aktueller Name) | NULL |
| `current_personality_number` | INTEGER | Persönlichkeit (aktueller Name) | NULL |
| `current_name` | TEXT | Aktueller Name (vollständig) | NULL |
| **Numerologie - Erweitert** | | | |
| `karmic_debt_life_path` | INTEGER | Karmic Debt (13/14/16/19) | NULL |
| `karmic_debt_expression` | INTEGER | Karmic Debt Expression | NULL |
| `karmic_debt_soul_urge` | INTEGER | Karmic Debt Soul Urge | NULL |
| `challenge_numbers` | INTEGER[] | 4 Challenge Numbers (Array) | NULL |
| `karmic_lessons` | INTEGER[] | Fehlende Zahlen (Array) | NULL |
| `bridge_life_path_expression` | INTEGER | Bridge LP↔Expression | NULL |
| `bridge_soul_urge_personality` | INTEGER | Bridge SU↔Personality | NULL |
| `calculated_at` | TIMESTAMPTZ | Zeitpunkt der Berechnung | NOT NULL |

**RLS:**
```sql
CREATE POLICY "Users can view own birth chart"
  ON birth_charts FOR SELECT
  USING (auth.uid() = user_id);
```

**Wichtig:** Dieser Cache wird beim Onboarding einmalig berechnet und bei Profil-Änderungen neu berechnet.

---

#### `daily_content`

**Zweck:** Gecachter Content (Tageshoroskope, Mondphasen, Wochen-/Monats-/Jahresausblicke)

| Feld | Typ | Beschreibung | Nullable |
|------|-----|--------------|----------|
| `id` | UUID | PK | NOT NULL |
| `content_date` | DATE | Datum des Contents | NOT NULL |
| `content_type` | TEXT | "horoscope", "moon_phase", "weekly", "monthly", "yearly" | NOT NULL |
| `zodiac_sign` | TEXT | Sternzeichen (für Horoskope) | NULL |
| `language` | TEXT | DE oder EN | NOT NULL |
| `content_text` | TEXT | Generierter Text | NOT NULL |
| `created_at` | TIMESTAMPTZ | Generierungszeitpunkt | NOT NULL |
| `cache_until` | TIMESTAMPTZ | Cache gültig bis (für Wochen/Monats/Jahres-Content) | NULL |
| `moon_phase` | TEXT | Mondphase (z.B. "Waxing Crescent") | NULL |
| `bazi_day_energy` | TEXT | Bazi Tagesenergie | NULL |

**Cache-Strategie:**

| Content-Typ | cache_until | Beispiel |
|-------------|-------------|----------|
| `horoscope` | NULL (24h implizit) | Tageshoroskop gültig bis Mitternacht |
| `weekly` | +7 Tage | Wochenausblick gültig bis nächsten Sonntag |
| `monthly` | +30 Tage | Monatsenergie gültig bis Monatsende |
| `yearly` | +365 Tage | Jahresvorschau gültig bis nächstes Jahr |

**RLS:**
```sql
-- Alle authentifizierten User können Content lesen
CREATE POLICY "Authenticated users can view daily content"
  ON daily_content FOR SELECT
  TO authenticated
  USING (true);
```

**Unique Constraint:**
```sql
CREATE UNIQUE INDEX daily_content_unique
  ON daily_content (content_date, content_type, zodiac_sign, language);
```

**Zweck:** Verhindert doppelte Einträge für denselben Tag/Typ/Zeichen/Sprache

---

#### `partner_checks`

**Zweck:** Gespeicherte Partner-Analysen (Premium)

| Feld | Typ | Beschreibung | Nullable |
|------|-----|--------------|----------|
| `id` | UUID | PK | NOT NULL |
| `user_id` | UUID | FK → `profiles.id` | NOT NULL |
| `created_at` | TIMESTAMPTZ | Erstellungszeitpunkt | NOT NULL |
| `partner_name` | TEXT | Name des Partners | NOT NULL |
| `partner_birth_date` | DATE | Geburtsdatum Partner | NOT NULL |
| `compatibility_score` | INTEGER | 0-100 | NOT NULL |
| `analysis_text` | TEXT | Claude-generierter Text | NOT NULL |

**RLS:**
```sql
CREATE POLICY "Users can view own partner checks"
  ON partner_checks FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create partner checks"
  ON partner_checks FOR INSERT
  WITH CHECK (auth.uid() = user_id);
```

---

### 8.2 Supabase Edge Functions

#### `generate-daily-content`

**Zweck:** Cron-Job, läuft täglich um 4:00 UTC

**Aufgaben:**
1. Berechne Mondphase für heute
2. Berechne Bazi-Tagesenergie
3. Generiere Tageshoroskop für alle 12 Zeichen (DE + EN = 24 Texte)
4. Speichere in `daily_content` Tabelle

**Technologie:** Deno/TypeScript
**Claude API Calls:** 24 pro Tag (12 Zeichen × 2 Sprachen)

**Kosten:** ~$0.50 pro Tag = ~$15/Monat (bei 50 Wörtern pro Text)

---

#### `geocode-place`

**Zweck:** Server-seitige Geocoding via Google Places API

**Input:**
```json
{
  "query": "Friedrichshafen, Deutschland"
}
```

**Output:**
```json
{
  "place": "Friedrichshafen, Deutschland",
  "latitude": 47.6546609,
  "longitude": 9.4798766,
  "timezone": "Europe/Berlin"
}
```

**APIs verwendet:**
1. Google Places Autocomplete
2. Google Place Details
3. Google Timezone API

**Status:** ✅ Bereits implementiert

---

#### `calculate-signature`

**Zweck:** Berechnung aller astrologischen Daten ("Deine Signatur")

**Input:** `user_id` (aus JWT)

**Output:**
```json
{
  "western": { "sun": "Sagittarius 8.01°", ... },
  "bazi": { "day_master": "癸 Yin Water", ... },
  "numerology": { "life_path": 8, ... }
}
```

**Logik:**
1. Lade Profil aus DB
2. Berechne Western Astrology (ZodiacCalculator)
3. Berechne Bazi (BaziCalculator)
4. Berechne Numerologie (NumerologyCalculator)
   - Wenn `full_birth_name` vorhanden → Expression/Soul Urge/Personality daraus
   - Wenn `current_last_name` vorhanden → Aktuelle Namens-Energie berechnen
5. Speichere in `signature_profiles`

**Status:** ⏳ Noch zu implementieren (Logik existiert in Flutter)

---

#### `personalize-horoscope` (Premium)

**Zweck:** Personalisierung des gecachten Tageshoroskops

**Input:**
```json
{
  "user_id": "...",
  "date": "2026-02-07"
}
```

**Workflow:**
1. Lade gecachten Basis-Horoskop-Text für User-Sternzeichen
2. Lade Cosmic Profile des Users
3. Claude API Call: "Personalisiere diesen Text basierend auf Mond/Bazi/Numerologie"
4. Return personalisierter Text

**Kosten:** ~$0.01 pro Request (kurzer Prompt)

---

## 9. API-Integration

### 9.1 Claude API (Anthropic)

**Zweck:** Content-Generierung (Horoskope, Synthese-Texte)

**Model:** `claude-sonnet-4-20250514` (Standard), `claude-opus-4-5` (für Premium-Reports)

**Verwendung:**

| Content-Typ | Prompt-Länge | Output-Länge | Kosten/Call |
|-------------|--------------|--------------|-------------|
| Tageshoroskop (Basis) | ~500 Tokens | ~50 Wörter | ~$0.02 |
| Tageshoroskop (Premium) | ~800 Tokens | ~250 Wörter | ~$0.05 |
| Wochenausblick | ~1000 Tokens | ~400 Wörter | ~$0.08 |
| Partner-Check | ~1200 Tokens | ~300 Wörter | ~$0.10 |

**Caching-Strategie:**
- Tageshoroskope: Gecached für alle User (generiert um 4 Uhr)
- Personalisierung: On-Demand für Premium-User
- Partner-Checks: Gespeichert nach Generierung (nicht neu bei jedem View)

**Rate Limiting:**
- Max. 100 Requests/Minute (Anthropic Limit)
- User-Limit: 10 Partner-Checks/Tag (verhindert Missbrauch)

---

### 9.2 Google Places API

**Zweck:** Geburtsort → Koordinaten + Timezone

**APIs verwendet:**
1. **Autocomplete API** — Ortssuche
2. **Place Details API** — Koordinaten
3. **Timezone API** — Zeitzone

**Kosten:** ~$0.025 pro Geocoding-Request

**Free Tier:** $200/Monat = ~8000 Requests kostenlos

**Implementierung:** ✅ Server-seitig via Edge Function `geocode-place`

---

### 9.3 Supabase API

**Authentifizierung:** JWT-basiert (automatisch via Supabase Client)

**Verwendete Features:**
- **Auth:** Email/Passwort (später: Apple Sign-In)
- **Database:** PostgreSQL mit RLS
- **Edge Functions:** Deno/TypeScript
- **Realtime:** (optional für Live-Updates)
- **Storage:** (später für PDF-Reports)

**Region:** EU Central (GDPR-konform)

---

### 9.4 In-App Purchase APIs

**Apple StoreKit** (iOS):
- Produkte: `glow_premium_monthly`, `glow_premium_yearly`
- Preise: 4,99 € / 39,99 €
- 7-Tage-Trial: ✅
- Auto-Renewal: ✅ (mit Kündigungs-Option)

**Google Play Billing** (Android):
- Identische Produkte/Preise wie iOS
- Kompatibilität mit Subscriptions API

**Server-seitige Verifikation:**
- iOS: Receipt Validation via Apple Server
- Android: Google Play Developer API

**Implementierung:** ⏳ Später (nach MVP-Testing)

---

## 10. Content-Strategie

### 10.1 Tageshoroskop-Generierung

**Workflow:**

```
Täglich um 4:00 UTC (Edge Function):
    ↓
Für jedes Sternzeichen (12):
    ↓
Berechne Mondphase (heute)
Berechne Bazi-Tagesenergie (heute)
    ↓
Claude API Prompt:
    ↓
System: "Du bist Astrologie-Texterin für Nuuray Glow..."
User: "Tageshoroskop für Schütze am 7.2.2026.
       Mondphase: Zunehmender Mond (7. Tag).
       Bazi: Holz-Tag.
       Ton: Unterhaltsam, staunend, ermutigend.
       Länge: 50 Wörter."
    ↓
Claude API Response: "Heute..."
    ↓
Speichere in daily_content:
    - content_date: 2026-02-07
    - content_type: "horoscope"
    - zodiac_sign: "Sagittarius"
    - language: "DE"
    - content_text: "Heute..."
    ↓
Wiederhole für EN
```

**Resultat:** 24 Texte gecached (12 Zeichen × 2 Sprachen)

---

### 10.2 Personalisierung (Premium)

**Workflow beim Abruf:**

```
User öffnet Tageshoroskop:
    ↓
Lade gecachten Basis-Text (Sternzeichen)
    ↓
Wenn Premium-User:
    ↓
Lade Cosmic Profile (Mond, Bazi Day Master, Life Path)
    ↓
Claude API Prompt:
    ↓
System: "Personalisiere diesen Basis-Text..."
User: "Basis-Text: '...'
       User: Mond in Waage, Day Master Yin-Wasser, Life Path 8.
       Füge persönliche Akzente hinzu (max. 3 Sätze)."
    ↓
Claude API Response: "...und dein Mond in Waage sehnt sich heute besonders nach Harmonie..."
    ↓
Kombiniere: Basis-Text + Personalisierung
    ↓
Display in App
```

**Kosten:** ~$0.01 pro Premium-User pro Tag

---

### 10.3 Wochenausblick (Premium)

**Generierung:** Sonntags um 18:00 UTC

**Prompt-Struktur:**
```
"Wochenausblick für Schütze (8.-14. Februar).
Mondphasen: Zunehmend → Vollmond (12.2.).
Bazi-Energien: Montag Holz, Dienstag Feuer...
Ton: Vorausschauend, ermutigend.
Länge: 400 Wörter."
```

**Output:** Strukturierter Text mit Tages-Highlights

---

### 10.4 Partner-Check (Premium)

**On-Demand-Generierung:**

```
User gibt Partner-Daten ein:
    ↓
Berechne Partner-Profil (Western + Bazi + Numerology)
    ↓
Claude API Prompt:
    ↓
"Kompatibilitäts-Analyse:
User: Schütze-Sonne, Waage-Mond, Yin-Wasser, Life Path 8.
Partner: Löwe-Sonne, Skorpion-Mond, Yang-Feuer, Life Path 5.
Analysiere Harmonie, Herausforderungen, Tipps.
Ton: Warm, ehrlich, konstruktiv.
Länge: 300 Wörter."
    ↓
Claude API Response: "Eure Verbindung ist geprägt von..."
    ↓
Berechne Kompatibilitäts-Score (0-100):
    - Sonne-Mond-Aspekte: +40
    - Element-Harmonie: +30
    - Life Path Synergy: +15
    = 85%
    ↓
Speichere in partner_checks
    ↓
Display in App
```

**Kosten:** ~$0.10 pro Partner-Check

---

### 10.5 Jahresvorschau (Premium, On-Demand)

**Generierung:** Wenn User Premium kauft ODER am 1.1. jedes Jahres

**Workflow:**

```
User kauft Premium:
    ↓
Prüfe: Existiert Jahresvorschau für aktuelles Jahr?
    Ja → Zeige gecachte Version
    Nein → Generiere neu ↓
    ↓
Lade Signatur-Profil (Western + Bazi + Numerology)
    ↓
Berechne zusätzlich:
    - Aktuelle Transite (Planeten-Positionen)
    - Luck Pillars (Bazi 10-Jahres-Zyklus)
    - Persönliches Jahr (Numerologie)
    ↓
Claude API Prompt (OPUS Model!):
    ↓
"Jahresvorschau 2026 für [Name]:
Signatur: Schütze-Sonne, Waage-Mond, Löwe-Aszendent,
          Yin-Wasser Day Master, Life Path 8.
Transite: Jupiter in Zwillinge, Saturn in Fische...
Luck Pillar: Yang-Holz (2021-2031)
Persönliches Jahr: 3 (Kreativität & Ausdruck)

Erstelle Jahresvorschau:
1. Überblick (Was erwartet mich 2026?)
2. Quartalsweise Highlights
3. Beziehungen & Karriere
4. Herausforderungen & Chancen
5. Monatsweise Empfehlungen

Ton: Warm, inspirierend, realistisch.
Länge: ~2000 Wörter."
    ↓
Claude API Response: "2026 wird für dich..."
    ↓
Speichere in daily_content:
    - content_type: 'yearly'
    - content_date: '2026-01-01'
    - cache_until: '2027-01-01'
    - content_text: [2000 Wörter]
    ↓
Display in App
```

**Kosten:** ~$0.50 pro User (Opus Model + lange Antwort)

**Cache-Strategie:**
- Einmal generiert → 365 Tage gültig
- Kein Re-Generate nötig
- Am 1.1. nächstes Jahr: Automatisch neue Jahresvorschau für Premium-User

**Wichtig:**
- **Nicht** für alle User am 1.1. generieren (zu teuer!)
- **On-Demand** beim Premium-Kauf
- **Dann** jährlich automatisch für aktive Premium-User

---

## 11. Sprachen & Lokalisierung

### 11.1 Entwicklungsstrategie

**Primärsprache:** Deutsch
**Sekundärsprache:** Englisch (parallel entwickelt)

**Warum beide von Anfang an?**
- Internationale Skalierung geplant
- Claude API kann beide Sprachen gleich gut
- Minimal zusätzlicher Aufwand (ARB-Dateien)
- Vermeidet späteres Re-Writing

### 11.2 Implementierung

**ARB-Dateien** (Application Resource Bundle):
```
/packages/nuuray_ui/lib/src/l10n/
  ├── app_de.arb  ← Primär, wird zuerst geschrieben
  └── app_en.arb  ← Parallel, sofort mit implementiert
```

**Beispiel app_de.arb:**
```json
{
  "appTitle": "Nuuray Glow",
  "homeGreetingMorning": "Guten Morgen, {name}!",
  "signatureTitle": "Deine Signatur",
  "dailyHoroscope": "Tageshoroskop",
  "sunSign": "Sonne",
  "moonSign": "Mond",
  "ascendant": "Aszendent"
}
```

**Beispiel app_en.arb:**
```json
{
  "appTitle": "Nuuray Glow",
  "homeGreetingMorning": "Good morning, {name}!",
  "signatureTitle": "Your Signature",
  "dailyHoroscope": "Daily Horoscope",
  "sunSign": "Sun",
  "moonSign": "Moon",
  "ascendant": "Ascendant"
}
```

### 11.3 Settings Integration

**Sprach-Auswahl:**
```dart
// In Settings Screen
DropdownButton<String>(
  value: currentLanguage,
  items: [
    DropdownMenuItem(value: 'DE', child: Text('🇩🇪 Deutsch')),
    DropdownMenuItem(value: 'EN', child: Text('🇬🇧 English')),
  ],
  onChanged: (lang) => updateLanguage(lang),
)
```

**Datenbank-Update:**
```sql
UPDATE profiles
SET language = 'EN'
WHERE id = auth.uid();
```

**App-weite Reaktion:**
- Alle UI-Texte sofort in neuer Sprache
- Claude API Calls nutzen neue Sprache
- Gecachter Content in neuer Sprache geladen

### 11.4 Claude API Content-Generierung

**Sprach-Variable im Prompt:**
```dart
final prompt = """
Generate daily horoscope for $zodiacSign.
Language: ${user.language == 'DE' ? 'German' : 'English'}
Tone: Entertaining, curious.
Length: 50 words.
""";
```

**Claude generiert direkt in gewünschter Sprache!**

### 11.5 Während Entwicklung

**Dein Test-Account:**
- Sprache: Deutsch (Default)
- Alle Texte werden auf Deutsch angezeigt
- Englisch wird parallel entwickelt (ARB-Dateien)
- Zum Testen: Sprache in Settings auf EN umstellen → sofort Englisch!

**Wichtig:**
- Kein "i18n später" → beide Sprachen von Anfang an
- Minimal extra Aufwand (Copy-Paste ARB, dann übersetzen)
- Deepl kann helfen bei Übersetzungen

---

## 12. Entwicklungs-Roadmap

### 12.1 MVP (Minimal Viable Product) — 4-6 Wochen

**Ziel:** Lauffähige App mit Kern-Features, bereit für Early Adopters

| Feature | Status | Priorität | Dauer |
|---------|--------|-----------|-------|
| ✅ Auth (Email) | Fertig | P0 | — |
| ✅ Onboarding (2 Schritte!) | Fertig | P0 | — |
| ✅ Geocoding (Google Places) | Fertig | P0 | — |
| ✅ "Deine Signatur" Dashboard | Fertig | P0 | — |
| ⏳ Tageshoroskop (gecacht) | In Arbeit | P0 | 3 Tage |
| ⏳ Claude API Integration | In Arbeit | P0 | 2 Tage |
| ⏳ Mondphasen-Berechnung | TODO | P0 | 2 Tage |
| ⏳ Home Screen Polish | TODO | P1 | 1 Tag |
| ⏳ Settings Screen (mit Sprach-Auswahl) | TODO | P1 | 1 Tag |
| ⏳ Premium-Gating (UI) | TODO | P1 | 1 Tag |
| ⏳ i18n (Deutsch + Englisch) | TODO | P0 | 2 Tage |
| ⏳ Deployment (TestFlight) | TODO | P0 | 2 Tage |

**Total:** ~14 Tage (Vollzeit) oder ~4-5 Wochen (Teilzeit)

---

### 12.2 Post-MVP: Retention & Monetarisierung — 2-3 Wochen

| Feature | Priorität | Dauer |
|---------|-----------|-------|
| Push-Notifications (täglich) | P0 | 2 Tage |
| In-App Purchase (Apple + Google) | P0 | 3 Tage |
| Premium-Personalisierung (Claude) | P1 | 2 Tage |
| Wochenausblick | P1 | 2 Tage |
| Monatsenergie | P1 | 1 Tag |
| Jahresvorschau (On-Demand) | P1 | 2 Tage |
| Partner-Check (Basic) | P1 | 3 Tage |
| Mondphasen-Kalender | P2 | 2 Tage |

---

### 12.3 Future Features — Nach Launch

| Feature | Beschreibung | Priorität |
|---------|--------------|-----------|
| **Apple Sign-In** | Social Login | P1 |
| **Google Sign-In** | Social Login | P1 |
| **Freundinnen-Check** | Freundschafts-Kompatibilität | P2 |
| **PDF-Reports (OTP)** | Jahresvorschau + Birth Chart als PDF | P3 |
| **"Deine Signatur" Teilen** | Screenshot + Social Sharing | P3 |
| **Widgets (iOS/Android)** | Tageshoroskop auf Home Screen | P3 |
| **Dark Mode** | Theme-Option | P3 |
| **10 Gods (Bazi)** | Fortgeschrittene Bazi-Analyse (Premium) | P4 |

---

## 13. Offene Fragen & Nächste Schritte

### 13.1 Was fehlt noch?

**Technisch:**
- [ ] Mondphasen-Berechnung (astronomische Bibliothek oder API?)
- [ ] Bazi-Berechnung (chinesischer Kalender, Lichun-Dates)
- [ ] Claude API Prompt-Templates finalisieren
- [ ] Error Handling & Offline-Modus
- [ ] Analytics (Plausible oder PostHog?)
- [ ] Namens-Energie Berechnung (`current_last_name` in Numerologie)

**Design:**
- [ ] Logo & App Icon
- [ ] Onboarding Illustrations
- [ ] Loading States & Animations
- [ ] "Deine Signatur" Dashboard Design finalisieren
- [ ] Dark Mode (später)

**Content:**
- [ ] Sternzeichen-Beschreibungen (DE + EN)
- [ ] Elemente-Beschreibungen (Bazi)
- [ ] Numerologie-Beschreibungen (1-9, 11, 22, 33)
- [ ] Mondphasen-Tipps
- [ ] Prompt-Templates für alle Content-Typen

**Legal:**
- [ ] Datenschutzerklärung (KVKK + GDPR)
- [ ] AGB
- [ ] Impressum

---

### 13.2 Nächste Schritte (priorisiert)

**Diese Woche:**
1. ✅ Projektbeschreibung finalisieren (← FERTIG!)
2. ⏳ Onboarding neu implementieren (2 Schritte + neue Name-Felder)
3. ⏳ "Deine Signatur" Dashboard auf Home Screen
4. ⏳ Claude API Integration testen
5. ⏳ Tageshoroskop-Screen implementieren

**Nächste Woche:**
1. Mondphasen-Berechnung implementieren
2. Edge Function `generate-daily-content` schreiben
3. Settings Screen mit Sprach-Auswahl
4. i18n finalisieren (DE + EN)
5. TestFlight Build erstellen

**Danach:**
1. Early Adopters testen lassen
2. Feedback sammeln
3. Premium-Features implementieren
4. App Store Launch vorbereiten

---

## 14. Zusammenfassung in Stichpunkten

**Nuuray Glow ist:**
- Horoskop-App mit **3-System-Synthese** (Western + Bazi + Numerologie)
- **Freemium-Modell** (Basis kostenlos, Premium 4,99 €/Monat)
- **Claude API** für personalisierte Texte
- **Flutter** (iOS + Android + Web)
- **Supabase** Backend (Auth, DB, Edge Functions)
- **Google Places** für Geburtsort-Koordinaten
- **Deutsch + Englisch** von Anfang an

**Kern-Features:**
1. **"Deine Signatur" Dashboard** (3 Cards: Western, Bazi, Numerologie) — immer sichtbar!
2. **Tageshoroskop** (gecacht + personalisiert für Premium)
3. **Wochenausblick** (Premium)
4. **Monatsenergie** (Premium)
5. **Jahresvorschau** (Premium, On-Demand)
6. **Partner-Check** (Premium)
7. **Mondphasen-Kalender** (Premium)

**Onboarding:**
- **2 Schritte** (Name + Geburtsdaten) — schneller!
- Name-Felder: Display Name (Pflicht), Geburtsname (optional), aktueller Nachname (optional)
- Geburtsort mit Google Places Geocoding

**Differenzierung:**
- **Nicht** nur westliche Astrologie
- **Nicht** generische Texte
- **Sondern:** Einzigartige Synthese, persönlich, tiefgehend

**Zeitplan:**
- MVP: 4-5 Wochen
- Launch: 8-10 Wochen
- Premium-Ausbau: 12-14 Wochen

**Nächste Schritte:**
1. Onboarding neu implementieren (2 Schritte)
2. "Deine Signatur" auf Home Screen
3. Claude API testen
4. Settings mit Sprach-Auswahl
5. i18n finalisieren (DE + EN)

---

**Status:** 🚀 Bereit für Implementierung!
**Änderungen:** ✅ Alle User-Requests eingearbeitet!
