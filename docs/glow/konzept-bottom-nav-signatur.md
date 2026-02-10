# Konzept: Bottom Navigation + Signatur Screen

> Dieses Dokument beschreibt das Konzept für zwei zusammenhängende Features.
> Bitte in **zwei Schritten** umsetzen: Erst Bottom Nav, dann Signatur Screen.
> Kein Overengineering. Lies CLAUDE.md und docs/PROJECT_BRIEF.md für Kontext.

---

## Teil 1: Bottom Navigation

### Überblick

Die App bekommt eine persistente Bottom Navigation Bar mit zunächst **3 Tabs**.
Der aktuelle Homescreen wird zum ersten Tab. Zwei neue Screens kommen dazu.

### Tabs

| # | Label | Icon | Screen | Status |
|---|-------|------|--------|--------|
| 1 | **Home** | `Icons.auto_awesome` (Sparkles) | Bestehender Homescreen | Existiert bereits |
| 2 | **Signatur** | Stern-Kompass-Icon (Custom oder `Icons.explore` als Fallback) | Neuer Screen: `SignatureScreen` | Neu bauen (siehe Teil 2) |
| 3 | **Mond** | `Icons.nightlight_round` (Mondsichel) | Neuer Screen: `MoonCalendarScreen` | Platzhalter mit "Coming Soon"-State |
| 4 | **Insights** | Sparkle-Lupe (Custom oder `Icons.saved_search` als Fallback) | Neuer Screen: `InsightsScreen` | Platzhalter mit "Coming Soon"-State |

### Design-Vorgaben

- **Stil**: Zum bestehenden Glow-Theme passend (warm, golden, minimalistisch)
- **Aktiver Tab**: Goldene/warme Akzentfarbe aus dem Theme (`NuurayColors`)
- **Inaktiver Tab**: Gedämpftes Grau/Beige
- **Hintergrund**: Weiß oder das helle Creme aus dem bestehenden Theme
- **Keine Labels wenn Platz knapp** – aber Labels bevorzugt wenn sie passen
- **Animierter Übergang** zwischen Tabs: Kein Seitenübergang, direkt wechseln (kein PageView-Swipe)

### Technische Umsetzung

- `BottomNavigationBar` oder `NavigationBar` (Material 3) in einer neuen `MainShell`-Widget
- **GoRouter**: Nested Navigation mit `ShellRoute` für die Bottom Nav
- Jeder Tab behält seinen eigenen State (kein Rebuild beim Tab-Wechsel)
- Die bestehende Homescreen-Logik bleibt unverändert, wird nur in die Shell eingebettet
- **Platzhalter-Screens** (Mond, Insights): Einfaches `Scaffold` mit zentriertem Text "Kommt bald" + passendem Icon. Kein Aufwand hier – das sind nur Platzhalter.

### Navigation innerhalb der Tabs

- Vom Homescreen kann weiterhin auf Detail-Screens navigiert werden (z.B. Tippen auf Archetyp-Card → navigiert zum Signatur-Tab)
- Die drei Mini-Cards auf dem Homescreen (Western, Chinesisch, Numerologie) navigieren zum Signatur-Tab
- Die unteren "Mondkalender"- und "Partner-Check"-Cards navigieren zu den entsprechenden Tabs
- Settings-Icon (Zahnrad oben rechts) bleibt als Push-Navigation, nicht als Tab

### Dateien (erwartete Struktur)

```
apps/glow/lib/
├── src/
│   ├── app/
│   │   ├── main_shell.dart          ← NEU: Shell mit BottomNav
│   │   └── router.dart              ← ANPASSEN: ShellRoute einbauen
│   ├── features/
│   │   ├── home/                    ← BESTEHT: Homescreen
│   │   ├── signature/               ← NEU: Signatur Screen (Teil 2)
│   │   ├── moon_calendar/           ← NEU: Platzhalter
│   │   └── insights/                ← NEU: Platzhalter
```

### i18n Keys (in nuuray_ui ARB-Dateien ergänzen)

```json
{
  "navHome": "Home",
  "navSignature": "Signatur",
  "navMoon": "Mond",
  "navInsights": "Insights",
  "comingSoonTitle": "Kommt bald",
  "comingSoonMessage": "Dieses Feature wird gerade entwickelt."
}
```

---

## Teil 2: Signatur Screen

### Überblick

Eine vertikal scrollbare Seite, die das vollständige persönliche Profil der Nutzerin zeigt.
Aufgebaut als **modulare Scroll-Seite mit Expandable Cards** – nicht als Tabs, nicht als Unterseiten.

Die Seite heißt **"Deine Signatur"** und zeigt alle drei Systeme (Western, Bazi, Numerologie)
auf einer Seite, mit der Synthese als verbindendes Element.

### Seitenstruktur (von oben nach unten)

```
┌─────────────────────────────────────────────┐
│  HERO: Archetyp                             │
│  ─────────────────────                      │
│  Titel: "Die feine Strategin"               │
│  Ein-Satz-Essenz (Mini-Synthese)            │
│  → Für alle User sichtbar (Freemium)        │
│  → Gecacht, kein Live-API-Call              │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│  SEKTION 1: Westliche Astrologie ☀️         │
│  ─────────────────────                      │
│  Immer sichtbar:                            │
│    • Sonne: Schütze (8.00°)                 │
│    • Mond: Waage (10.77°)                   │
│    • Aszendent: Löwe (23.00°)               │
│    • Element: Feuer                         │
│                                             │
│  [Expandable] Mehr erfahren:                │
│    Free: Kurzbeschreibung pro Position      │
│    Premium: Ausführliche Beschreibungen,     │
│    Aspekte zwischen Positionen              │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│  SEKTION 2: Bazi (四柱) 🐷                  │
│  ─────────────────────                      │
│  Immer sichtbar:                            │
│    • Tages-Meister: Xin-Schwein             │
│    • Vier Säulen: Jahr/Monat/Tag/Stunde     │
│    • Dominantes Element: Wasser             │
│                                             │
│  [Expandable] Mehr erfahren:                │
│    Free: Kurzbeschreibung Day Master        │
│    Premium: Ausführliche Elementanalyse,     │
│    Säulen-Interaktionen                     │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│  SEKTION 3: Numerologie 🔢                  │
│  ─────────────────────                      │
│  Immer sichtbar:                            │
│    • Lebensweg: 8 (Macht & Manifestation)   │
│    • Rufname: 8                             │
│    • Challenges: 8, 0, 8, 8                 │
│    • Karmic Lessons: 4, 8                   │
│    • Bridges: 2, 7                          │
│                                             │
│  [Expandable] Mehr erfahren:                │
│    Free: Kurzbeschreibung Lebenszahl        │
│    Premium: Alle Zahlen ausführlich,         │
│    Challenges & Bridges erklärt             │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│  PREMIUM-BEREICH: Deine Kosmische Synthese  │
│  ─────────────────────                      │
│  Free-User sehen:                           │
│    • Sichtbarer Titel + Teaser-Satz         │
│    • "Deine persönliche Synthese             │
│       freischalten" Button                  │
│    • KEIN Blur/Grayout – sauber und klar    │
│                                             │
│  Premium-User sehen:                        │
│    • Vollständiger Synthese-Text von Claude  │
│    • Verwebt alle drei Systeme              │
│    • Personalisiert auf die Nutzerin        │
└─────────────────────────────────────────────┘
```

### Expandable Cards – Verhalten

- **Standardzustand**: Eingeklappt (nur Basisdaten sichtbar)
- **Tap auf "Mehr erfahren"**: Klappt sanft auf (AnimatedCrossFade oder ähnlich)
- **Freemium**: Aufklappen zeigt Kurzbeschreibungen (2-3 Sätze pro Position)
- **Premium**: Aufklappen zeigt ausführliche Texte (1-2 Absätze pro Position)
- **Premium-Gating innerhalb der Card**: Wenn Free-User aufklappt, zeige den Kurztext + einen dezenten Hinweis "Ausführliche Analyse mit Premium" am Ende. Kein harter Block.

### Hero-Sektion: Archetyp + Mini-Synthese

- Visuell identisch mit der bestehenden Archetyp-Card auf dem Homescreen (goldener Gradient)
- **Mini-Synthese**: Ein einzelner Satz, der alle drei Systeme verbindet
  - Beispiel: "Deine feurige Schütze-Seele schmiedet mit der feinen Klarheit des Yin-Metalls goldene Träume, während der Lebenspfad 8 dich zu wahrem Wohlstand und innerer Fülle führt."
  - Wird beim Onboarding von Claude mitgeneriert und in `signature_profiles` gecacht
  - Kein laufender API-Aufwand – einmalig pro User

### Freemium vs. Premium – Übersicht

| Bereich | Free | Premium |
|---------|------|---------|
| Archetyp-Titel + Mini-Synthese | ✅ | ✅ |
| Basisdaten (Zeichen, Säulen, Zahlen) | ✅ | ✅ |
| Kurzbeschreibungen (aufklappbar) | ✅ | ✅ |
| Ausführliche Beschreibungen | ❌ (Teaser) | ✅ |
| Kosmische Synthese (unten) | ❌ (Titel + CTA) | ✅ |

### Datenquellen

Die Daten kommen aus dem bestehenden `BirthChart`-Modell in `nuuray_core`.
Hier sollte nichts Neues berechnet werden – der Signatur Screen ist rein eine **Darstellungs-Schicht**.

| Daten | Quelle | Bereits vorhanden? |
|-------|--------|-------------------|
| Sonnenzeichen, Mond, Aszendent | `BirthChart.westernChart` | ✅ Ja |
| Bazi-Säulen, Day Master, Element | `BirthChart.baziChart` | ✅ Ja |
| Lebenszahl, Namenszahl, etc. | `BirthChart.numerologyProfile` | ✅ Ja |
| Archetyp-Titel | `signature_profiles` Tabelle | ✅ Ja (Homescreen nutzt das schon) |
| Mini-Synthese (Ein-Satz) | `signature_profiles.mini_synthesis` | ⬜ Neues Feld nötig |
| Kurzbeschreibungen | Statische Texte oder Supabase | ⬜ Klären (siehe unten) |
| Ausführliche Beschreibungen | Claude-generiert, gecacht | ⬜ Klären (siehe unten) |
| Kosmische Synthese | Claude-generiert, gecacht | ⬜ Klären (siehe unten) |

### Offene Fragen (für Natalie, nicht für Claude Code)

1. **Kurzbeschreibungen**: Sollen die statisch sein (pro Zeichen/Element/Zahl ein fester Text in der App) oder dynamisch von Claude generiert? Statisch = kein API-Aufwand, dynamisch = persönlicher.

2. **Mini-Synthese**: Wird beim Onboarding mitgeneriert – brauchen wir ein neues Feld `mini_synthesis` in `signature_profiles`? Oder existiert das schon als Teil des Archetyp-Texts?

3. **Premium-Texte Caching**: Wenn eine Premium-Userin die ausführlichen Texte einmal generiert bekommt – cachen wir die dauerhaft in Supabase (`signature_details` Tabelle)? Empfehlung: Ja, die ändern sich nicht.

### UI Design-Hinweise

- **Farbwelt**: Gleiche warme Goldtöne wie der Homescreen
- **Cards**: Abgerundete Ecken, leichter Schatten, Creme-Hintergrund (wie bestehende Cards)
- **Expandable-Animation**: Sanft, ~300ms, kein hartes Einblenden
- **Icons**: Bestehende Emoji-/Icon-Sprache beibehalten (☀️ für Western, 🐷 für Bazi, Zahlen-Icons für Numerologie)
- **Premium-CTA**: Warmer goldener Button, nicht aggressiv. Text wie "Deine Synthese entdecken" statt "JETZT KAUFEN"
- **Spacing**: Großzügig. Viel Weißraum zwischen den Sektionen
- **Scroll**: Smooth scrolling, kein Paging

### Dateien (erwartete Struktur)

```
apps/glow/lib/src/features/signature/
├── signature_screen.dart              ← Hauptscreen mit ScrollView
├── widgets/
│   ├── archetype_hero_section.dart    ← Hero oben (Archetyp + Mini-Synthese)
│   ├── western_section.dart           ← Expandable Card: Westlich
│   ├── bazi_section.dart              ← Expandable Card: Bazi
│   ├── numerology_section.dart        ← Expandable Card: Numerologie
│   ├── expandable_card.dart           ← Shared Widget für aufklappbare Sektionen
│   └── premium_synthesis_section.dart ← Premium-Bereich unten
```

### i18n Keys (ergänzen)

```json
{
  "signatureTitle": "Deine Signatur",
  "signatureArchetype": "Dein Archetyp",
  "signatureWestern": "Westliche Astrologie",
  "signatureBazi": "Bazi (四柱)",
  "signatureNumerology": "Numerologie",
  "signatureSynthesis": "Deine Kosmische Synthese",
  "signatureLearnMore": "Mehr erfahren",
  "signatureCollapse": "Weniger anzeigen",
  "signaturePremiumTeaser": "Entdecke, wie deine drei kosmischen Signaturen zusammenwirken.",
  "signatureUnlockSynthesis": "Deine Synthese entdecken",
  "signaturePremiumHint": "Ausführliche Analyse mit Premium verfügbar",
  "signatureSun": "Sonne",
  "signatureMoon": "Mond",
  "signatureAscendant": "Aszendent",
  "signatureElement": "Element",
  "signatureDayMaster": "Tages-Meister",
  "signaturePillars": "Vier Säulen",
  "signatureDominantElement": "Dominantes Element",
  "signatureLifePath": "Lebensweg",
  "signatureChallenges": "Challenges",
  "signatureKarmicLessons": "Karmic Lessons",
  "signatureBridges": "Bridges"
}
```

---

## Umsetzungsreihenfolge

### Schritt 1: Bottom Navigation
1. `MainShell` mit `BottomNavigationBar` erstellen
2. `GoRouter` auf `ShellRoute` umbauen
3. Bestehenden Homescreen einbetten
4. Platzhalter-Screens für Signatur, Mond, Insights
5. Navigation von Homescreen-Cards zu den richtigen Tabs
6. Testen: Tab-Wechsel, State-Erhalt, Deep Links

### Schritt 2: Signatur Screen
1. `SignatureScreen` als ScrollView mit den Sektionen
2. `ExpandableCard`-Widget bauen (wiederverwendbar für alle drei Sektionen)
3. Hero-Sektion mit Archetyp (Daten aus bestehendem Provider)
4. Drei Sektionen mit Basisdaten (aus BirthChart)
5. Expandable-Logik mit Freemium/Premium-Unterscheidung
6. Premium-Synthese-Bereich unten (zunächst nur CTA, Content kommt später)
7. i18n Keys einpflegen
8. Testen

### Was NICHT in diesem Schritt:
- ❌ Claude API Calls für Beschreibungstexte (kommt separat)
- ❌ Mondkalender-Logik (nur Platzhalter)
- ❌ Insights/Reports-Logik (nur Platzhalter)
- ❌ Premium-Gating / In-App Purchase (kommt separat)
- ❌ Mini-Synthese generieren (kommt mit Claude API Integration)
