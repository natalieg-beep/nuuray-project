# NUURAY GLOW — MVP vs. Post-Launch Features

**Erstellt:** 2026-02-12
**Zweck:** Klare Trennung zwischen MVP-Launch und späteren Features zur Konzept-Überprüfung

---

## 🎯 VOR MVP-LAUNCH (Was muss funktionieren?)

### ✅ BEREITS FERTIG

**Auth & Onboarding:**
- ✅ Email-Login/Signup (Supabase Auth)
- ✅ Onboarding: 2 Schritte (Name + Geburtsdaten kombiniert)
- ✅ Google Places Autocomplete für Geburtsort (Live-Suche)
- ✅ 4 Name-Felder für Numerologie (Rufname, Vornamen, Geburtsname, Nachname)

**"Deine Signatur" Dashboard:**
- ✅ Western Astrology Card (Sonne, Mond, Aszendent mit Graden)
- ✅ Bazi Card (Vier Säulen, Day Master, Element Balance)
- ✅ Numerology Card (Life Path, Display Name, Birth/Current Energy, Erweitert)
- ✅ Alle Berechnungen funktionieren (Western, Bazi, Numerologie)

**Technische Foundation:**
- ✅ Claude API Integration (Tageshoroskop On-Demand)
- ✅ Supabase Backend (Auth, Profiles, BirthCharts, Content Library)
- ✅ i18n Setup komplett (DE + EN, 260+ Strings)
- ✅ Settings Screen (Sprach-Switcher, Profil bearbeiten)
- ✅ Profile Edit mit Auto-Regenerierung (Chart + Archetyp)
- ✅ Content Library (264 Texte: Sternzeichen, Zahlen, Bazi Day Masters)

**Reports UI Foundation:**
- ✅ Insights Screen (Alle 10 Reports als Platzhalter)
- ✅ Bottom Nav: `[Home] [Signatur] [Insights] [Mond]`
- ✅ Settings: "Meine Reports" + "Premium" Platzhalter

---

### ⏳ NOCH OFFEN FÜR MVP

**Kern-Features (Kritisch):**
- [ ] **Mond Screen** — Aktuell nur Platzhalter-Screen
  - Mondphasen-Berechnung implementieren
  - Mondphasen-Kalender UI
  - Mondphasen-Tipps (aus Content Library oder Claude)

- [ ] **Tageshoroskop-Ansicht verbessern**
  - Aktuell: Home Screen zeigt On-Demand generiertes Horoskop
  - TODO: Eigener Screen mit vollständiger Ansicht?
  - TODO: Personal Insights besser hervorheben?

- [ ] **Archetyp-System Integration** (Optional für MVP?)
  - Aktuell: Archetyp-Titel wird generiert und gespeichert
  - Geplant: 12 Archetypen mit Detail-Screens (Schamanin, Kriegerin, etc.)
  - Frage: Ist das MVP-kritisch oder kann das später kommen?

**Testing & Quality:**
- [ ] **⚠️ KRITISCH: Berechnungs-Validierung**
  - Western Astrology: 10-20 Testfälle (Sonnenzeichen, Mondzeichen, Aszendent)
  - Bazi: Mit externen Rechnern abgleichen (fourpillars.net)
  - Numerologie: Meisterzahlen verifizieren
  - **Warum kritisch?** Alle User-Charts basieren darauf!

- [ ] **Archetyp-Persistenz Testing**
  - Profile Edit → signature_text bleibt erhalten?
  - Logout/Login → Archetyp konstant?
  - Home = Signatur Screen Titel identisch?

- [ ] **Content Quality Check**
  - Content Library Texte nach Brand Soul überarbeiten
  - Bazi Day Master Beschreibungen fehlen (60 Texte)
  - 7-Fragen-Check für alle generierten Texte

**Deployment:**
- [ ] TestFlight Build erstellen (iOS)
- [ ] Google Play Internal Testing (Android)
- [ ] Privacy Policy + Terms of Service (GDPR/KVKK)
- [ ] Crash Reporting (Sentry oder ähnlich)

---

## 🚀 NACH MVP-LAUNCH (Was kann warten?)

### Phase 1: Retention & Engagement (0-4 Wochen nach Launch)

**Push-Notifications:**
- [ ] Firebase Cloud Messaging Setup
- [ ] Tägliche Horoskop-Reminder (morgens)
- [ ] Mondphasen-Alerts (Vollmond, Neumond)
- [ ] Permissions-Flow optimieren

**Content-Expansion:**
- [ ] Wochen-Horoskop (Premium)
- [ ] Monats-Energie (Premium)
- [ ] Jahresvorschau (Premium, On-Demand)
- [ ] Premium-Personalisierung via Claude API

---

### Phase 2: Monetarisierung (4-8 Wochen nach Launch)

**In-App Purchases:**
- [ ] Apple StoreKit Configuration
- [ ] Google Play Billing Configuration
- [ ] RevenueCat evaluieren (vereinfacht Cross-Platform)
- [ ] Premium-Gating Logic (Riverpod Provider)
- [ ] Subscription Management (subscriptions Tabelle)

**Premium-Features umsetzen:**
- [ ] Wochen-Horoskop aktivieren
- [ ] Monats-Energie aktivieren
- [ ] Partner-Check (Basic Version)
- [ ] Jahresvorschau (Premium)

---

### Phase 3: Reports & OTPs (8-12 Wochen nach Launch)

**Report-System Foundation:**
- [ ] `StructuredReport` Model aus Beyond Horoscope portieren
- [ ] `LuxuryPdfGenerator` in `nuuray_api` integrieren
- [ ] Fonts (Noto Sans, Nunito) zu assets hinzufügen
- [ ] PDF-Sharing (Web: Download, Native: Share Sheet)

**SoulMate Finder / Partner-Check Report (€4,99):**
- [ ] UI: Partner-Daten-Eingabe Screen (2 Geburtsdaten)
- [ ] Compatibility Score Berechnung (Western + Bazi + Numerologie)
- [ ] Claude API Prompt: Partner-Check (Brand Voice!)
- [ ] Report-Preview-Screen (Teaser + Sample-Seiten)
- [ ] In-App Purchase: SoulMate Finder Produkt
- [ ] Report-Viewer-Screen (PDF in-app + Download + Share)
- [ ] Report-Bibliothek: "Meine Reports" (gekaufte Reports)

**Core Reports:**
- [ ] Soul Purpose Report (€7,99)
- [ ] Yearly Forecast Report (€9,99)

**Expansion Reports:**
- [ ] Shadow & Light (€7,99)
- [ ] The Purpose Path (€6,99)
- [ ] Body Vitality (€5,99)
- [ ] Aesthetic Style Guide (€5,99)
- [ ] Cosmic Parenting (€6,99)
- [ ] Relocation Astrology (€7,99)
- [ ] Golden Money Blueprint (€7,99)

---

### Phase 4: Advanced Features (12+ Wochen nach Launch)

**Social Features:**
- [ ] Apple Sign-In
- [ ] Google Sign-In
- [ ] "Deine Signatur" Teilen (Screenshot + Social Sharing)
- [ ] Freundinnen-Check (Freundschafts-Kompatibilität)

**Platform-Features:**
- [ ] Widgets (iOS/Android) — Tageshoroskop auf Home Screen
- [ ] Dark Mode
- [ ] Weitere Sprachen (ES, FR, TR) via DeepL API

**Advanced Bazi:**
- [ ] 10 Gods (十神) — Fortgeschrittene Bazi-Analyse (Premium)
- [ ] Luck Pillars (大运) — 10-Jahres-Zyklen
- [ ] Hidden Stems (藏干) — Evtl. zu spezialisiert

---

## 🤔 Konzeptionelle Fragen zur Diskussion

### 1. Archetyp-System — MVP oder später?

**Aktuell:**
- Archetyp-Titel wird generiert ("Die Schamanin", "Die Kriegerin", etc.)
- Wird auf Home Screen + Signatur Screen angezeigt
- KEINE Detail-Screens, nur der Titel

**Geplant (laut ARCHETYP_SYSTEM.md):**
- 12 Archetypen mit ausführlichen Beschreibungen
- Detail-Screens mit Stärken, Schatten, Berufung
- Integration in alle Content-Bereiche

**Frage:**
- Ist der Archetyp-Titel allein genug für MVP?
- Oder verwirrt es User, wenn sie "Die Schamanin" sehen aber nichts darüber erfahren?
- Alternative: Archetyp-System komplett rausnehmen aus MVP?

---

### 2. Insights Screen — Zu früh für MVP?

**Aktuell:**
- Bottom Nav zeigt "Insights" Tab
- Screen zeigt alle 10 Reports als "Coming Soon"
- User sehen Features, die nicht funktionieren

**Pro:**
- Zeigt App-Vision (wir haben mehr vor!)
- Keine verwirrenden leeren Zustände später
- Discovery-Flow ist schon da

**Contra:**
- User könnten frustriert sein ("Warum zeigen die mir das, wenn es nicht geht?")
- Lenkt von Kern-Features ab
- Erwartungshaltung wird geweckt, die nicht erfüllt wird

**Optionen:**
1. **Behalten:** Insights Tab bleibt, aber nur mit 1-2 "Coming Soon" Reports
2. **Verstecken:** Insights Tab komplett raus, nur in Settings "Meine Reports" erwähnen
3. **Später hinzufügen:** Erst mit erstem funktionierenden Report (SoulMate Finder)

---

### 3. Mond Screen — Was zeigen wir da?

**Aktuell:**
- Bottom Nav zeigt "Mond" Tab
- Screen ist Platzhalter (leer)

**Geplant:**
- Mondphasen-Kalender
- Aktuelle Mondphase + Bedeutung
- Mondphasen-Tipps (Rituale, Self-Care)

**Frage:**
- Ist ein Mondphasen-Kalender MVP-kritisch?
- Alternative: Mond Tab zeigt nur aktuelle Mondphase + Tipp (simpler)?
- Alternative: Mond Tab ganz rausnehmen und nur auf Home Screen Mondphase zeigen?

---

### 4. Premium-Features — Was gehört ins MVP?

**Aktuell geplant für MVP:**
- Premium-Gating ist sichtbar (UI-Elemente zeigen "Premium" Badge)
- ABER: Kein In-App Purchase implementiert
- User sehen Premium-Features, können sie aber nicht kaufen

**Frage:**
- Macht es Sinn, Premium-Features zu zeigen, wenn man sie nicht kaufen kann?
- Alternative: MVP ist komplett kostenlos, kein Premium-Gating?
- Alternative: Premium-Features verstecken bis In-App Purchase funktioniert?

---

### 5. Content-Strategie — Wie viel ist genug?

**Aktuell:**
- Content Library: 264 Texte (Sternzeichen, Zahlen, Bazi Day Masters)
- Tageshoroskop: On-Demand via Claude API
- Archetyp-Signatur: On-Demand via Claude API

**Offen:**
- Wochen-Horoskop: Manuell schreiben oder Claude?
- Monats-Energie: Manuell oder Claude?
- Mondphasen-Tipps: Statischer Content oder dynamisch?

**Frage:**
- Wie viel Content brauchen wir VOR Launch?
- Können wir mit Basis-Content starten und nach Launch erweitern?
- Oder brauchen wir von Tag 1 vollständige Content-Coverage?

---

## 📊 Feature-Matrix: MVP vs. Post-Launch

| Feature | MVP | Post-Launch | Nie |
|---------|-----|-------------|-----|
| **Auth & Onboarding** | ✅ | — | — |
| **"Deine Signatur" Dashboard** | ✅ | — | — |
| **Tageshoroskop** | ✅ | Personalisierung (Premium) | — |
| **Mondphasen-Kalender** | ⚠️ Diskutieren | Erweiterung | — |
| **Archetyp-System (Titel)** | ✅ Aktuell drin | — | ⚠️ Rausnehmen? |
| **Archetyp Detail-Screens** | ❌ | ✅ Phase 1 | — |
| **Insights Screen (Reports)** | ⚠️ Diskutieren | ✅ Mit SoulMate Finder | — |
| **Wochen-Horoskop** | ❌ | ✅ Premium Phase 1 | — |
| **Monats-Energie** | ❌ | ✅ Premium Phase 1 | — |
| **Jahresvorschau** | ❌ | ✅ Premium Phase 1 | — |
| **Partner-Check (Basic)** | ❌ | ✅ Premium Phase 1 | — |
| **SoulMate Finder Report (PDF)** | ❌ | ✅ Phase 3 | — |
| **Weitere Reports** | ❌ | ✅ Phase 3 | — |
| **In-App Purchase** | ❌ | ✅ Phase 2 | — |
| **Push-Notifications** | ❌ | ✅ Phase 1 | — |
| **Apple/Google Sign-In** | ❌ | ✅ Phase 4 | — |
| **Widgets** | ❌ | ✅ Phase 4 | — |
| **Dark Mode** | ❌ | ✅ Phase 4 | — |
| **10 Gods (Bazi)** | ❌ | ✅ Phase 4 | ⚠️ Evtl. zu komplex |
| **Luck Pillars** | ❌ | ✅ Phase 4 | — |
| **Hidden Stems** | ❌ | — | ✅ Zu spezialisiert |

---

## 🎯 Empfehlung: Schlanker MVP

**Vorschlag für minimalen, funktionierenden MVP:**

### Was MUSS rein:
1. ✅ Auth + Onboarding (FERTIG)
2. ✅ "Deine Signatur" Dashboard (FERTIG)
3. ✅ Tageshoroskop On-Demand (FERTIG)
4. ⏳ Mondphasen-Anzeige (NUR aktuelle Phase + Tipp, kein Kalender)
5. ⏳ Settings (Sprache, Profil bearbeiten) (FERTIG)
6. ⏳ Berechnungs-Tests (KRITISCH!)

### Was KANN warten:
1. ❌ Insights Screen → Erst mit SoulMate Finder (Phase 3)
2. ❌ Archetyp Detail-Screens → Phase 1 nach Launch
3. ❌ Wochen/Monats-Horoskop → Premium Phase 1
4. ❌ Partner-Check → Premium Phase 1
5. ❌ In-App Purchase → Phase 2
6. ❌ Reports (PDFs) → Phase 3

### Was RAUS sollte (zur Diskussion):
1. ⚠️ **Archetyp-Titel?** — Verwirrt ohne Erklärung
2. ⚠️ **Insights Tab?** — Frustrierend ohne funktionierende Reports
3. ⚠️ **Premium-Badges?** — Frustrierend ohne Kauf-Möglichkeit

---

## 💭 Nächste Schritte

1. **Konzept-Review:** Welche Features bleiben im MVP?
2. **Priorisierung:** Was ist wirklich kritisch für Early Adopters?
3. **Testing-Plan:** Berechnungen validieren (SEHR WICHTIG!)
4. **Content-Plan:** Wie viel Content brauchen wir minimal?
5. **Launch-Termin:** Realistisch 2-4 Wochen?

**Frage an dich:** Was stört dich am aktuellen Konzept? Was fühlt sich falsch an? 🤔
