# 📋 DOKUMENTATIONS-AUDIT: INKONSISTENZEN & VERALTETE INFORMATIONEN

> **Audit-Datum:** 2026-02-12
> **Durchgeführt von:** Claude Explore Agent
> **Durchsucht:** Alle Dokumentations-Dateien im `/docs` Verzeichnis
> **Status:** ✅ Kritische & kleinere Inkonsistenzen identifiziert

---

## 🔴 KRITISCHE INKONSISTENZEN (MÜSSEN SOFORT BEHOBEN WERDEN)

### 1. ⚠️ **Archetyp-System: Konzept vs. Implementierung (VERALTET!)**

**Problem:** `docs/architecture/ARCHETYP_SYSTEM.md` beschreibt ein **hardcoded 12-Archetyp-System**, aber die tatsächliche Implementierung ist anders!

**In ARCHETYP_SYSTEM.md:**
- ❌ Zeigt 12 hardcodierte Archetyp-Namen (Die Pionierin, Die Diplomatin, etc.)
- ❌ Zeigt 10 hardcodierte Bazi-Adjektive (die standfeste, die anpassungsfähige, etc.)
- ❌ Beschreibt 12 separate Detail-Screens für jeden Archetyp
- ⚠️ Hat Warning-Banner: "Dieses Dokument ist teilweise VERALTET!"

**Tatsächliche Implementierung (2026-02-12):**
- ✅ **Archetyp-Titel wird INDIVIDUELL via Claude API generiert** (NICHT hardcoded!)
- ✅ **Signatur-Satz wird INDIVIDUELL via Claude API generiert**
- ✅ **KEINE 12 Detail-Screens nötig**
- ✅ Implementiert in: `archetype_signature_service.dart` + `archetype_signature_prompt.dart`

**Dokumentiert in:** `docs/daily-logs/2026-02-12_archetyp-konzept-klarstellung.md`

**MASSNAHME:**
- [ ] `ARCHETYP_SYSTEM.md` komplett überarbeiten ODER nach `archive/` verschieben
- [ ] Großes WarningBox am Top: "Dieses Dokument beschreibt die ursprüngliche Konzeption. Die tatsächliche Implementierung erzeugt individuelle Archetyp-Titel via Claude API"
- [ ] Link zu `docs/CLAUDE_BRIEFING_CONTENT_STRATEGY.md` und `docs/daily-logs/2026-02-12_archetyp-konzept-klarstellung.md` hinzufügen

---

### 2. 🗄️ **Tabellennaming: `birth_charts` vs. `signature_profiles`**

**Problem:** Datenbank-Schema ist **inkonsistent dokumentiert**

**In GLOW_SPEC_V2.md (Abschnitt 8.2):**
- Tabelle heißt: `birth_charts`
- Hinweis: "Tabellenname ist `birth_charts` (nicht `signature_profiles`), da die Umbenennung noch aussteht."

**In TODO.md:**
- Provider heißt: `signatureProvider` (nicht `cosmicProfileProvider`)
- Folder heißt: `features/signature/` (nicht `cosmic_profile/`)
- Service heißt: `SignatureService` (nicht `CosmicProfileService`)
- **ABER die DB-Tabelle heißt immer noch `birth_charts`!**

**MASSNAHME:**
- [ ] **ENTSCHEIDEN:** Tabelle wirklich `birth_charts` behalten oder zu `signature_profiles` umbenennen?
- [ ] Konsistent in ALLEN Docs dokumentieren
- [ ] Wenn Tabelle bleiben soll: Clarify in GLOW_SPEC_V2 dass das OK ist + Begründung
- [ ] Wenn Umbenennung nötig: Migration schreiben

---

### 3. 🚶 **Onboarding: 2 ODER 3 Schritte?**

**Problem:** Dokumentation ist **widersprüchlich**

**In GLOW_SPEC_V2.md (Abschnitt 7.2):**
```
Onboarding: 2 Schritte
→ Schritt 1: Name (30s)
→ Schritt 2: Geburtsdaten (60s)
```

**In TODO.md (Zeile 158):**
```
✅ Gender-Tracking im Onboarding
→ Onboarding Flow: Jetzt 3 Schritte (Name → Gender → Geburtsdaten)
```

**In SPEC_CHANGELOG.md (Abschnitt 3):**
```
Onboarding: 3 Schritte → 2 Schritte
- Schritt 1: Name & Identität (3 Felder)
- Schritt 2: Geburtsdaten (alles kombiniert)
```

**Tatsächliche Implementation (Git Status):**
- `onboarding_gender_screen.dart` existiert im Git als untracked file (??)

**MASSNAHME:**
- [ ] **KLÄREN:** Ist Gender ein **separater 3. Screen** oder **integriert in Schritt 1/2**?
- [ ] Wenn 3. Screen: ALLE Docs aktualisieren (GLOW_SPEC_V2, SPEC_CHANGELOG, TODO)
- [ ] Wenn integriert: `onboarding_gender_screen.dart` entfernen oder dokumentieren warum sie existiert
- [ ] **ODER:** Alle Docs einheitlich: "2 Schritte Name + Geburtsdaten (Gender optional/später)"

---

### 4. ⏱️ **Runway-Schätzung: 4-6 Wochen MVP vs. 4-5 Monate Launch**

**Problem:** Zwei **völlig unterschiedliche Zeitpläne** existieren parallel

**In GLOW_SPEC_V2.md (Abschnitt 12.1):**
```
### 12.1 MVP (Minimal Viable Product) — 4-6 Wochen
Total: ~14 Tage (Vollzeit) oder ~4-5 Wochen (Teilzeit)
```

**In MVP_VS_POST_LAUNCH_V2.md (Zeile 1-20):**
```
**KEIN schlanker MVP** — stattdessen **vollständig Launch-Ready App**
- Lieber 4-5 Monate entwickeln mit kompletten Features
- Statt schneller MVP → frustrierte User → Features nachrüsten
```

**Interpretation:**
- GLOW_SPEC_V2 beschreibt schnellen MVP (4-6 Wochen)
- MVP_VS_POST_LAUNCH_V2 sagt: Skip MVP, geh direkt zu Launch-Ready (4-5 Monate)

**MASSNAHME:**
- [ ] **ENTSCHEIDEN:** Welche Strategie ist aktuell gültig?
- [ ] Alle Docs einheitlich anpassen
- [ ] **Empfehlung:** `MVP_VS_POST_LAUNCH_V2.md` als **THE SOURCE OF TRUTH** verwenden
- [ ] GLOW_SPEC_V2 Abschnitt 12 komplett überarbeiten oder archivieren

---

## ⚠️ VERALTETE INFORMATIONEN (SOLLTEN AKTUALISIERT WERDEN)

### 5. 📝 **Name "Cosmic Profile" vs. "Deine Signatur"**

**Status:** Umbenennung ist im Code implementiert ✅, aber noch in mehreren Docs erwähnt

**Wo noch "Cosmic Profile" erwähnt wird:**
- `docs/glow/CHANGELOG.md` — alte Release-Notes (OK)
- `docs/glow/implementation/COSMIC_PROFILE_IMPLEMENTATION.md` (Dateiname!) ← **sollte umbenennen**
- `docs/archive/GLOW_SPEC_V1.md` — alte Spec (OK, ist archiviert)

**MASSNAHME:**
- [ ] Datei umbenennen: `COSMIC_PROFILE_IMPLEMENTATION.md` → `SIGNATURE_IMPLEMENTATION.md`
- [ ] Inhalt überprüfen: "Cosmic Profile" durch "Deine Signatur" ersetzen
- [ ] README.md überprüfen: Falls noch "Cosmic Profile" erwähnt, aktualisieren

---

### 6. 📚 **Content Library Status: Unvollständig dokumentiert**

**In TODO.md (Zeilen 342-350):**
```
- [x] **Content Library komplett generiert** (264 Texte = 132 DE + 132 EN)
  - Sun/Moon/Rising Signs (12 each)
  - Life Path Numbers (12)
  - Soul Urge Numbers (12)
  - Expression Numbers (12)
  - Bazi Day Masters (60 Kombinationen) ← FEHLT TATSÄCHLICH!
```

**Status AKTUELL (2026-02-12):**
- ✅ Western Astrology Content: 36 Texte (12 × 3: Sun, Moon, Rising)
- ✅ Numerologie Basis: 36 Texte (3 × 12: Life Path, Expression, Soul Urge)
- ❌ **Bazi Day Masters: FEHLT KOMPLETT** → 60 Kombinationen nicht implementiert
- ❌ **Erweiterte Numerologie: FEHLT** → Birthday, Attitude, Maturity, Karmic Debt, etc.

**MASSNAHME:**
- [ ] TODO.md korrigieren: **"Content Library NICHT komplett"** statt "komplett generiert"
- [ ] Status-Sektion in TODO.md aktualisieren: "Content Library: 132/466 Texte (28%)"
- [ ] Fehlende Kategorien auflisten:
  - Bazi Day Master (60 × 2 = 120)
  - Birthday Numbers (31 × 2 = 62)
  - Attitude, Maturity, Personal Year, etc. (152)

---

### 7. 📊 **Reports-Dokumentation: Drei Versionen!**

**Problem:** Drei separate Report-Dokumentationen mit unterschiedlichen Inhalten:

1. **`GLOW_REPORTS_OTP.md`** (NEU, 2026-02-12) ✅
   - Vollständiger Katalog aller 10 Reports
   - Detaillierte UI/UX-Strategie
   - Entwicklungs-Phasen klar definiert

2. **`MVP_VS_POST_LAUNCH_V2.md`** (auch 2026-02-12)
   - Reports als Phase 2 (nach MVP)
   - 12-14 Wochen Entwicklung
   - Ähnliche Report-Liste

3. **`GLOW_SPEC_V2.md` (Abschnitt 6-7)** (älter)
   - Erwähnt "One-Time Purchase" für Jahresvorschau
   - Beschreibt "Partner-Check" als Feature
   - Keine vollständige Report-Liste

**MASSNAHME:**
- [ ] **`GLOW_REPORTS_OTP.md` als SINGLE SOURCE OF TRUTH etablieren**
- [ ] `GLOW_SPEC_V2.md` Abschnitt 6-7 überarbeiten → auf GLOW_REPORTS_OTP.md verweisen
- [ ] `MVP_VS_POST_LAUNCH_V2.md` mit GLOW_REPORTS_OTP.md synchronisieren
- [ ] README.md aktualisieren → klare Navigation zu Reports-Dok

---

### 8. 🔗 **Links zu nicht-existierenden/verschobenen Dokumenten**

**In CLAUDE.md (Zeile 9):**
```
- [`docs/daily-logs/2026-02-08_session-zusammenfassung.md`](docs/daily-logs/2026-02-08_session-zusammenfassung.md) — Neueste Session
```

**Problem:**
- Datei heißt möglicherweise `2026-02-08_status-zusammenfassung.md`
- ODER `2026-02-08_session-zusammenfassung-OLD.md.bak` (mit .bak Ending!)
- Link ist broken

**MASSNAHME:**
- [ ] Richtige Dateinamen in CLAUDE.md eintragen
- [ ] Überprüfen: Welche Session-Zusammenfassung ist AKTUELL? (2026-02-12 sollte aktuellste sein!)
- [ ] CLAUDE.md anpassen mit korrektem Link

---

## 🟡 KLEINERE UNSTIMMIGKEITEN (NICE TO HAVE)

### 9. 🗃️ **Datenbank-Schema: Field `display_name_number` noch nicht dokumentiert**

**In TODO.md (Zeilen 119):**
```
✅ Supabase Migration: `display_name_number` Spalte in `birth_charts` Tabelle ✅ DEPLOYED 2026-02-08!
```

**Aber in GLOW_SPEC_V2.md (Abschnitt 8.2 - `birth_charts` Tabelle):**
- Feld `display_name_number` ist NICHT aufgelistet!
- Numerologie-Felder sind dort, aber nicht erweitert

**MASSNAHME:**
- [ ] GLOW_SPEC_V2.md aktualisieren: `display_name_number` zu Numerologie-Feldern hinzufügen
- [ ] Alle neuen Migrationen dokumentieren: `20260208_add_display_name_number.sql` etc.

---

### 10. 📄 **Duplicate Dokumentation: MVP_VS_POST_LAUNCH.md vs. MVP_VS_POST_LAUNCH_V2.md**

**Problem:** Zwei ähnliche Dateien existieren

**Dateien:**
- `docs/glow/MVP_VS_POST_LAUNCH.md` (älter)
- `docs/glow/MVP_VS_POST_LAUNCH_V2.md` (NEU, 2026-02-12)

**Status:**
- V2 ist aktueller (2026-02-12)
- V1 sollte wahrscheinlich gelöscht oder archiviert werden

**MASSNAHME:**
- [ ] `MVP_VS_POST_LAUNCH.md` löschen ODER in `archive/` verschieben
- [ ] README.md: nur auf `MVP_VS_POST_LAUNCH_V2.md` verweisen

---

### 11. 🌐 **i18n Status: Welche Sprachen sind WIRKLICH implementiert?**

**In TODO.md (Zeilen 565-587):**
```
✅ i18n (Deutsch + Englisch) 100% KOMPLETT (2026-02-08 Abend)!
  - ✅ Flutter i18n Setup
  - ✅ ARB-Dateien (`app_de.arb` + `app_en.arb`) mit 260+ Strings
  - ✅ ALLE Screens 100% lokalisiert
```

**Aber auch in TODO.md (Zeilen 614-620):**
```
📋 Weitere Sprachen (Backlog - nach MVP):
  - [ ] Spanisch (ES)
  - [ ] Französisch (FR)
  - [ ] Türkisch (TR)
  **Strategie:** Nach MVP-Launch
```

**MASSNAHME:**
- [ ] Klären: Sind DE + EN wirklich 100% fertig?
- [ ] Wo sind die generierten `.dart` Files? (Should be `l10n/app_localizations.dart`)
- [ ] Wenn nicht 100%: TODO.md korrigieren ← Nicht "100% KOMPLETT" schreiben

---

### 12. 🔄 **Deployment-Docs: HOROSCOPE_STRATEGY.md doppelt vorhanden**

**Dateien:**
- `docs/deployment/HOROSCOPE_STRATEGY.md`
- `docs/glow/implementation/HOROSCOPE_STRATEGY.md`

**Problem:** Sind das Duplikate oder unterschiedliche Inhalte?

**MASSNAHME:**
- [ ] Überprüfen: Welche ist aktueller?
- [ ] Falls Duplikat: Eine löschen, eine behalten
- [ ] Falls unterschiedlich: In README klarmachen welche für was ist

---

### 13. 🏷️ **Naming Inconsistency: "Reports" vs. "OTPs"**

**Verschiedene Begriffe werden gemischt:**
- GLOW_REPORTS_OTP.md heißt es "Reports"
- Überall wird auch "OTPs" erwähnt (One-Time Purchases)
- In TODO.md manchmal "Reports", manchmal "OTPs"

**MASSNAHME:**
- [ ] Standardisieren: **Reports** für das Feature, **OTP** für das Bezahlmodell
- [ ] Beispiel: "Report PDFs werden via OTP (One-Time Purchase) verkauft"
- [ ] Alle Docs anpassen für Konsistenz

---

## 📊 ZUSAMMENFASSUNG: HANDLUNGSPRIORITÄTEN

### 🔴 **Sofort (diese Woche):**
1. ✅ **ARCHETYP_SYSTEM.md** überarbeiten oder archivieren
2. ⏳ **Onboarding Schritte** klären (2 oder 3?)
3. ⏳ **MVP-Strategie** entscheiden (4-6 Wochen vs. 4-5 Monate)
4. ⏳ **GLOW_REPORTS_OTP.md** als "source of truth" etablieren

### ⚠️ **Diese Woche (später):**
5. ⏳ **Birth_charts vs. Signature_profiles** entscheiden
6. ⏳ **COSMIC_PROFILE_IMPLEMENTATION.md** umbenennen
7. ⏳ **Content Library Status** korrigieren (132 vs. 466 Texte)
8. ⏳ **CLAUDE.md Links** überprüfen

### 🟡 **Nächste Woche:**
9. ⏳ **Duplicate Docs** (MVP v1/v2, HOROSCOPE_STRATEGY) aufräumen
10. ⏳ **i18n Status** verifizieren
11. ⏳ Alle neuen **Migrations** dokumentieren
12. ⏳ **Reports vs. OTPs** Terminologie standardisieren

---

## 🎯 EMPFOHLENE AKTIONEN (TABELLE)

| Inkonsistenz | Gewicht | Action | Owner |
|-------------|---------|--------|-------|
| **Archetyp-System veraltet** | 🔴 KRITISCH | ARCHETYP_SYSTEM.md überarbeiten | Doku |
| **Onboarding 2/3 Schritte?** | 🔴 KRITISCH | Implementierung prüfen + Docs anpassen | Code Review |
| **MVP vs. Launch-Ready** | 🔴 KRITISCH | Strategie entscheiden, GLOW_SPEC_V2 aktualisieren | Planning |
| **Birth_charts Naming** | 🔴 KRITISCH | Entscheiden + konsistent dokumentieren | DB |
| **Cosmic Profile umbenennen** | ⚠️ WICHTIG | COSMIC_PROFILE_IMPL.md + README aktualisieren | Doku |
| **Content Library unvollständig** | ⚠️ WICHTIG | Status in TODO.md korrigieren | Doku |
| **Reports-Docs dupliziert** | ⚠️ WICHTIG | Auf GLOW_REPORTS_OTP.md zentralisieren | Doku |
| **Duplicate Docs (MVP v1/v2)** | 🟡 MITTEL | Alte Version archivieren/löschen | Maintenance |

---

## 📝 NÄCHSTE SCHRITTE

**Zeitbudget für Cleanup:**
- **🔴 KRITISCHE Inkonsistenzen:** ~3-4 Stunden
- **⚠️ Veraltete Infos:** ~2 Stunden
- **🟡 Kleinere Unstimmigkeiten:** ~1-2 Stunden
- **Total:** ~6-8 Stunden Dokumentations-Cleanup

---

**Erstellt:** 2026-02-12
**Agent-ID:** aac51c5 (für Fortsetzung via Task-Resume)
**Nächster Review:** Nach Behebung der kritischen Inkonsistenzen
