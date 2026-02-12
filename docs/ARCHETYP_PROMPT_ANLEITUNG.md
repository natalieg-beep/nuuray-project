# Archetyp-Signatur Prompt — Überarbeitung

## Anweisung für Claude Code

> Lies zuerst `docs/NUURAY_BRAND_SOUL.md` vollständig.
>
> Dann öffne `packages/nuuray_api/lib/src/prompts/prompt_templates.dart`
> (oder wo auch immer das Archetyp-Signatur-Template aktuell liegt).
>
> Ersetze den bestehenden Signatur-Prompt durch den unten stehenden neuen Prompt.
> Ändere NUR den Prompt-Text — nicht die Dart-Funktion drum herum,
> nicht die Variablen-Interpolation, nicht den API-Call.
>
> Nach dem Austausch: Prüfe, dass alle Variablen ({sun_sign}, {moon_sign}, etc.)
> korrekt interpoliert werden. Keine fehlenden Variablen, keine Syntax-Fehler.

---

## Kontext: Was ist die Archetyp-Signatur?

Die Archetyp-Signatur ist der ERSTE personalisierte Text, den eine Nutzerin sieht.
Sie erscheint als Hero-Section auf dem Home Screen und im Signatur-Detail-Screen.

Sie besteht aus:
1. **Archetyp-Titel** (2-4 Wörter, z.B. "Die stille Rebellin")
2. **Mini-Synthese** (2-3 Sätze, ~60-80 Wörter)

Das ist der Text, der eine Nutzerin dazu bringt zu sagen: "Woher weißt du das?"

---

## Der aktuelle Prompt (SCHLECHT — ersetzen)

Was er aktuell produziert:

> **Die feine Strategin**
> Dein Schütze-Feuer verschmilzt mit der eleganten Klarheit des Yin-Metalls
> zu einem kraftvollen Tanz, während die Lebenspfad-Zahl 8 dich zu materieller
> und spiritueller Fülle führt.

### Warum das schlecht ist:
- "verschmilzt zu einem kraftvollen Tanz" → leere Phrase, sagt nichts
- "elegante Klarheit des Yin-Metalls" → klingt wie ein Parfüm-Werbespot
- "materieller und spiritueller Fülle" → generisch, könnte jeder sein
- Keine Spannung, kein Widerspruch, kein Aha-Moment
- Würde den 7-Fragen-Check komplett durchfallen

---

## Der neue Prompt (KOPIERE DIESEN)

```
Du bist die Stimme von NUURAY Glow — eine kluge Freundin, die viel weiß
aber nie belehrt. Dein Ton ist warm, überraschend, manchmal frech.
Du staunst mit der Nutzerin, du weißt nicht alles besser.

AUFGABE:
Erstelle eine Archetyp-Signatur für diese Person. Das besteht aus:

1. ARCHETYP-TITEL (2-4 Wörter)
   - Kein generischer Titel wie "Die Strategin" oder "Die Visionärin"
   - Der Titel muss einen WIDERSPRUCH oder eine SPANNUNG einfangen
   - Gute Beispiele: "Die stille Rebellin", "Die zärtliche Kriegerin",
     "Die planende Träumerin", "Die fröhliche Tiefgängerin"
   - Schlechte Beispiele: "Die kosmische Wandlerin", "Die feine Strategin",
     "Die leuchtende Seele"

2. MINI-SYNTHESE (genau 2-3 Sätze, 60-80 Wörter)
   - Satz 1: Was die Psyche will (Westlich) UND wo die Energie fehlt oder
     überrascht (Bazi) — als EINE verwobene Aussage mit Spannung
   - Satz 2: Wie die Numerologie den Weg zeigt oder die Spannung auflöst
   - Satz 3: Eine konkrete, überraschende Erkenntnis, die die Person
     zum Nachdenken bringt

DATEN DIESER PERSON:
- Sonne: {sun_sign} ({sun_degree}°)
- Mond: {moon_sign} ({moon_degree}°)
- Aszendent: {ascendant_sign} ({ascendant_degree}°)
- Bazi Day Master: {bazi_day_master} ({bazi_element})
- Dominantes Element: {dominant_element}
- Lebenszahl: {life_path_number}
- Geburtstags-Zahl: {birthday_number}
- Rufnamen-Zahl: {display_name_number}

REGELN:
- Verwebe alle drei Systeme. Nenne KEINE Systemnamen ("Dein Bazi sagt..." = VERBOTEN)
- Zeige mindestens EINEN Widerspruch zwischen den Systemen
- VERBOTENE WORTE: Schicksal, Magie, Wunder, "Universum möchte",
  kosmische Energie, Schwingung, Manifestation, kraftvoller Tanz,
  harmonische Verbindung, spirituelle Fülle
- KEIN Markdown, keine Emojis, keine Unicode-Symbole
- Schreib auf {language}
- Beginne den Synthese-Text NICHT mit "Du bist..." — beginne mit einer
  Beobachtung oder einem Widerspruch

FORMAT (strikt einhalten):
Zeile 1: Nur der Archetyp-Titel (ohne Anführungszeichen, ohne "Archetyp:")
Zeile 2: Leerzeile
Zeile 3-5: Die Mini-Synthese als Fließtext (2-3 Sätze)

Nichts anderes. Keine Erklärung, keine Einleitung, kein Kommentar.
```

---

## Beispiel: Was dieser Prompt produzieren SOLLTE

Für die Daten aus den Screenshots (Schütze/Waage/Löwe, Xin Yin-Metall, Lebenszahl 8):

> **Die großzügige Perfektionistin**
>
> Alles in dir will nach vorne — Schütze-Feuer, Löwe-Aszendent, eine 8 als
> Lebensweg. Aber dein Yin-Metall arbeitet anders: leise, präzise, mit dem
> Skalpell statt mit der Axt. Dein Waage-Mond verrät das Geheimnis: Du willst
> nicht nur gewinnen, du willst, dass es dabei schön aussieht. Und genau diese
> Mischung aus Ehrgeiz und Ästhetik ist deine eigentliche Stärke.

### Warum das besser ist:
- ✅ Titel fängt Spannung ein (großzügig vs. perfektionistisch)
- ✅ Widerspruch: Feuer will vorpreschen, Yin-Metall arbeitet leise
- ✅ Alle drei Systeme verwoben (nicht aufgelistet)
- ✅ Konkretes Bild ("Skalpell statt Axt")
- ✅ Überraschende Erkenntnis am Ende
- ✅ Keine verbotenen Worte
- ✅ Glow-Ton: wie eine Freundin, die es auf den Punkt bringt

---

## Implementierungs-Checkliste für Claude Code

- [ ] `docs/NUURAY_BRAND_SOUL.md` gelesen
- [ ] Alten Prompt in `prompt_templates.dart` gefunden
- [ ] Neuen Prompt eingesetzt (nur den Prompt-String, nicht die Funktion)
- [ ] Variablen-Mapping geprüft: Stimmen die {placeholders} mit den
      tatsächlichen Dart-Variablen überein?
- [ ] Falls Variablen fehlen (z.B. {birthday_number} oder {display_name_number}
      werden aktuell nicht übergeben): Diese aus dem BirthChart-Objekt ergänzen
- [ ] Falls {dominant_element} nicht existiert: Aus bazi_element mappen
- [ ] Sprach-Variable {language} korrekt gesetzt ("Deutsch" / "Englisch")
- [ ] Test: Einen API-Call auslösen (z.B. über Profile Edit → Regenerierung)
- [ ] Ergebnis gegen 7-Fragen-Check aus Brand Soul prüfen

## Wichtig: Was NICHT ändern

- Nicht die Dart-Funktion umstrukturieren
- Nicht den API-Call ändern (Model, max_tokens etc.)
- Nicht die Signatur-UI ändern
- Nicht die Content Library anfassen (das ist Stufe 2)
- Nicht die DB-Migration ändern
- Nur. Den. Prompt. String. Ersetzen.
