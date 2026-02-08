# NUURAY — Archetyp-System (Konzeption)

> Dieses Dokument beschreibt das Archetyp-System für Nuuray Glow.
> Es ist die Referenz für die Implementierung in `nuuray_core` und die UI im Dashboard.

---

## 1. Was ist der Archetyp?

Jede Nutzerin bekommt bei Nuuray einen persönlichen **Archetyp** — eine einzige, greifbare Identität, die aus der Synthese von drei Systemen entsteht:

- **Westliche Astrologie** (Sonnenzeichen, Mondzeichen, Aszendent)
- **Bazi / Chinesische Astrologie** (Day Master, Dominantes Element)
- **Numerologie** (Lebenszahl / Life Path Number)

Der Archetyp ist das Erste, was die Nutzerin nach dem Onboarding sieht. Er ist ihr "Ich bin..." bei Nuuray.

### Beispiel-Ergebnis im UI

```
✨ Die Visionärin
   Die Yin-Wasser-Visionärin

   "In dir verbindet sich die traumwandlerische Tiefe
    des Wassers mit einer Intuition, die andere erst
    in Jahren entwickeln. Dein Schütze-Feuer gibt dir
    den Mut, deinen Visionen auch zu folgen."
```

---

## 2. Aufbau: Drei Bausteine

Der Archetyp besteht aus drei Schichten, die zusammen eine "Signatur" ergeben:

| Schicht | Quelle | Anzahl | Beispiel |
|---------|--------|--------|----------|
| **Name** (Substantiv) | Lebenszahl (Numerologie) | 12 | "Die Visionärin" |
| **Farbe** (Adjektiv) | Bazi Day Master | 10 | "Die Yin-Wasser-..." |
| **Signatur-Satz** | Claude API (einmalig) | individuell | Verwebt alle drei Systeme |

### Warum Lebenszahl als Name-Anker?

- **Sofort verständlich**: "Die Pionierin" sagt sofort etwas. "Das Yang-Metall" muss erst erklärt werden.
- **Teilbar**: "Ich bin die Strategin — was bist du?" funktioniert auf Instagram.
- **Emotional**: Die Namen beschreiben Rollen und Missionen, nicht abstrakte Elemente.
- **Bazi als Differenzierung**: Das Bazi-Element ist das, was Nuuray besonders macht — aber als Adjektiv/Farbe, nicht als Hauptidentität. So entdecken Nutzerinnen Bazi als Bonus, ohne überfordert zu werden.

---

## 3. Die 12 Archetyp-Namen (Lebenszahl → Name)

> Hardcoded in `nuuray_core`. Muss in i18n (ARB-Dateien) für DE + EN gepflegt werden.

| Lebenszahl | Name (DE) | Name (EN) | Kern-Energie |
|-----------|-----------|-----------|--------------|
| 1 | Die Pionierin | The Pioneer | Unabhängigkeit, Mut, Neuanfang |
| 2 | Die Diplomatin | The Diplomat | Harmonie, Empathie, Verbindung |
| 3 | Die Kreative | The Creative | Ausdruck, Freude, Kommunikation |
| 4 | Die Architektin | The Architect | Struktur, Bodenhaftung, Aufbau |
| 5 | Die Abenteurerin | The Adventurer | Freiheit, Wandel, Vielseitigkeit |
| 6 | Die Mentorin | The Mentor | Fürsorge, Heilung, Verantwortung |
| 7 | Die Sucherin | The Seeker | Analyse, Tiefe, Spiritualität |
| 8 | Die Strategin | The Strategist | Fülle, Macht, Manifestation |
| 9 | Die Humanistin | The Humanitarian | Weisheit, Abschluss, Mitgefühl |
| 11 | Die Visionärin | The Visionary | Inspiration, Intuition (Meisterzahl) |
| 22 | Die Baumeisterin | The Master Builder | Vision in Materie bringen (Meisterzahl) |
| 33 | Die Heilerin | The Healer | Bedingungslose Liebe (Meisterzahl) |

**Hinweis:** Meisterzahlen (11, 22, 33) dürfen bei der Berechnung NICHT weiter reduziert werden. Das ist bereits in der Numerologie-Engine so implementiert.

---

## 4. Die 10 Bazi-Farben (Day Master → Adjektiv)

> Hardcoded in `nuuray_core`. Muss in i18n (ARB-Dateien) für DE + EN gepflegt werden.

| Day Master | Element | Adjektiv (DE) | Adjektiv (EN) | Energie-Qualität |
|-----------|---------|---------------|---------------|------------------|
| Jia (甲) | Yang-Holz | Die standfeste | The steadfast | Wie ein großer Baum: stark, aufrecht, wachsend |
| Yi (乙) | Yin-Holz | Die anpassungsfähige | The adaptable | Wie eine Ranke: flexibel, elegant, beharrlich |
| Bing (丙) | Yang-Feuer | Die strahlende | The radiant | Wie die Sonne: warm, sichtbar, großzügig |
| Ding (丁) | Yin-Feuer | Die feinfühlige | The perceptive | Wie eine Kerzenflamme: intim, fokussiert, inspirierend |
| Wu (戊) | Yang-Erde | Die beständige | The grounded | Wie ein Berg: zuverlässig, stabil, beschützend |
| Ji (己) | Yin-Erde | Die nährende | The nurturing | Wie fruchtbare Erde: fürsorglich, geduldig, fruchtbar |
| Geng (庚) | Yang-Metall | Die entschlossene | The resolute | Wie ein Schwert: direkt, mutig, erneuernd |
| Xin (辛) | Yin-Metall | Die feine | The refined | Wie ein Juwel: präzise, ästhetisch, wertvoll |
| Ren (壬) | Yang-Wasser | Die fließende | The flowing | Wie ein Ozean: tiefgründig, kraftvoll, unaufhaltsam |
| Gui (癸) | Yin-Wasser | Die intuitive | The intuitive | Wie Morgentau: still, klar, durchdringend |

**Wichtig für die Fachfrau (Natalie):** Diese Adjektive sind Vorschläge basierend auf klassischen Bazi-Beschreibungen. Bitte validieren und ggf. anpassen — du kennst die Materie besser.

---

## 5. Der Signatur-Satz (Claude API)

### Wann wird er generiert?

**Einmalig beim Onboarding**, nachdem die Geburtsdaten-Engine das BirthChart berechnet hat. Der Satz wird in der DB gecacht und nie erneut generiert (es sei denn, die Nutzerin ändert ihre Geburtsdaten).

### Was geht in den Prompt?

Nur die relevanten Datenpunkte — nicht das gesamte Chart:

```
- Archetyp-Name: "Die Strategin" (aus Lebenszahl 8)
- Bazi-Farbe: "Die entschlossene" (aus Day Master Geng/Yang-Metall)
- Sonnenzeichen: Schütze
- Mondzeichen: Waage (falls vorhanden)
- Aszendent: Löwe (falls vorhanden)
- Dominantes Bazi-Element: Wasser
- Sprache: Deutsch
```

### Prompt-Template (Vorschlag für `nuuray_api/lib/src/prompts/`)

```
Du bist der Texter für Nuuray Glow, eine Astrologie-App für Frauen.

Erstelle einen persönlichen Signatur-Satz (2-3 Sätze, max. 200 Zeichen) 
für folgendes Profil:

Archetyp: {archetyp_name} ({lebenszahl})
Bazi-Energie: {day_master_adjektiv} ({day_master_element})
Sonnenzeichen: {sonnenzeichen}
Mondzeichen: {mondzeichen}
Aszendent: {aszendent}
Dominantes Element: {dominantes_element}

Regeln:
- Verwebe alle drei Systeme zu EINEM stimmigen Satz — keine Auflistung.
- Ton: Warm, staunend, wie eine kluge Freundin die etwas Besonderes entdeckt hat.
- Beginne NICHT mit "Du bist" — das steht bereits darüber als Archetyp-Name.
- Verwende keine Fachbegriffe (kein "Day Master", kein "Bazi", kein "Lebenszahl").
- Sprache: {sprache}
- Gib NUR den Signatur-Satz zurück, keine Erklärung, kein Intro.
```

### Kosten-Schätzung

- ~200 Input Tokens + ~80 Output Tokens pro Call
- Sonnet: ca. $0.001 pro Nutzerin
- Einmalig pro Nutzerin → bei 10.000 Nutzerinnen = ca. $10 total
- **Vernachlässigbar.**

### Caching

Der generierte Satz wird gespeichert in:
- **Supabase:** Feld `signature_text` in der `profiles`-Tabelle (oder alternativ in `birth_charts`)
- **Lokal:** Im BirthChart-Objekt gecacht (Offline-Fähigkeit)

### Wann neu generieren?

- Nutzerin ändert Geburtsdaten → altes Chart ungültig → neuer Signatur-Satz
- Nutzerin ändert Namen (Numerologie: Ausdruckszahl) → optional neu generieren
- Ansonsten: **nie.** Der Satz ist stabil.

---

## 6. Dashboard-Layout (Home Screen)

### Neue Hierarchie (von oben nach unten)

```
┌─────────────────────────────────────────────────┐
│  Guten Tag, Natalie                              │
│  Sonntag, 8. Februar                             │
├─────────────────────────────────────────────────┤
│                                                  │
│  ✨ Die entschlossene Strategin                  │  ← Archetyp (hardcoded)
│                                                  │
│  "In dir verbindet sich die präzise Kraft..."    │  ← Signatur-Satz (Claude, gecacht)
│                                                  │
├──────────┬──────────┬──────────┤                 │
│  ☀️      │  🔥      │  🔢      │                 │
│ Western  │  Bazi    │  Numero  │  ← 3 Mini-Widgets (tappbar)
│ Schütze  │  Geng    │  LP 8    │
│ Waage 🌙 │ Wasser💧 │  Jahr 6  │
│ Löwe ⬆️  │          │          │
└──────────┴──────────┴──────────┘

── Tagesenergie ──────────────────────────────────
🌙 Zunehmender Mond in Steinbock
"Heute ist ein guter Tag für Struktur..."

── Dein Tageshoroskop ────────────────────────────
Schütze ♐
"Liebe Schützin, der Kosmos flüstert dir..."

── Persönlich für dich ───────────────────────────
[Dein Bazi heute]  [Deine Numerologie heute]

── Entdecke mehr ─────────────────────────────────
[Mondkalender]  [Partner-Check]
```

### Interaktionen

- **Archetyp-Bereich (oben):** Tap → navigiert zur ausführlichen Signatur-Seite (die bereits existierende "Deine Signatur"-Seite)
- **Mini-Widgets:** Tap auf einzelnes Widget → navigiert zum Detail des jeweiligen Systems (Western/Bazi/Numerologie)
- **Tageshoroskop:** Wie bisher, scrollbar

### Design-Hinweise

- Der Archetyp-Bereich sollte sich **visuell abheben** (z.B. leichter Gradient, etwas mehr Padding, goldener Akzent)
- Die drei Mini-Widgets sind **gleichgroß**, in einer `Row` mit `Expanded`
- Der Archetyp-Name ist **größer** als der Signatur-Satz
- Signatur-Satz in *Kursiv* oder leicht reduzierter Opazität → wirkt wie ein persönliches Zitat

---

## 7. Datenfluss

```
Onboarding abgeschlossen
  → BirthChart wird berechnet (nuuray_core, bereits implementiert)
  → Lebenszahl → Archetyp-Name (hardcoded Mapping, nuuray_core)
  → Day Master → Bazi-Adjektiv (hardcoded Mapping, nuuray_core)
  → Claude API Call: Signatur-Satz generieren (nuuray_api)
  → Signatur-Satz in profiles-Tabelle speichern (Supabase)
  → Dashboard rendert: Archetyp + Widgets + Tages-Content
```

### Offline-Verhalten

- Archetyp-Name + Bazi-Adjektiv: **Immer verfügbar** (hardcoded + lokales BirthChart)
- Signatur-Satz: **Lokal gecacht** nach erstem Load
- Falls noch kein Signatur-Satz (z.B. API-Fehler beim Onboarding): Zeige nur den Archetyp-Namen ohne Satz. Retry beim nächsten App-Start.

---

## 8. Implementierungs-Hinweise

### Was muss neu gebaut werden?

| Komponente | Paket | Aufwand | Beschreibung |
|-----------|-------|---------|--------------|
| Archetyp-Mapping (Lebenszahl → Name) | `nuuray_core` | Klein | Map/Enum mit 12 Einträgen |
| Bazi-Adjektiv-Mapping (Day Master → Adjektiv) | `nuuray_core` | Klein | Map/Enum mit 10 Einträgen |
| Archetyp-Model | `nuuray_core` | Klein | `Archetype` Klasse mit name, adjective, signatureText |
| Signatur-Prompt-Template | `nuuray_api` | Klein | Prompt-Datei + Service-Methode |
| Signatur-Satz generieren + cachen | `nuuray_api` | Mittel | Claude API Call + Supabase Write |
| DB: `signature_text` Feld | `supabase/migrations` | Klein | ALTER TABLE profiles ADD COLUMN |
| Dashboard-UI: Archetyp-Header | `apps/glow` | Mittel | Neues Widget oben im Home Screen |
| Dashboard-UI: 3 Mini-Widgets | `apps/glow` | Mittel | Row mit 3 tappbaren System-Cards |
| i18n: Archetyp-Namen + Adjektive | `nuuray_ui` | Klein | 22 neue Keys (12 Namen + 10 Adjektive, je DE+EN) |

### Was muss NICHT gebaut werden?

- Kein neues Auth
- Keine neuen Berechnungen (BirthChart, Lebenszahl, Day Master existieren bereits)
- Keine neue Supabase-Tabelle (nur ein Feld in `profiles`)
- Kein neues Routing (Detail-Seiten existieren bereits)

### Reihenfolge der Implementierung

1. **DB-Migration:** `signature_text` Feld zu `profiles` hinzufügen
2. **nuuray_core:** Archetyp-Mapping (Name + Adjektiv) als Enums/Maps
3. **nuuray_core:** `Archetype` Model-Klasse
4. **i18n:** ARB-Keys für alle 12 Namen + 10 Adjektive (DE + EN)
5. **nuuray_api:** Prompt-Template für Signatur-Satz
6. **nuuray_api:** Service-Methode: generateSignature() → Claude Call + Supabase Cache
7. **apps/glow:** Dashboard-UI umbauen (Archetyp-Header + Mini-Widgets)
8. **Onboarding-Flow:** Nach Chart-Berechnung → Signatur generieren lassen

### RLS-Hinweis

Das neue Feld `signature_text` in `profiles` ist durch die bestehende RLS-Policy abgedeckt (`auth.uid() = user_id`). Keine neue Policy nötig.

### KVKK/GDPR-Hinweis

Der Signatur-Satz ist aus Geburtsdaten abgeleitet → sensible Daten. Bei Account-Löschung muss er mit gelöscht werden. Da er in `profiles` liegt, wird er durch die bestehende Lösch-Logik mit erfasst. Kein separater Handlungsbedarf.

---

## 9. Offene Fragen (für Natalie)

- [ ] **Bazi-Adjektive validieren:** Passen die vorgeschlagenen Adjektive zu deinem Verständnis der Day Master? (Abschnitt 4)
- [ ] **Archetyp-Namen validieren:** Passen die Lebenszahl-zu-Name-Zuordnungen? (Abschnitt 3)
- [ ] **Signatur-Satz Länge:** 2-3 Sätze (ca. 150-200 Zeichen) — oder kürzer/länger?
- [ ] **Sonnenzeichen im Dashboard:** Soll das Sonnenzeichen-Icon/Symbol neben dem Archetyp-Namen erscheinen, oder reicht es im Western-Widget?
- [ ] **Social Sharing:** Soll der Archetyp teilbar sein? (Screenshot/Story-Format) → Wenn ja: Backlog für Phase 2.

Validierung deiner offenen Fragen:
Bazi-Adjektive: Die Liste in Abschnitt 4 ist fachlich sehr sauber. Jia/Yang-Holz als "standfest" und Yi/Yin-Holz als "anpassungsfähig" fängt die Essenz der Stems sehr gut ein.

Archetyp-Namen: Die Zuordnung der Lebenszahlen (z.B. 8 = Strategin, 2 = Diplomatin) ist intuitiv und für westliche Nutzerinnen sofort greifbar.

Sonnenzeichen im Dashboard: Ich würde das Icon des Sonnenzeichens nicht direkt neben den großen Archetyp-Namen setzen. Lass den Archetyp allein strahlen ("✨ Die intuitive Visionärin"). Das Sonnenzeichen-Icon hat seinen Platz im Western-Widget darunter.
