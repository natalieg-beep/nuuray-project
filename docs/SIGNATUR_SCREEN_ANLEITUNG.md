# Signatur-Screen Struktur — Anleitung für Claude Code

## Kontext

Der Signatur-Detail-Screen ("Deine Signatur") bekommt eine klare Dramaturgie:

```
┌─────────────────────────────────────┐
│  ARCHETYP HERO                      │  ← Titel + Mini-Synthese
│  (identisch mit Home Screen)        │     (aus derselben DB-Quelle!)
├─────────────────────────────────────┤
│  ÜBERLEITUNG                        │  ← Neuer kurzer Text (i18n)
│  "Deine Signatur setzt sich..."    │
├─────────────────────────────────────┤
│  Westliche Astrologie              │
│  Sonne / Mond / Aszendent          │  ← Bestehendes bleibt
├─────────────────────────────────────┤
│  Chinesisches Bazi                  │
│  Day Master / Vier Säulen          │  ← Bestehendes bleibt
├─────────────────────────────────────┤
│  Numerologie                        │
│  Lebenszahl, Zahlen, Energien      │  ← Bestehendes bleibt
├─────────────────────────────────────┤
│  KOSMISCHE SYNTHESE                 │  ← Der tiefe Synthese-Text
│  (Premium oder Claude-generiert)   │     (später: Stufe 3)
└─────────────────────────────────────┘
```

## Was zu tun ist

### 1. Archetyp-Hero: Gleiche Datenquelle wie Home Screen

Der Archetyp-Block oben auf dem Signatur-Screen MUSS denselben Titel
und denselben Synthese-Text anzeigen wie der Home Screen.

- Finde heraus, woher der Home Screen seinen Archetyp-Titel + Text liest
- Finde heraus, woher der Signatur-Screen seinen Archetyp-Titel + Text liest
- Falls das zwei verschiedene Quellen sind: Den Signatur-Screen auf
  dieselbe Quelle umstellen
- Es darf nur EINE Quelle geben (ein DB-Feld, ein Provider)
- Falls der Signatur-Screen aktuell einen eigenen Claude-Call macht:
  Diesen entfernen. Nur noch aus der gecachten/gespeicherten Quelle lesen.

### 2. Überleitung einfügen

Zwischen dem Archetyp-Hero und der ersten Sektion ("Westliche Astrologie")
einen kurzen Überleitungs-Text einfügen.

**Stil:** Dezent, kein eigener Card-Container. Einfach Text mit etwas Abstand.
Gleicher Stil wie die Untertitel unter den Sektions-Überschriften
(z.B. wie "Deine Planetenpositionen" oder "Die Zahlen deines Lebens").

**i18n-Keys und Texte — in die ARB-Dateien einfügen:**

```
// app_de.arb
"signatureOverviewIntro": "Deine Signatur setzt sich aus drei Perspektiven zusammen — jede zeigt einen anderen Aspekt von dir.",
"signatureOverviewOutro": "Und so fügt sich alles zusammen:"

// app_en.arb
"signatureOverviewIntro": "Your signature is made up of three perspectives — each reveals a different aspect of you.",
"signatureOverviewOutro": "And this is how it all comes together:"
```

**Platzierung:**
- `signatureOverviewIntro` → nach dem Archetyp-Hero, vor "Westliche Astrologie"
- `signatureOverviewOutro` → vor der "Kosmische Synthese" Sektion ganz unten

### 3. Sektions-Untertitel aktualisieren (optional, Brand Voice)

Die bestehenden Untertitel könnten etwas mehr NUURAY-Stimme vertragen.
Das ist optional und kein Muss für jetzt, aber falls du sie anfasst:

```
// AKTUELL (generisch)
"Deine grundlegende kosmische Identität"
"Deine Vier Säulen des Schicksals"
"Die Zahlen deines Lebens"

// BESSER (Brand Voice, optional)
// app_de.arb
"signatureWesternSubtitle": "Wer du bist — deine psychologische Signatur",
"signatureBaziSubtitle": "Was du brauchst — deine energetische Architektur",
"signatureNumerologySubtitle": "Wohin du gehst — dein Seelenrhythmus"

// app_en.arb
"signatureWesternSubtitle": "Who you are — your psychological signature",
"signatureBaziSubtitle": "What you need — your energetic architecture",
"signatureNumerologySubtitle": "Where you're headed — your soul rhythm"
```

Das ist die Sprach-Transformation aus der Brand Soul:
- Western = "Wer bin ich?" → Psyche
- Bazi = "Was brauche ich?" → Energie
- Numerologie = "Wohin gehe ich?" → Seelenweg

### 4. "Kosmische Synthese" Sektion unten

Die existiert schon als Platzhalter (sichtbar in Screenshot 8).
Vorerst NICHT anfassen — das ist Stufe 3.

Aber stelle sicher, dass `signatureOverviewOutro` ("Und so fügt sich alles
zusammen:") direkt VOR dieser Sektion erscheint.

## Checkliste

- [ ] Datenquelle Archetyp: Home + Signatur lesen aus EINER Quelle
- [ ] Alter separater Signatur-Text/Call entfernt (kein "Die kosmische Wandlerin" mehr)
- [ ] i18n-Key `signatureOverviewIntro` in app_de.arb und app_en.arb eingefügt
- [ ] i18n-Key `signatureOverviewOutro` in app_de.arb und app_en.arb eingefügt
- [ ] Überleitung im UI platziert (nach Hero, vor Western)
- [ ] Outro im UI platziert (vor Kosmische Synthese)
- [ ] Optional: Sektions-Untertitel mit Brand Voice aktualisiert
- [ ] Testen: Home Screen und Signatur Screen zeigen identischen Archetyp

## Was NICHT ändern

- Nicht die Sektions-Cards (Western, Bazi, Numerologie) umbauen
- Nicht die expandable Cards ändern
- Nicht die Kosmische Synthese Sektion inhaltlich anfassen
- Nicht den Archetyp-Prompt nochmal ändern (der ist fertig)
- Nicht die Bottom Navigation ändern
