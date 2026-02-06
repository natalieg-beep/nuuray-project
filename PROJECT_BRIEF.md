# NUURAY — Projektbeschreibung & Arbeitsanleitung für Claude

> Dieses Dokument ist deine Grundlage. Lies es vollständig, bevor du mit der Arbeit beginnst.

---

## 1. Was ist NUURAY?

NUURAY ist eine Markenfamilie aus drei Apps, die Frauen dabei unterstützen, sich selbst besser zu verstehen — durch die Synthese von westlicher Astrologie, chinesischer Astrologie (Bazi) und Numerologie.

Der Name kommt von **arabisch *nuur*** (Licht) + **türkisch *ay*** (Mond) = **Mondlicht**.

Die drei Apps sind:

| App | Claim | Zielgruppe | Kern-Feature |
|-----|-------|------------|--------------|
| **Nuuray Glow** | Kosmische Unterhaltung | Frauen 20-40, die Horoskope lieben, aber die üblichen langweilig finden | Tageshoroskop als Synthese aus Western + Bazi + Numerologie |
| **Nuuray Tide** | Zyklus & Mond | Frauen, die ihren Zyklus tracken und Mondphasen einbeziehen wollen | Zyklustracking mit Mondphasen-Overlay und Stimmungsprognose |
| **Nuuray Path** | Coaching & Selbsterkenntnis | Frauen, die sich aktiv weiterentwickeln wollen | Personalisierte Coaching-Journey basierend auf dem Geburts-Chart |

### Das Besondere (USP)

Die meisten Horoskop-Apps zeigen nur westliche Astrologie. NUURAY kombiniert **drei Systeme** zu einer einzigen, stimmigen Aussage:

- **Westliche Astrologie**: Sonnenzeichen, Mondzeichen, Aszendent → beschreibt die Persönlichkeitsstruktur
- **Bazi (Vier Säulen des Schicksals)**: Day Master, Elemente → beschreibt die energetische Konstitution
- **Numerologie**: Lebenszahl, Ausdruckszahl → beschreibt den Lebensweg und die Talente

Diese Synthese passiert nicht als Auflistung ("Dein Sonnenzeichen sagt X, dein Bazi sagt Y"), sondern als **ein einziger, stimmiger Text**, der alle drei Perspektiven verwebt. Das ist die Aufgabe der Claude API.

---

## 2. Wer entwickelt?

Eine Person. Solo-Entwicklerin. Kein Team, kein Budget für externe Entwickler.

**Wichtig für deine Arbeit als Claude:**
- Jede Entscheidung muss **pragmatisch** sein. Kein Overengineering.
- Wenn du zwischen "elegant aber komplex" und "einfach aber funktionierend" wählen musst: **Wähle einfach.**
- Ich kann nicht drei verschiedene Technologien gleichzeitig lernen. Halte den Stack konsistent.
- Ich werde Fragen stellen. Erkläre mir Dinge, wenn ich frage — aber überfrachte mich nicht ungefragt mit Theorie.
- Ich arbeite in Phasen. Manchmal intensiv, manchmal mit Pausen. Der Code muss so geschrieben sein, dass ich nach 2 Wochen Pause wieder einsteigen kann.

**Mein technischer Hintergrund:**
- Ich bin keine ausgebildete Entwicklerin, aber ich lerne schnell und verstehe Konzepte gut.
- Ich arbeite mit Flutter/Dart (lerne ich gerade) und habe Grundverständnis für Datenbanken, APIs und App-Architektur.
- Du bist mein Co-Entwickler. Nicht mein Assistent, der blind Befehle ausführt — sondern jemand, der mitdenkt, warnt wenn etwas problematisch ist, und Alternativen vorschlägt.

**Standort & Unternehmen:**
- Türkei (İzmir), Firma: Be Hamarat Group Teknoloji
- Apple Developer Account und Google Play Account werden über die Firma betrieben
- Relevante Regulierung: KVKK (türkisches Datenschutzgesetz, ähnlich GDPR) + GDPR für EU-Nutzer

---

## 3. Die Architektur im Überblick

### Drei Apps, ein Backend

Die drei Apps sind **eigenständige Flutter-Apps** mit separaten Einträgen in App Store und Google Play. Aber sie teilen sich:

```
┌─────────────────────────────────────────────────────┐
│                    SHARED LAYER                      │
├─────────────┬─────────────────┬─────────────────────┤
│ nuuray_core │   nuuray_api    │     nuuray_ui       │
│ Models      │   Supabase      │     Theme           │
│ Berechnungen│   Claude API    │     Widgets         │
│ Logik       │   Repositories  │     i18n            │
├─────────────┴─────────────────┴─────────────────────┤
│                    SUPABASE                          │
│  Auth │ PostgreSQL │ Edge Functions │ Storage        │
└─────────────────────────────────────────────────────┘
         ↑               ↑               ↑
    Nuuray Glow     Nuuray Tide     Nuuray Path
```

### Warum drei separate Apps statt einer Super-App?

- **Verschiedene Zielgruppen**: Horoskop-Scroller ≠ Zyklus-Tracker ≠ Coaching-Suchende
- **Unabhängige Monetarisierung**: Jede App hat ihr eigenes Preismodell
- **Risiko-Isolation**: Wenn eine App floppt, sterben die anderen nicht mit
- **Fokussierte Positionierung**: Im App Store rankt eine spezialisierte App besser als ein Gemischtwarenladen

### Entwicklungsreihenfolge

**Glow zuerst**, weil:
1. Es die **komplexeste Backend-Komponente erzwingt** (Geburtsdaten-Engine), die alle drei Apps brauchen
2. Es die **breiteste Zielgruppe** hat für schnellste Marktvalidierung
3. Es **günstiger zu testen** ist als eine Zyklus-App (keine Health-Data-Compliance anfangs)
4. Die Mondphasen-API, die hier gebaut wird, dient allen drei Apps

---

## 4. Die Geburtsdaten-Engine (Kern-Komponente)

Das ist das technische Herzstück des gesamten Projekts. Alle drei Apps basieren darauf.

### Input
- Geburtsdatum (Pflicht)
- Geburtszeit (Optional — ermöglicht Aszendent + Bazi-Stunde)
- Geburtsort (Optional — ermöglicht präziseren Aszendent)

### Output: BirthChart
Ein BirthChart-Objekt enthält:

**Westliche Astrologie:**
- Sonnenzeichen + Grad (aus Geburtsdatum)
- Mondzeichen + Grad (aus Geburtsdatum + -zeit, Berechnung über Mondposition)
- Aszendent + Grad (aus Geburtsdatum + -zeit + -ort)

**Bazi (Vier Säulen):**
- Jahressäule: Heavenly Stem + Earthly Branch
- Monatssäule: Heavenly Stem + Earthly Branch
- Tagessäule: Heavenly Stem (= Day Master) + Earthly Branch
- Stundensäule: Heavenly Stem + Earthly Branch (nur mit Geburtszeit)
- Dominantes Element (abgeleitet)

**Numerologie:**
- Lebenszahl (Life Path Number): Quersumme des Geburtsdatums
- Ausdruckszahl (Expression Number): Aus dem vollständigen Namen (wenn vorhanden)
- Seelenzahl (Soul Urge Number): Aus den Vokalen des Namens (wenn vorhanden)

### Wichtige Implementierungs-Hinweise

- **Mondzeichen-Berechnung ist komplex.** Der Mond wechselt alle ~2,5 Tage das Zeichen. Für eine exakte Berechnung brauchen wir eine astronomische Bibliothek oder eine API. Für den MVP reicht eine Lookup-Tabelle oder eine vereinfachte Berechnung.
- **Bazi-Berechnung** folgt einem festen Schema basierend auf dem chinesischen Kalender. Der Jahreswechsel ist NICHT am 1. Januar, sondern am Beginn des Frühlings (立春, Lichun, meist 3.-5. Februar). Das muss korrekt implementiert werden.
- **Numerologie** ist vergleichsweise einfach (Quersummen-Berechnungen), aber die Meisterzahlen 11, 22, 33 dürfen NICHT weiter reduziert werden.
- **Aszendent-Berechnung** erfordert Geburtszeit + Geburtsort (für Längen-/Breitengrad). Ohne diese Daten: Aszendent = null. Das ist OK.

---

## 5. Die Claude API Rolle

Die Claude API ist der "Texter" des Projekts. Sie nimmt die berechneten Daten und macht daraus **lesbare, persönliche, inspirierende Texte**.

### Was Claude NICHT tut:
- Astrologie berechnen (das macht die Geburtsdaten-Engine)
- Mondphasen berechnen (das macht die Mondphasen-API)
- Daten speichern (das macht Supabase)

### Was Claude TUT:
- Aus strukturierten Daten (Sternzeichen + Bazi + Numerologie + Mondphase) einen stimmigen, personalisierten Text generieren
- Den Ton an die jeweilige App anpassen
- In Deutsch und Englisch schreiben

### Ton pro App:

| App | Ton | Vergleich |
|-----|-----|-----------|
| Glow | Unterhaltsam, überraschend, staunend, lebendig | Wie eine kluge Freundin, die dir beim Kaffee spannende Dinge erzählt |
| Tide | Achtsam, empowernd, im Fluss, körperbewusst | Wie eine Yoga-Lehrerin, die auch Wissenschaft versteht |
| Path | Warm, reflektiert, tiefgehend, einladend | Wie eine weise Mentorin, die nie belehrt sondern Fragen stellt |

### Kosten-Strategie:

Claude API Calls kosten Geld. Deshalb:

1. **Tageshoroskope vorab generieren** — nicht pro User, sondern pro Sternzeichen. Ein Cron-Job generiert morgens 12 × 2 = 24 Texte (12 Zeichen × 2 Sprachen). Das sind ~24 API-Calls pro Tag, nicht pro User.
2. **Personalisierung als zweite Schicht** — Der gecachte Basistext wird für Premium-User mit einem kurzen Claude-Call personalisiert (persönlicher Bazi-Bezug, Mondzeichen-Bezug). Dieser Call ist kürzer und günstiger.
3. **Caching aggressiv nutzen** — Supabase-Tabelle `daily_content` mit Datum als Key.
4. **Model-Auswahl bewusst** — Sonnet für täglichen Content, Opus nur für komplexe Coaching-Journeys in Path.

---

## 6. Monetarisierung

### Glow
| Tier | Features | Preis |
|------|----------|-------|
| Free | Tageshoroskop (Basistext), Mondphase heute, Sternzeichen-Info | kostenlos |
| Premium | Synthese-Horoskop, Wochen/Monatsüberblick, Partner-Check, erweitertes Mondzeichen | ~4,99 €/Monat oder ~39,99 €/Jahr |
| OTP (Einmalkauf) | PDF-Reports (Jahresprognose, Partner-Analyse) | ~9,99-19,99 € |

### Tide (später)
| Tier | Features | Preis |
|------|----------|-------|
| Free | Basis-Tracking, Kalender, Mondphase | kostenlos |
| Premium | Stimmungsprognose, Phasen-Tipps, Insights | ~4,99 €/Monat |

### Path (später)
| Tier | Features | Preis |
|------|----------|-------|
| 3-Tage-Test | Profil-Überblick, 3 Tage Coaching-Einblick | kostenlos |
| Premium | Volle Coaching-Journey, Journaling, Fortschritt | ~9,99 €/Monat (höchster ARPU) |

### Technische Umsetzung:
- **In-App Purchases** über Apple StoreKit / Google Play Billing (Pflicht für digitale Inhalte in Apps)
- **RevenueCat** als Abstraktionsschicht evaluieren
- **Subscription-Status serverseitig verifizieren** — nie nur clientseitig
- Website-basierte PDF-Reports optional über **Lemon Squeezy** (PayPal-Auszahlung in die Türkei möglich)

---

## 7. Sprachen & i18n

- **Deutsch und Englisch gleichzeitig ab Tag 1.** Kein Nachgedanke.
- **Deutsch ist die Entwicklungssprache.** Code-Kommentare, Commit-Messages, Docs: Deutsch.
- **Variablennamen, Klassen, Funktionen: Englisch.** Das ist Dart/Flutter-Konvention.
- **ARB-Dateien** in `packages/nuuray_ui/lib/src/l10n/`. Deutsch (`app_de.arb`) wird zuerst geschrieben.
- **Claude API Content** wird in der jeweiligen User-Sprache generiert. Der Prompt enthält `{sprache}` als Variable.

---

## 8. Datenschutz & Compliance

### KVKK (Türkei) + GDPR (EU)
- Nutzer müssen der Datenverarbeitung aktiv zustimmen (Opt-in, kein Opt-out)
- Datenschutzerklärung in Deutsch und Englisch
- Recht auf Datenlöschung implementieren (Account + alle Daten löschen)
- Daten werden in Supabase gespeichert (Region: EU bevorzugt für GDPR)
- **Geburtsdaten und Zyklusdaten sind sensible Daten** — extra Sorgfalt bei Verschlüsselung und Zugriffskontrolle

### Besondere Vorsicht bei Tide (Zyklusdaten)
- Gesundheitsdaten unterliegen strengeren Regeln
- Apple HealthKit-Integration: Separate Genehmigung nötig
- **Für MVP: Keine HealthKit-Integration.** Eigenes Tracking in Supabase reicht.

---

## 9. Arbeitsanleitung für Claude

### Grundprinzipien

1. **MVP first.** Wenn du bei einer Entscheidung unsicher bist, frag dich: "Braucht Glow das für den MVP?" Wenn nein → Backlog. Erstelle ein TODO-Kommentar und mach weiter.

2. **Ein Schritt nach dem anderen.** Erstelle nicht die gesamte App auf einmal. Arbeite Feature für Feature. Teste jedes Feature isoliert, bevor du zum nächsten gehst.

3. **Shared Packages zuerst.** Bevor du App-spezifischen Code schreibst, stell sicher, dass das Shared Package die nötigen Models/Services/Widgets bereitstellt.

4. **Erkläre was du tust.** Schreib Kommentare im Code (auf Deutsch). Wenn du eine Architektur-Entscheidung triffst, erkläre kurz warum.

5. **Warne mich.** Wenn du etwas siehst, das problematisch werden könnte (Skalierung, Kosten, Sicherheit), sag es sofort. Nicht erst wenn es zu spät ist.

6. **Kein Overengineering.** Kein SOLID um des SOLID willen. Keine abstrakten Interfaces, die nur eine Implementierung haben werden. Keine Design Patterns, die die Komplexität erhöhen ohne echten Nutzen.

7. **Halte es lesbar.** Ich muss den Code nach 2 Wochen Pause noch verstehen. Klare Namen, logische Struktur, kurze Funktionen.

### Workflow für neue Features

```
1. Prüfe: Braucht das Feature neue Models? → nuuray_core erweitern
2. Prüfe: Braucht das Feature neue API-Calls? → nuuray_api erweitern
3. Prüfe: Braucht das Feature neue DB-Tabellen? → Migration schreiben
4. Prüfe: Braucht das Feature neue Widgets? → nuuray_ui erweitern
5. Implementiere die UI in der jeweiligen App
6. Teste
7. Commit
```

### Wenn du unsicher bist

- **Technische Frage:** Recherchiere kurz, schlage mir 2 Optionen vor mit Vor-/Nachteilen, lass mich entscheiden.
- **Architektur-Frage:** Schlage die einfachere Lösung vor. Nenne die elegantere als Alternative für später.
- **Inhaltliche Frage (Astrologie, Bazi, Numerologie):** Frag mich. Ich kenne die Materie.
- **Design-Frage:** Halte dich an das Theme in `nuuray_ui`. Im Zweifel: Minimalistisch, viel Weißraum, warme Farben.

### Dateien, die du kennen solltest

| Datei | Inhalt | Wann relevant |
|-------|--------|---------------|
| `CLAUDE.md` | Technische Konventionen, Stack, Code-Stil | Immer |
| `docs/PROJECT_BRIEF.md` | Dieses Dokument — Vision, Architektur, Kontext | Bei grundlegenden Fragen |
| `supabase/migrations/` | DB-Schema | Bei Datenbank-Änderungen |
| `packages/nuuray_core/` | Shared Models & Berechnungen | Bei neuen Features |
| `packages/nuuray_api/lib/src/prompts/` | Claude API Prompt-Templates | Bei Content-Generierung |
| `packages/nuuray_ui/lib/src/theme/` | Farben, Typografie, Spacing | Bei UI-Arbeit |
| `packages/nuuray_ui/lib/src/l10n/` | Übersetzungen DE/EN | Bei neuen UI-Texten |

### Aktuelle Phase: Glow MVP

Die aktuelle Priorität ist **Nuuray Glow MVP**. Features in dieser Reihenfolge:

1. ✅ Projektstruktur (fertig)
2. ✅ DB-Schema (fertig — Migrations 001, 002, 003)
3. ✅ Shared Models (UserProfile mit allen Onboarding-Feldern)
4. ✅ Auth (Supabase: Email Authentication)
   - Login/Signup Screens implementiert
   - AuthService mit signIn/signUp/signOut/resetPassword
   - Auth-State Management via Riverpod
   - Router mit Auth-Redirects
   - TODO: Apple Sign-In + Google Sign-In
5. ✅ Onboarding Flow: Geburtsdaten eingeben
   - 3-Schritte Flow (Name, Geburtsdatum/-zeit, Geburtsort)
   - Name-Felder: displayName (Rufname), fullFirstNames, lastName, birthName
   - Geburtsdatum (Pflicht), Geburtszeit (Optional mit hasBirthTime Flag)
   - Geburtsort: Text-Input (Google Places für später geplant)
   - Speicherung in Supabase `profiles` Tabelle
   - Upsert-Logik (UPDATE wenn Profil durch Auth-Trigger existiert)
6. ✅ Splash Screen mit Routing-Logik
   - Prüft Auth-Status und Onboarding-Status
   - Leitet zu /login, /onboarding oder /home weiter
7. ✅ Basic Home Screen
   - Header mit personalisierter Begrüßung (Tageszeit-abhängig)
   - Tagesenergie-Card mit Gradient (Placeholder Content)
   - Horoskop-Card mit Energie-Indikatoren (Hardcoded Schütze)
   - Quick Action Cards (Mondkalender, Partner-Check - Coming Soon)
   - Debug: Logout Button
8. 🔨 **Cosmic Profile Dashboard (NÄCHSTER SCHRITT)**
   - Western Astrology Card (Sonne/Mond/Aszendent + Grade)
   - Bazi Card (Vier Säulen, Day Master, Element Balance Chart)
   - Numerology Card (Life Path, Expression, Soul Urge Numbers)
   - Freezed Models: CosmicProfile, WesternAstrology, Bazi, Numerology
   - Calculator Services in nuuray_core
   - Supabase: cosmic_profiles Tabelle mit JSONB + RLS
   - Premium-Gate für Detailansichten
9. ⬜ Geburtsdaten-Engine: Westliche Berechnung (Sonnenzeichen, Mondzeichen, Aszendent)
10. ⬜ Geburtsdaten-Engine: Bazi-Berechnung (Vier Säulen, Day Master, Elemente)
11. ⬜ Geburtsdaten-Engine: Numerologie (Life Path, Expression, Soul Urge)
12. ⬜ Mondphasen-Berechnung / API
13. ⬜ Tageshoroskop-Ansicht (gecachter Content + Claude API)
14. ⬜ Mondphasen-Kalender
15. ⬜ Wochen- und Monatsüberblick (Premium)
16. ⬜ Partner-Check (Premium)
17. ⬜ Premium-Gating + In-App Purchase
18. ⬜ Push-Notifications

**Nächster Schritt:** Cosmic Profile Dashboard implementieren (Feature 8)

**Implementierungs-Details für Dashboard:**
- Drei separate Widgets: WesternAstrologyCard, BaziCard, NumerologyCard
- Gradient-basiertes Design mit eigenen Farbpaletten pro System
- "Mehr erfahren" Button führt zu Premium-Details
- Calculator-Services berechnen aus Geburtsdaten + Name
- Caching in cosmic_profiles Tabelle (1 Row pro User)
- i18n für alle Sternzeichen, Elemente, Zahlen-Beschreibungen

---

## 10. Qualitätsstandards

### Code
- Kein `print()` — immer `log()` oder Logger
- Const überall wo möglich
- Keine Magic Numbers oder hardgecodete Strings in der UI (immer i18n)
- Fehlerbehandlung: Nie silent fails. Immer ein sinnvoller Fehlerzustand in der UI.
- RLS auf jeder Supabase-Tabelle. Keine Ausnahmen.

### UI/UX
- **Ladezeiten mit Skeletons oder Shimmer**, nicht mit Spinnern
- **Leere Zustände** (keine Daten) immer gestalten — nie leerer Screen
- **Fehler-Zustände** immer gestalten — mit Retry-Button
- **Offline-fähig** für gecachten Content (Tageshoroskop lokal cachen)
- **Accessibility**: Semantics-Labels, ausreichende Kontraste, Mindestgröße für Touch-Targets

### Performance
- Bilder: WebP, lazy loading
- Listen: `ListView.builder` statt `ListView`
- Keine unnötigen Rebuilds (Riverpod hilft hier)
- API-Calls: Caching, Debouncing bei Suche

---

## 11. Zusammenfassung in einem Satz

NUURAY ist eine App-Familie, die Frauen durch die einzigartige Synthese von westlicher Astrologie, Bazi und Numerologie unterstützt — und wir bauen sie pragmatisch, Schritt für Schritt, mit Flutter, Supabase und der Claude API, wobei Glow die erste App ist.
