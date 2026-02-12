# NUURAY GLOW — Launch-Ready Roadmap (Aktualisiert 2026-02-12)

**Erstellt:** 2026-02-12
**Status:** ✅ Aktuell — Archetyp-Konzept klargestellt
**Ersetzt:** `MVP_VS_POST_LAUNCH.md` (veraltet)

---

## 🎯 Launch-Philosophie

**KEIN schlanker MVP** — stattdessen **vollständig Launch-Ready App**

- Lieber 4-5 Monate entwickeln mit kompletten Features
- Statt schneller MVP → frustrierte User → Features nachrüsten
- **Qualität > Geschwindigkeit**
- **Keine "Coming Soon" Platzhalter wo möglich**

---

## ✅ BEREITS FERTIG (~50% der Arbeit)

**Auth & Onboarding:**
- ✅ Email-Login/Signup (Supabase Auth)
- ✅ Onboarding: 2 Schritte (Name + Geburtsdaten kombiniert)
- ✅ Google Places Autocomplete für Geburtsort
- ✅ 4 Name-Felder für Numerologie

**"Deine Signatur" Dashboard:**
- ✅ Western Astrology Card (Sonne, Mond, Aszendent)
- ✅ Bazi Card (Vier Säulen, Day Master, Element Balance)
- ✅ Numerology Card (Life Path, erweiterte Numerologie)
- ✅ Alle Berechnungen funktionieren

**Archetyp-System (Synthese):**
- ✅ **Archetyp-Titel** (individuell via Claude API)
- ✅ **Signatur-Satz** (individuell via Claude API)
- ✅ Home Screen Integration
- ✅ Signatur Screen Integration
- ✅ **= Synthese aller 3 Systeme** (FERTIG!)
- ✅ **KEINE Detail-Screens nötig!**

**Technische Foundation:**
- ✅ Claude API Integration
- ✅ Supabase Backend
- ✅ i18n Setup (DE + EN, 260+ Strings)
- ✅ Settings Screen
- ✅ Profile Edit mit Auto-Regenerierung
- ✅ Content Library (264 Texte)

**Reports UI Foundation:**
- ✅ Insights Screen (alle 10 Reports als Platzhalter)
- ✅ Bottom Nav: `[Home] [Signatur] [Insights] [Mond]`
- ✅ Settings: "Meine Reports" + "Premium" Platzhalter

---

## ⏳ NOCH ZU BAUEN FÜR LAUNCH (~50%)

### 1. Alle 10 Reports funktionsfähig (12-14 Wochen)

**Report-System Foundation:** (2-3 Wochen)
- [ ] `StructuredReport` Model aus Beyond Horoscope portieren
- [ ] `LuxuryPdfGenerator` in `nuuray_api` integrieren
- [ ] Fonts (Noto Sans, Nunito) zu assets hinzufügen
- [ ] PDF-Sharing (Web: Download, Native: Share Sheet)
- [ ] Kauf-Flow + Report-Bibliothek UI

**10 Reports implementieren:** (10-12 Wochen)
- [ ] 1. SoulMate Finder (€4,99) — Partner-Check
- [ ] 2. Soul Purpose (€7,99) — Seelenmission
- [ ] 3. Shadow & Light (€7,99) — Schatten-Integration
- [ ] 4. The Purpose Path (€6,99) — Berufung
- [ ] 5. Golden Money Blueprint (€7,99) — Geld-Energie
- [ ] 6. Body Vitality (€5,99) — Lebensenergie
- [ ] 7. Aesthetic Style Guide (€5,99) — Kosmischer Stil
- [ ] 8. Cosmic Parenting (€6,99) — Elternschaft
- [ ] 9. Relocation Astrology (€7,99) — Idealer Ort
- [ ] 10. Yearly Energy Forecast (€9,99) — Persönliches Jahr

**Jeder Report benötigt:**
- Claude API Prompt (Brand Voice!)
- PDF-Template anpassen
- Preview-Screen
- Test-Generierungen

---

### 2. Premium-Features (7-8 Wochen)

**In-App Purchase Setup:** (1-2 Wochen)
- [ ] Apple StoreKit Configuration
- [ ] Google Play Billing Configuration
- [ ] RevenueCat evaluieren
- [ ] Premium-Gating Logic (Riverpod Provider)
- [ ] Subscription Management (subscriptions Tabelle)

**Premium-Content:** (5-6 Wochen)
- [ ] Wochen-Horoskop (Premium)
- [ ] Monats-Energie (Premium)
- [ ] Jahresvorschau (Premium, On-Demand)
- [ ] Partner-Check Basic (Premium)
- [ ] Premium-Badge UI überall

---

### 3. Mond Screen ausführlich (4-5 Wochen)

- [ ] Mondphasen-Berechnung implementieren
- [ ] Mondphasen-Kalender UI (interaktiv)
- [ ] Aktuelle Mondphase + Bedeutung
- [ ] Rituale/Tipps Content erstellen (8 Mondphasen × 2 Sprachen)
- [ ] Mondphasen-Alerts (optional)

---

### 4. Testing + Polish (5-8 Wochen)

**Berechnungen validieren:** (2-3 Wochen)
- [ ] Western Astrology: 10-20 Testfälle
- [ ] Bazi: Mit externen Rechnern abgleichen
- [ ] Numerologie: Meisterzahlen verifizieren
- [ ] **KRITISCH: Alle User-Charts basieren darauf!**

**Content Quality Check:** (1-2 Wochen)
- [ ] Content Library nach Brand Soul überarbeiten
- [ ] Bazi Day Master Beschreibungen (60 Texte)
- [ ] 7-Fragen-Check für alle Claude-generierten Texte
- [ ] Report-Prompts nach Brand Voice prüfen

**Bug-Fixing + Polish:** (2-3 Wochen)
- [ ] UI-Inkonsistenzen beheben
- [ ] Loading States verbessern
- [ ] Error Handling testen
- [ ] Offline-Modus sicherstellen

---

### 5. Legal + Deployment (4-5 Wochen)

- [ ] Privacy Policy (GDPR/KVKK)
- [ ] Terms of Service
- [ ] Impressum
- [ ] App Store Submission (iOS)
- [ ] Google Play Submission (Android)
- [ ] TestFlight Beta (2 Wochen Testing)
- [ ] Crash Reporting (Sentry)

---

## 📊 Gesamt-Zeitplan

| Feature-Gruppe | Wochen | Status |
|----------------|--------|--------|
| **Bereits fertig** | — | ✅ 50% |
| Alle 10 Reports | 12-14 | ⏳ |
| Premium-Features | 7-8 | ⏳ |
| Mond Screen | 4-5 | ⏳ |
| ~~Archetyp-Screens~~ | ~~5-7~~ | ✅ NICHT NÖTIG! |
| Testing + Polish | 5-8 | ⏳ |
| Legal + Deployment | 4-5 | ⏳ |

**Gesamt (mit Parallelisierung): ~18-22 Wochen = 4-5 Monate** 🚀

---

## 🎉 Archetyp-System: BEREITS FERTIG!

**Was wir dachten:**
- 12 hardcodierte Archetyp-Namen
- 10 hardcodierte Bazi-Adjektive
- 12 Detail-Screens erstellen
- Content schreiben für alle 12
- **= 5-7 Wochen Extra-Arbeit**

**Was tatsächlich implementiert ist:**
- ✅ **Individueller Archetyp-Titel** (Claude-generiert, einzigartig pro User)
- ✅ **Individueller Signatur-Satz** (Claude-generiert, verwebt alle 3 Systeme)
- ✅ Home Screen + Signatur Screen Integration
- ✅ **= Synthese-Lösung, KEINE Detail-Screens nötig!**
- ✅ **5-7 Wochen gespart!** 🎉

**Siehe:** `docs/daily-logs/2026-02-12_archetyp-konzept-klarstellung.md`

---

## 🚫 NICHT für Launch (später)

- Apple/Google Sign-In (Social Login)
- Widgets (iOS/Android)
- Dark Mode
- Advanced Bazi Features (10 Gods, Luck Pillars)
- Weitere Sprachen (ES, FR, TR)

---

## ✅ Launch-Ready Definition

**Die App ist "Launch-Ready" wenn:**
1. ✅ Alle 4 Bottom Nav Tabs funktionieren (Home, Signatur, Insights, Mond)
2. ✅ Alle 10 Reports sind kaufbar und generierbar
3. ✅ Premium-Abo ist funktionsfähig
4. ✅ In-App Purchase funktioniert (Apple + Google)
5. ✅ Alle Berechnungen sind validiert
6. ✅ Content ist Brand Voice-konform
7. ✅ Privacy Policy + Terms sind vorhanden
8. ✅ TestFlight Beta erfolgreich

**KEIN "Coming Soon" außer bei:**
- Social Sign-In (optional, kann später kommen)
- Advanced Bazi Features (zu spezialisiert für Launch)

---

## 🎯 Fazit

**Launch-Zeitplan: 4-5 Monate ab jetzt**

**Warum realistisch:**
- ~50% ist bereits fertig
- Reports sind größter Arbeitsblock (12-14 Wochen)
- Mit Parallelisierung: Mond Screen + Premium Features gleichzeitig
- Archetyp-System spart 5-7 Wochen (war Missverständnis!)

**Nächste Schritte:**
1. Entscheidung: Alle 10 Reports für Launch? Oder 3 zuerst?
2. Priorisierung: Was ist wichtiger — Reports oder Premium-Features?
3. Zeitplan finalisieren basierend auf Entscheidungen

**User-Fragen:**
- Alle 10 Reports VOR Launch? → Ja, bestätigt! ✅
- Archetyp Detail-Screens? → Nein, nicht nötig! ✅
- Mond Screen ausführlich? → Ja, ausführlich! ✅
- Zeitrahmen 6-12 Monate? → Nein, 4-5 Monate realistisch! ✅
