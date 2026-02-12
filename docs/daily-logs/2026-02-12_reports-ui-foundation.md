# Reports UI Foundation — Insights Screen & Settings Integration

**Datum:** 2026-02-12
**Kontext:** Reports UI Structure implementiert (Option A aus GLOW_REPORTS_OTP.md)
**Status:** ✅ UI Foundation komplett — Backend/Funktionalität kommt später

---

## 🎯 Was wurde implementiert

### 1. Bottom Navigation neu sortiert

**Vorher:** `[Home] [Signatur] [Mond] [Insights]`
**Nachher:** `[Home] [Signatur] [Insights] [Mond]`

**Grund:** Insights soll direkt neben Signatur stehen (thematisch zusammenhängend)

**Geänderte Datei:**
- `apps/glow/lib/src/core/widgets/scaffold_with_nav_bar.dart`
  - Index-Mapping angepasst: Insights = 2, Mond = 3
  - Navigation Destinations neu sortiert
  - `_onTabTapped()` Switch-Cases aktualisiert

---

### 2. Insights Screen erstellt (Report-Katalog)

**Neue Datei:** `apps/glow/lib/src/features/insights/screens/insights_screen.dart`

**Alle 10 Reports aus Beyond Horoscope integriert:**

#### 📊 Report-Kategorien:

**💖 Beziehungen**
1. **SoulMate Finder** (€4,99) — Partner-Check

**💫 Seele & Purpose**
2. **Soul Purpose** (€7,99) — Seelenmission
3. **Shadow & Light** (€7,99) — Schatten-Integration

**💼 Berufung & Erfolg**
4. **The Purpose Path** (€6,99) — Berufung

**💰 Geld & Erfolg**
5. **Golden Money Blueprint** (€7,99) — Geld-Energie

**🌱 Gesundheit & Energie**
6. **Body Vitality** (€5,99) — Lebensenergie

**✨ Lifestyle & Entwicklung**
7. **Aesthetic Style Guide** (€5,99) — Kosmischer Stil
8. **Cosmic Parenting** (€6,99) — Elternschaft nach den Sternen

**🌍 Ortswechsel & Veränderung**
9. **Relocation Astrology** (€7,99) — Idealer Ort

**📅 Prognosen**
10. **Yearly Energy Forecast** (€9,99) — Persönliches Jahr

#### UI-Features:

**Report Cards:**
- Material Design mit `Container` + `InkWell`
- Farbige Icons (individuell pro Report)
- Titel + Subtitle + Beschreibung
- Preis-Badge (Gold: `#D4AF37`)
- "Coming Soon" Badge (grau)
- Tap-Feedback: Zeigt Snackbar "Coming Soon!"

**Layout:**
- `CustomScrollView` mit `SliverToBoxAdapter` + `SliverList`
- Header: "Entdecke deine Tiefen" + Subtitle
- Kategorien als Section-Headers
- Spacing zwischen Reports und Kategorien

**Design-System:**
- Background: `#FFFBF5` (AppColors.background)
- Icons: Material Icons (outlined)
- Border-Radius: 16px
- Shadow: Subtle (0.04 alpha, 8px blur)

---

### 3. Settings Screen erweitert

**Datei:** `apps/glow/lib/src/features/settings/screens/settings_screen.dart`

**Neue Section: "Meine Inhalte"**

Zwischen "Account" und "Information" eingefügt:

```
Settings:
├─ Sprache
├─ Benachrichtigungen
├─ Account
│  └─ Profil bearbeiten
├─ Meine Inhalte  ← NEU!
│  ├─ Meine Reports (Gekaufte Reports & Analysen)
│  └─ Premium (Dein Abo verwalten)
├─ Information
│  ├─ Privacy
│  ├─ Terms
│  └─ About
└─ Logout
```

**"Meine Reports":**
- Icon: `Icons.auto_stories_outlined` (Buch)
- Titel: "Meine Reports"
- Subtitle: "Gekaufte Reports & Analysen"
- Aktuell: Snackbar "Coming Soon!"
- Später: Navigiert zu Report-Bibliothek

**"Premium":**
- Icon: `Icons.stars_outlined`
- Titel: "Premium"
- Subtitle: "Dein Abo verwalten"
- Aktuell: Snackbar "Coming Soon!"
- Später: Premium-Status + Abo-Verwaltung

---

## 📋 Was NICHT implementiert wurde (absichtlich)

**Bewusst als Platzhalter gelassen:**
- ❌ Report-Preview-Screens (Teaser-Content, Sample-Seiten)
- ❌ Report-Kauf-Flow (In-App Purchase)
- ❌ Report-Generierung (Claude API)
- ❌ Report-Viewer (PDF anzeigen)
- ❌ Report-Bibliothek (gekaufte Reports verwalten)
- ❌ Premium-Verwaltung (Abo-Status, Kündigung)

**Grund:** UI Foundation erst implementieren, Funktionalität kommt nach MVP-Launch

---

## 🎯 Nächste Schritte (für später)

### Phase 1: SoulMate Finder MVP (nach Glow Launch)

**Backend:**
1. `StructuredReport` Model aus Beyond Horoscope portieren
2. `LuxuryPdfGenerator` in `nuuray_api` integrieren
3. Supabase-Tabelle: `purchased_reports` (user_id, report_type, purchase_date, pdf_url)
4. In-App Purchase Setup (StoreKit + Google Play)

**Report-Generierung:**
1. Partner-Daten-Eingabe Screen (2 Geburtsdaten)
2. Compatibility Score Berechnung (Western + Bazi + Numerologie)
3. Claude API Prompt: SoulMate Finder (Brand Voice!)
4. PDF-Generierung via Edge Function

**UI/UX:**
1. Report-Preview-Screen (Teaser + Sample-Seiten + Preis)
2. Kauf-Button → In-App Purchase
3. Loading-Screen: "Dein Report wird erstellt..." (Progress-Indicator)
4. Report-Viewer-Screen (PDF in-app anzeigen)
5. Download + Share Buttons

**Bibliothek:**
1. Report-Bibliothek Screen (`/my-reports`)
2. Liste aller gekauften Reports (Cover + Titel + Datum)
3. Empty State: "Noch keine Reports gekauft" + CTA
4. Navigation von Settings → Bibliothek

### Phase 2: Core Reports

- Soul Purpose Report (€7,99)
- Yearly Forecast Report (€9,99)

### Phase 3: Expansion Reports

- Shadow & Light (€7,99)
- The Purpose Path (€6,99)
- Body Vitality (€5,99)
- Aesthetic Style Guide (€5,99)
- Cosmic Parenting (€6,99)
- Relocation Astrology (€7,99)

---

## 📚 Code-Referenzen

**Beyond Horoscope Code-Basis:**
- `/altesProjektBeyondHoroscope/lib/models/structured_report.dart`
- `/altesProjektBeyondHoroscope/lib/services/luxury_pdf_generator.dart`
- `/altesProjektBeyondHoroscope/lib/theme/beyond_theme.dart`
- `/altesProjektBeyondHoroscope/assets/fonts/` (Noto Sans + Nunito)

**Report-Struktur (Luxury Dossier Format):**
1. Cover Page
2. Executive Summary ("Die Golden Three")
3. Identity Page (Western + Bazi + Numerologie)
4. Beyond Insights (Pull Quotes)
5. Visualizations (Beyond-Dreieck, Element-Balance)
6. Energy Forecast (Transit-Radar, 12-Monate)
7. Body Sections (Hauptinhalt)
8. Closing Page (Summary, Action Items, Dharma Checklist)

**Design-System (Cosmic Nude):**
- Primary Gold: `#D4AF37`
- Cosmic Nude: `#B8A394`
- Warm White: `#FAF8F5`
- Deep Charcoal: `#2D2926`

---

## ✅ Ergebnis

**UI Foundation für Reports ist komplett:**
- ✅ Bottom Nav mit Insights-Tab (zwischen Signatur & Mond)
- ✅ Insights Screen mit allen 10 Reports
- ✅ Settings: "Meine Reports" + "Premium" Platzhalter
- ✅ Dokumentation: `GLOW_REPORTS_OTP.md` + Session-Log
- ✅ TODO.md: Reports als eigene Section

**Entwicklungsphase:**
- App ist nur intern sichtbar (nur User + Claude)
- UI kann jederzeit angepasst werden
- Funktionalität kommt nach MVP-Launch

**User Experience:**
- Reports sind sichtbar und "entdeckbar"
- Klare Erwartung: "Coming Soon"
- Keine verwirrenden leeren Zustände

Reports sind **kein verstecktes Feature mehr**, sondern ein **sichtbarer Teil der App-Vision**! 🚀
