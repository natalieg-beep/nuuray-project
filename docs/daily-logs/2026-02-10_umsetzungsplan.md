# 🎯 UMSETZUNGSPLAN — 2026-02-10

## 📊 Status Quo
- ✅ **Onboarding komplett** (2-Schritte Flow, Google Places, Geocoding)
- ✅ **Home Screen mit Mini-Dashboard** (Western/Bazi/Numerologie Cards)
- ✅ **Profile Edit mit Auto-Regenerierung**
- ✅ **Erweiterte Numerologie** (Karmic Debt, Challenges, Lessons, Bridges)
- ✅ **i18n vollständig** (DE + EN, 260+ Strings)
- 📋 **Neue Konzepte dokumentiert:** Bottom Navigation + Signatur Screen + Content-Strategie
  - `docs/glow/konzept-bottom-nav-signatur.md`
  - `docs/glow/konzept-signatur-content.md`

---

## 🎯 Ziel für heute

**Bottom Navigation + Signatur Screen MVP implementieren**

Das bedeutet:
1. ✅ Navigation-Infrastruktur (GoRouter + ShellRoute für 4 Tabs)
2. ✅ Signatur Screen UI (5 scrollbare Sektionen mit ExpandableCards)
3. ✅ Freemium-Content-Integration (statische Texte aus `content_library`)
4. ⏳ Premium-Platzhalter (CTA für Synthese, Edge Function vorbereiten)

---

## 📋 Tasks (Priorisiert)

### Phase 1: Navigation-Infrastruktur (2-3h)
**Ziel:** Bottom Navigation Bar mit 4 Tabs, GoRouter ShellRoute

#### 1.1 GoRouter ShellRoute konfigurieren
- Datei: `apps/glow/lib/src/core/router/app_router.dart`
- ShellRoute mit 4 Tabs: `/home`, `/signature`, `/moon`, `/insights`
- Aktiven Tab über `GoRouterState` tracken

#### 1.2 ScaffoldWithNavBar Widget
- Neues Widget: `apps/glow/lib/src/core/widgets/scaffold_with_nav_bar.dart`
- BottomNavigationBar mit 4 Items (Icons gemäß Konzept)
- `NavigationDestination` statt klassischer BottomNavigationBar (Material 3)

#### 1.3 Placeholder Screens
- `MoonScreen` (`apps/glow/lib/src/features/moon/moon_screen.dart`)
- `InsightsScreen` (`apps/glow/lib/src/features/insights/insights_screen.dart`)
- Einfacher Scaffold mit "Coming Soon" Text

#### 1.4 Navigation testen
- Tab-Wechsel funktioniert
- Deep Links (`/signature`, `/moon`) funktionieren
- Android Zurück-Button kehrt nicht zu vorherigem Tab zurück (GoRouter-Standard)

---

### Phase 2: Signatur Screen UI (3-4h)
**Ziel:** Scrollbare Seite mit 5 Sektionen (Hero, Western, Bazi, Numerologie, Premium-CTA)

#### 2.1 SignatureScreen Struktur
- Datei: `apps/glow/lib/src/features/signature/signature_screen.dart`
- `ListView` mit 5 Sektionen
- Provider: `signatureProvider` (existiert bereits, nutzt `CosmicProfileService`)
- Loading State + Error State

#### 2.2 HeroSection
- Widget: `apps/glow/lib/src/features/signature/widgets/hero_section.dart`
- Archetyp-Titel (z.B. "Die warmherzige Visionärin")
- Mini-Synthese (1 Satz, personalisiert, aus `signature_profiles.mini_synthesis`)
- **Achtung:** Mini-Synthese-Feld muss zu DB/Model hinzugefügt werden!

#### 2.3 ExpandableCard (Wiederverwendbar)
- Widget: `apps/glow/lib/src/core/widgets/expandable_card.dart`
- Props: `title`, `subtitle`, `icon`, `content` (Widget), `isExpanded`
- Animierte Expansion (300ms)
- Design: AppColors, kein Gradient

#### 2.4 WesternAstrologySection
- 3 ExpandableCards: Sonne ☀️, Mond 🌙, Aszendent ⬆️
- **Collapsed:** "Stier in Sonne" + Icon
- **Expanded:** Kurzbeschreibung aus `content_library` (70 Wörter)
- Datenquelle: `BirthChart.westernChart` + `content_library` Lookup

#### 2.5 BaziSection
- 1 ExpandableCard: Day Master 🐷 (z.B. "Yin Wasser Schwein")
- **Collapsed:** Day Master + Element-Balance Icons
- **Expanded:** Kurzbeschreibung aus `content_library`
- Datenquelle: `BirthChart.baziChart.dayMaster` + `content_library`

#### 2.6 NumerologySection
- 1-2 ExpandableCards: Life Path Number + Soul Urge (oder Birthday)
- **Collapsed:** "Life Path 7" + Icon
- **Expanded:** Kurzbeschreibung aus `content_library`
- Datenquelle: `BirthChart.numerologyChart.lifePathNumber` + `content_library`

#### 2.7 PremiumSynthesisSection
- **Free User:** CTA-Box "Entdecke deine kosmische Synthese" + "Premium freischalten" Button
- **Premium User:** Full Synthese-Text (~400-600 Wörter, Claude-generiert)
- Premium-Status: `subscription_status` Provider (später via RevenueCat)

---

### Phase 3: Content Library Integration (2-3h)
**Ziel:** Freemium-Texte für alle Zeichen/Elemente/Zahlen in Supabase speichern

#### 3.1 Supabase Migration: `content_library`
- Neue Migration: `20260210000000_create_content_library.sql`
- Schema:
  ```sql
  CREATE TABLE content_library (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category TEXT NOT NULL, -- 'sun_sign', 'moon_sign', 'rising_sign', 'bazi_day_master', 'life_path_number', etc.
    key TEXT NOT NULL, -- 'aries', 'taurus', ..., 'yang_wood_rat', '1', '2', '11', '22', etc.
    locale TEXT NOT NULL, -- 'de', 'en'
    title TEXT NOT NULL, -- "Widder", "Aries"
    description TEXT NOT NULL, -- ~70 Wörter
    created_at TIMESTAMPTZ DEFAULT NOW()
  );
  CREATE UNIQUE INDEX idx_content_library_lookup ON content_library(category, key, locale);
  ```

#### 3.2 ContentLibraryService
- Datei: `packages/nuuray_api/lib/src/services/content_library_service.dart`
- Methode: `Future<String?> getDescription(String category, String key, String locale)`
- Caching: In-Memory Cache für häufig genutzte Texte

#### 3.3 Batch-Seed-Script
- Datei: `scripts/seed_content_library.dart` (oder Edge Function)
- **Input:** Liste aller Keys (12 Sonnenzeichen, 12 Mondzeichen, etc.)
- **Prozess:**
  1. Für jede Kategorie/Key-Kombination: Claude API Call (Batch)
  2. Prompt: "Schreibe eine 70-Wörter-Beschreibung für [Widder/Sonne] für Frauen, warm & unterhaltsam"
  3. Response parsen → Supabase INSERT
- **Kosten:** ~$3-5 für alle 264 Texte (einmalig)

#### 3.4 Seed ausführen
- Script lokal ausführen oder als Supabase Edge Function deployen
- Texte in `content_library` speichern
- Testen: `SELECT * FROM content_library WHERE category = 'sun_sign' AND key = 'aries' AND locale = 'de';`

---

### Phase 4: Premium-Vorbereitung (Optional, 1-2h)
**Ziel:** Edge Function für Premium-Synthese vorbereiten (noch nicht live)

#### 4.1 Supabase Migration: `premium_signature_content`
- Schema:
  ```sql
  CREATE TABLE premium_signature_content (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    locale TEXT NOT NULL,
    cosmic_synthesis TEXT, -- ~400-600 Wörter, die große Zusammenfassung
    sun_detail TEXT, -- ~200 Wörter
    moon_detail TEXT,
    rising_detail TEXT,
    day_master_detail TEXT,
    sun_moon_interaction TEXT, -- ~150 Wörter
    pillar_synthesis TEXT,
    numerology_analysis TEXT,
    generated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, locale)
  );
  ALTER TABLE premium_signature_content ENABLE ROW LEVEL SECURITY;
  CREATE POLICY premium_content_select ON premium_signature_content FOR SELECT USING (auth.uid() = user_id);
  ```

#### 4.2 Edge Function: `generate-premium-signature`
- Datei: `supabase/functions/generate-premium-signature/index.ts`
- **Input:** `user_id`, `locale`
- **Prozess:**
  1. User-Profil + Birth Chart aus DB laden
  2. Claude API Call mit strukturiertem Prompt (~2000 Wörter generieren)
  3. Response parsen (JSON mit allen Feldern)
  4. In `premium_signature_content` speichern (UPSERT)
- **Kosten:** ~$0,03-0,04 pro Call

#### 4.3 PremiumSignatureService
- Datei: `packages/nuuray_api/lib/src/services/premium_signature_service.dart`
- Methode: `Future<PremiumSignatureContent> generate(String userId, String locale)`
- Methode: `Future<PremiumSignatureContent?> get(String userId, String locale)`
- Caching: Supabase-seitig (UNIQUE constraint verhindert doppelte Generierung)

---

## 🎯 Zeitplan (8h Arbeitstag)

| Phase | Tasks | Geschätzte Zeit | Priorität |
|-------|-------|-----------------|-----------|
| **Phase 1** | Navigation-Infrastruktur (GoRouter, ShellRoute, Placeholders) | 2-3h | 🔴 Kritisch |
| **Phase 2** | Signatur Screen UI (5 Sektionen, ExpandableCards) | 3-4h | 🔴 Kritisch |
| **Phase 3** | Content Library (Migration, Service, Seed-Script) | 2-3h | 🟡 Wichtig |
| **Phase 4** | Premium-Vorbereitung (Migration, Edge Function) | 1-2h | 🟢 Optional |

**Realistisches Ziel für heute:**
- ✅ Phase 1 + 2 komplett (Navigation + UI)
- ✅ Phase 3 teilweise (Migration + Service, Seed morgen)
- ⏳ Phase 4 morgen/später

---

## 📦 Dateien zum Erstellen/Ändern

### Neue Dateien
```
apps/glow/lib/src/core/widgets/
├── scaffold_with_nav_bar.dart          [NEU]
└── expandable_card.dart                [NEU]

apps/glow/lib/src/features/signature/
├── signature_screen.dart               [NEU]
└── widgets/
    ├── hero_section.dart               [NEU]
    ├── western_astrology_section.dart  [NEU]
    ├── bazi_section.dart               [NEU]
    ├── numerology_section.dart         [NEU]
    └── premium_synthesis_section.dart  [NEU]

apps/glow/lib/src/features/moon/
└── moon_screen.dart                    [NEU]

apps/glow/lib/src/features/insights/
└── insights_screen.dart                [NEU]

packages/nuuray_api/lib/src/services/
├── content_library_service.dart        [NEU]
└── premium_signature_service.dart      [NEU]

supabase/migrations/
├── 20260210000000_create_content_library.sql         [NEU]
└── 20260210000001_create_premium_signature_content.sql [NEU]

supabase/functions/generate-premium-signature/
└── index.ts                            [NEU]

scripts/
└── seed_content_library.dart           [NEU]
```

### Zu ändernde Dateien
```
apps/glow/lib/src/core/router/app_router.dart
  → ShellRoute hinzufügen, Routen umstrukturieren

packages/nuuray_ui/lib/src/l10n/
  → app_de.arb, app_en.arb (neue Strings für Signatur Screen)

packages/nuuray_core/lib/src/models/
  → signature_profile.dart (mini_synthesis Feld hinzufügen)
```

---

## ✅ Definition of Done (heute)

- [ ] **Bottom Navigation funktioniert** (4 Tabs, Wechsel ohne Flackern)
- [ ] **Signatur Screen zeigt alle 5 Sektionen** (scrollbar, ohne Fehler)
- [ ] **ExpandableCards funktionieren** (Tap → Expansion mit Animation)
- [ ] **content_library Tabelle existiert** (Migration deployed)
- [ ] **ContentLibraryService implementiert** (Lookup funktioniert mit Mock-Daten)
- [ ] **i18n vollständig** (alle neuen Strings in ARB-Dateien)
- [ ] **Keine Linter-Fehler** (`flutter analyze`)
- [ ] **App läuft auf iOS Simulator** (visueller Test)

---

## 🚀 Nächste Session (morgen)

1. **Content-Seed ausführen** (264 Texte generieren)
2. **Premium Edge Function deployen**
3. **Mini-Synthese in Onboarding integrieren** (Archetyp-Call erweitern)
4. **Premium-CTA mit Mock-Subscription testen**
5. **Visuelles Polishing** (Spacing, Farben, Icons)

---

## 📝 Notizen

- **Kostenkontrolle:** Content-Seed nur einmal ausführen (nicht pro Deploy)
- **Performance:** `content_library` Service sollte In-Memory-Cache nutzen (häufig gleiche Lookups)
- **Premium-Gating:** Aktuell nur UI-Platzhalter, kein echtes IAP (kommt später mit RevenueCat)
- **Testing:** Fokus auf visuelle Tests, Unit-Tests für Calculator-Services später
- **Dokumentation:** Session-Log am Ende erstellen (`docs/daily-logs/2026-02-10_umsetzung-signatur-screen.md`)

---

## 🔄 Fortschritt (wird während der Session aktualisiert)

### Phase 1: Navigation ✅
- [x] GoRouter ShellRoute konfiguriert
- [x] ScaffoldWithNavBar erstellt
- [x] Placeholder Screens erstellt
- [x] Navigation getestet

### Phase 2: Signatur Screen UI ✅
- [x] SignatureScreen Struktur
- [x] HeroSection
- [x] ExpandableCard Widget
- [x] WesternAstrologySection
- [x] BaziSection
- [x] NumerologySection
- [x] PremiumSynthesisSection

### Phase 3: Content Library ✅ (Vorbereitet)
- [x] content_library Migration (Datei erstellt, manuell deployen)
- [x] ContentLibraryService
- [x] Batch-Seed-Script
- [ ] Seed ausführen (manuell, wenn Migrationen deployed sind)

### Phase 4: Premium ✅ (Vorbereitet)
- [x] premium_signature_content Migration (Datei erstellt, manuell deployen)
- [ ] generate-premium-signature Edge Function (später)
- [ ] PremiumSignatureService (später)

---

**Bereit zum Start!** 🚀
