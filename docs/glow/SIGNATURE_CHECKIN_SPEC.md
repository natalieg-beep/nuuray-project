# Signatur-Check-In — Feature Spezifikation

> **Status:** 📋 Konzept — bereit für Implementierung
> **Erstellt:** 2026-02-21
> **Abhängigkeit:** Deep Synthesis muss generiert sein (Herzstück)
> **Priorität:** Mittel — vor Launch empfohlen, aber kein MVP-Blocker

---

## Was ist der Signatur-Check-In?

Die Deep Synthesis weiß was jemand **ist** — seine Grundstruktur, seine Muster, sein Preis.

Der Check-In verbindet diese statische Signatur mit dem **dynamischen Jetzt**: Was beschäftigt gerade? Was braucht diese Person konkret heute?

In 3 schnellen Taps beantwortet der User, wo er/sie gerade steht. Die App matcht das mit der bereits gecachten Synthese und liefert eine kurze, direkte Antwort: *Was bedeutet deine Signatur in genau dieser Situation?*

Das ist kein neues Feature — es ist die Synthese, die endlich **antwortfähig** wird.

---

## Wo lebt der Check-In?

**Direkt unter der Deep Synthesis Section** im Signatur-Screen.

```
[Signatur-Screen]
├── Archetyp-Header (Titel + Mini-Synthese)
├── Western Astrology Section
├── Bazi Section
├── Numerologie Section
├── Deep Synthesis Section ← Das Herzstück
│
└── Signatur-Check-In Section ← NEU (nach unten scrollbar)
    ├── 3-Schritt-Fragen (Chips/Buttons)
    └── Ergebnis-Widget (erscheint nach Beantwortung)
```

Kein separater Screen. Kein Modal. Der Flow bleibt im Signatur-Screen — User scrollt nach unten, antwortet, bekommt sofort die Antwort darunter.

---

## Der Flow im Detail

### Schritt 1 — Lebenssituation

**Überschrift:** "Was beschäftigt dich gerade am meisten?"

| Option | Icon | Schlüssel |
|--------|------|-----------|
| Arbeit & Karriere | 💼 | `work` |
| Beziehungen | 💛 | `relationships` |
| Ich selbst | 🪞 | `self` |
| Energie & Gesundheit | ⚡ | `energy` |

Design: 2×2 Grid aus großen Tap-Chips. Beim Tap: Sofortiger Farbwechsel (selected), Schritt 2 erscheint mit Slide-Animation darunter.

---

### Schritt 2 — Emotionale Lage

**Überschrift:** "Wie fühlt es sich gerade an?"

| Option | Icon | Schlüssel |
|--------|------|-----------|
| Chaotisch | 🌀 | `chaotic` |
| Erschöpft | 😴 | `exhausted` |
| Aufgeladen | 🔥 | `energized` |
| Taub / Leer | 😶 | `numb` |

---

### Schritt 3 — Bedürfnis

**Überschrift:** "Was brauchst du gerade?"

| Option | Icon | Schlüssel |
|--------|------|-----------|
| Klarheit | 🧭 | `clarity` |
| Ruhe | 🌿 | `rest` |
| Antrieb | ⚡ | `momentum` |
| Ehrlichkeit | 🔑 | `honesty` |

---

### CTA nach Schritt 3

Button: **"Zeig mir was meine Signatur dazu sagt"**

→ Löst den Claude-Call aus (oder Cache-Hit)
→ Ergebnis-Widget erscheint darunter mit Slide-In Animation

---

## Das Ergebnis-Widget

```
┌─────────────────────────────────────────┐
│  Deine Signatur in dieser Situation     │
│  ─────────────────────────────────────  │
│                                         │
│  [2-3 Sätze aus der Synthese, destil-   │
│   liert auf diese spezifische Kombi-    │
│   nation. Konkret, direkt, ehrlich.]    │
│                                         │
│  ─────────────────────────────────────  │
│  💡 Impuls für heute                    │
│                                         │
│  [1 konkrete Handlung, passt zur        │
│   gewählten Situation + Signatur]       │
│                                         │
│  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─   │
│  Wenn du tiefer gehen möchtest:         │
│                                         │
│  [Report-Card — sanfter Hinweis]        │
└─────────────────────────────────────────┘
```

---

## Der Claude-Call für das Ergebnis

### Wichtig: Kein neuer langer Call

Der Synthese-Text ist bereits generiert und gecacht. Der Check-In-Call bekommt:
- Den gecachten Synthese-Text (~800 Tokens)
- Die 3 Antworten des Users (~15 Tokens)
- Einen kurzen Prompt (~80 Tokens)

Output: 2-3 Sätze + 1 Impuls (~120-150 Tokens)

**Kosten: ~$0.003-0.004 pro Call**

### Caching-Strategie

64 mögliche Kombinationen (4 × 4 × 4). Jede Kombination wird in Supabase gecacht:

```sql
-- Neue Tabelle: signature_checkin_results
CREATE TABLE signature_checkin_results (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL,
  checkin_key TEXT NOT NULL,         -- z.B. "work_exhausted_clarity"
  language TEXT NOT NULL DEFAULT 'de',
  result_text TEXT NOT NULL,         -- Die 2-3 Sätze
  impulse_text TEXT NOT NULL,        -- Der konkrete Impuls
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, checkin_key, language)
);
```

`checkin_key` = `{kategorie}_{gefühl}_{bedürfnis}` → z.B. `"work_exhausted_clarity"`

Bei einem neuen Check-In wird zuerst der Cache geprüft. Nur wenn kein Eintrag vorhanden, neuer Claude-Call.

### Prompt-Architektur

```
SYSTEM-PROMPT (kurz):
Du bist die Stimme von NUURAY Glow.
Du hast diese Person bereits durch ihre tiefe Signatur begleitet.
Jetzt fragt sie sich: Was bedeutet meine Signatur GENAU JETZT für mich?

Antworte direkt. 2-3 Sätze die sitzen. Kein "Als [Zeichen]..." —
nur die Wahrheit die diese Kombination hat.
Danach: Ein konkreter Impuls für heute (1 Satz, kein "vielleicht" oder "versuche").

[ANSPRACHE-Block hier — gender-aware]

USER-PROMPT:
Hier ist die tiefe Synthese dieser Person:
---
{synthese_text}
---

Sie hat angegeben:
- Was sie gerade beschäftigt: {kategorie_de}
- Wie es sich anfühlt: {gefühl_de}
- Was sie braucht: {bedürfnis_de}

Destilliere aus der Synthese 2-3 Sätze die genau das adressieren.
Dann 1 konkreter Impuls für heute.

Format:
[2-3 Sätze Fließtext]

Impuls: [1 Satz]
```

---

## Report-Mapping (Sanfter Hinweis)

Am Ende des Ergebnis-Widgets erscheint — nur wenn Reports verfügbar — ein dezenter Hinweis:

```
"Wenn du das weiter erkunden möchtest:"
[Report-Card mit Titel + Kurzbeschreibung + Preis + "Mehr erfahren" Button]
```

| Kategorien-Auswahl | Empfohlener Report |
|--------------------|--------------------|
| `work` | The Purpose Path (€6,99) — Berufung & Ausdruck |
| `relationships` | SoulMate Finder (€4,99) — Beziehungsmuster |
| `self` | Shadow & Light (€7,99) — Schatten-Integration |
| `energy` | Body Vitality (€5,99) — Lebensenergie |

**Design:** Kleine Card mit goldener Umrandung, nicht aufdringlich. Der Report ist "Coming Soon" — Tap öffnet Info-Modal oder Snackbar bis Funktionalität live ist.

---

## Premium-Gating Überlegung

**Option A (empfohlen für Launch):** Check-In ist für alle sichtbar, aber das **Ergebnis** ist Premium-only.
- Gratis-User: Sehen die 3 Fragen, tippen Antworten → Paywall-Screen erscheint
- "Aktiviere Premium um deine Signatur in Aktion zu sehen"
- Starker Conversion-Moment weil User bereits emotionalen Input gegeben hat

**Option B:** Check-In komplett frei bis Launch, später Premium
- Einfacher zu bauen
- Weniger Reibung für frühe User/Beta-Tester

→ **Entscheidung beim Implementieren treffen** je nach Launch-Timing

---

## Dateien die neu erstellt werden

```
apps/glow/lib/src/features/signature/
├── widgets/
│   ├── signature_checkin_section.dart       ← Haupt-Widget (3 Fragen + CTA)
│   └── checkin_result_widget.dart           ← Ergebnis-Anzeige + Report-Hinweis
├── models/
│   └── checkin_selection.dart               ← Enum/Model für die 3 Antworten
└── providers/
    └── checkin_provider.dart                ← StateProvider + FutureProvider.family

apps/glow/lib/src/core/services/
└── claude_api_service.dart                  ← generateCheckinResponse() hinzufügen

supabase/migrations/
└── 20260221_add_checkin_results.sql         ← Neue Tabelle
```

### Änderungen an bestehenden Dateien

```
apps/glow/lib/src/features/signature/screens/signature_screen.dart
  → SignatureCheckinSection unterhalb von DeepSynthesisSection einfügen

apps/glow/lib/src/core/services/claude_api_service.dart
  → generateCheckinResponse() Methode hinzufügen
  → _buildCheckinPrompt() helper
```

---

## i18n

Alle 3 Fragen + alle 12 Antwortoptionen + Ergebnis-Labels müssen in `app_de.arb` und `app_en.arb`.

Schlüssel-Beispiele:
```
"checkinTitle": "Was beschäftigt dich gerade am meisten?"
"checkinCategoryWork": "Arbeit & Karriere"
"checkinCategoryRelationships": "Beziehungen"
"checkinCategorySelf": "Ich selbst"
"checkinCategoryEnergy": "Energie & Gesundheit"
"checkinCtaButton": "Zeig mir was meine Signatur dazu sagt"
"checkinResultTitle": "Deine Signatur in dieser Situation"
"checkinImpulseLabel": "💡 Impuls für heute"
"checkinReportHint": "Wenn du tiefer gehen möchtest:"
```

---

## Implementierungs-Reihenfolge

1. **Supabase Migration** — `signature_checkin_results` Tabelle
2. **Model** — `CheckinSelection` (Kategorie, Gefühl, Bedürfnis als Enums)
3. **UI: SignatureCheckinSection** — 3 Fragen mit Chips, CTA-Button, statisch
4. **ClaudeApiService** — `generateCheckinResponse()` Methode
5. **Provider** — `checkinProvider` (FutureProvider.family, Cache-First)
6. **UI: CheckinResultWidget** — Ergebnis + Impuls + Report-Hinweis
7. **Integration** — In SignatureScreen einfügen (nach DeepSynthesisSection)
8. **i18n** — ARB-Einträge DE + EN
9. **(Optional) Premium-Gating** — je nach Entscheidung

---

## Zeitschätzung

| Schritt | Aufwand |
|---------|---------|
| Migration + Model | 30 Min |
| Fragen-UI (Chips, Animation) | 1-2 Std |
| Claude-Call + Prompt | 1 Std |
| Provider + Caching | 1 Std |
| Ergebnis-Widget + Report-Hinweis | 1-2 Std |
| Integration + i18n | 1 Std |
| **Gesamt** | **~6-8 Stunden** |

---

## Offen zu klären beim Implementieren

- [ ] Premium-Gating: Sofort oder nach Launch?
- [ ] Soll das Ergebnis gespeichert werden (History)? Oder immer neu generierbar?
- [ ] Animation: Erscheint das Ergebnis sofort oder mit kurzer Ladezeit (besser für Wirkung)?
- [ ] Kann der User die Antworten ändern und einen neuen Check-In machen? (Ja — neue 3 Taps)

---

*Erstellt: 2026-02-21 | Bereit für Implementierung in neuer Session*
