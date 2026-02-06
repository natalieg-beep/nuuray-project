-- =============================================================================
-- NUURAY — Initiales Datenbankschema
-- Migration: 001_initial_schema.sql
-- =============================================================================
-- Shared-Tabellen (ohne Prefix) werden von allen drei Apps genutzt.
-- App-spezifische Tabellen haben Prefix: glow_, tide_, path_.
-- RLS ist IMMER aktiviert.
-- =============================================================================


-- ---------------------------------------------------------------------------
-- EXTENSIONS
-- ---------------------------------------------------------------------------

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";


-- ---------------------------------------------------------------------------
-- SHARED: User-Profile
-- ---------------------------------------------------------------------------

CREATE TABLE public.profiles (
  id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name  TEXT,
  birth_date    DATE NOT NULL,
  birth_time    TIME,                    -- Optional: Für genaueres Chart
  birth_city    TEXT,                     -- Optional: Für Aszendent-Berechnung
  birth_lat     DOUBLE PRECISION,
  birth_lng     DOUBLE PRECISION,
  language      TEXT NOT NULL DEFAULT 'de' CHECK (language IN ('de', 'en')),
  timezone      TEXT NOT NULL DEFAULT 'Europe/Berlin',
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users können eigenes Profil lesen"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users können eigenes Profil ändern"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users können eigenes Profil erstellen"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);


-- ---------------------------------------------------------------------------
-- SHARED: Geburtsdaten-Charts (berechnete Ergebnisse, gecacht)
-- ---------------------------------------------------------------------------

CREATE TABLE public.birth_charts (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id           UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,

  -- Westliche Astrologie
  sun_sign          TEXT NOT NULL,        -- 'aries', 'taurus', ...
  moon_sign         TEXT,
  ascendant_sign    TEXT,                  -- Nur wenn Geburtszeit bekannt
  sun_degree        DOUBLE PRECISION,
  moon_degree       DOUBLE PRECISION,
  ascendant_degree  DOUBLE PRECISION,

  -- Bazi (Chinesische Astrologie)
  bazi_year_stem    TEXT,                  -- 'jia', 'yi', 'bing', ...
  bazi_year_branch  TEXT,                  -- 'zi', 'chou', 'yin', ...
  bazi_month_stem   TEXT,
  bazi_month_branch TEXT,
  bazi_day_stem     TEXT,                  -- Day Master
  bazi_day_branch   TEXT,
  bazi_hour_stem    TEXT,                  -- Nur wenn Geburtszeit bekannt
  bazi_hour_branch  TEXT,
  bazi_element      TEXT,                  -- Dominantes Element: 'holz', 'feuer', 'erde', 'metall', 'wasser'

  -- Numerologie
  life_path_number  INTEGER,              -- 1-9, 11, 22, 33
  expression_number INTEGER,
  soul_urge_number  INTEGER,

  -- Meta
  calculated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(user_id)
);

ALTER TABLE public.birth_charts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users können eigenes Chart lesen"
  ON public.birth_charts FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Service kann Charts erstellen"
  ON public.birth_charts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Service kann Charts aktualisieren"
  ON public.birth_charts FOR UPDATE
  USING (auth.uid() = user_id);


-- ---------------------------------------------------------------------------
-- SHARED: Partner-Daten (für Partner-Check in Glow, später auch Tide/Path)
-- ---------------------------------------------------------------------------

CREATE TABLE public.partner_profiles (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id       UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  display_name  TEXT NOT NULL,
  birth_date    DATE NOT NULL,
  birth_time    TIME,
  relationship  TEXT DEFAULT 'partner' CHECK (relationship IN ('partner', 'friend', 'family', 'colleague')),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.partner_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users können eigene Partner lesen"
  ON public.partner_profiles FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users können Partner erstellen"
  ON public.partner_profiles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users können Partner löschen"
  ON public.partner_profiles FOR DELETE
  USING (auth.uid() = user_id);


-- ---------------------------------------------------------------------------
-- SHARED: Täglicher Content (gecacht, von Edge Function generiert)
-- ---------------------------------------------------------------------------

CREATE TABLE public.daily_content (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  content_date  DATE NOT NULL,
  content_type  TEXT NOT NULL,            -- 'horoscope', 'moon_phase', 'daily_energy', 'tip'
  sun_sign      TEXT,                     -- NULL für allgemeine Inhalte (z.B. Mondphase)
  language      TEXT NOT NULL DEFAULT 'de',
  title         TEXT,
  body          TEXT NOT NULL,
  metadata      JSONB DEFAULT '{}',       -- Flexibel: Mondphase-Details, Energie-Werte, etc.
  app           TEXT NOT NULL DEFAULT 'glow' CHECK (app IN ('glow', 'tide', 'path', 'shared')),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(content_date, content_type, sun_sign, language, app)
);

ALTER TABLE public.daily_content ENABLE ROW LEVEL SECURITY;

-- Täglicher Content ist für alle authentifizierten User lesbar
CREATE POLICY "Authentifizierte User können Content lesen"
  ON public.daily_content FOR SELECT
  USING (auth.role() = 'authenticated');

-- Nur Service-Role kann Content erstellen (Edge Functions)
CREATE POLICY "Service kann Content erstellen"
  ON public.daily_content FOR INSERT
  WITH CHECK (auth.role() = 'service_role');

-- Index für schnelle Abfragen
CREATE INDEX idx_daily_content_lookup
  ON public.daily_content(content_date, content_type, language, app);

CREATE INDEX idx_daily_content_sign
  ON public.daily_content(content_date, sun_sign, language);


-- ---------------------------------------------------------------------------
-- SHARED: Mondphasen-Cache (vorberechnet)
-- ---------------------------------------------------------------------------

CREATE TABLE public.moon_phases (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  phase_date    DATE NOT NULL UNIQUE,
  phase_name    TEXT NOT NULL,            -- 'new_moon', 'waxing_crescent', 'first_quarter', 'waxing_gibbous', 'full_moon', 'waning_gibbous', 'last_quarter', 'waning_crescent'
  illumination  DOUBLE PRECISION,         -- 0.0 - 1.0
  moon_sign     TEXT,                     -- 'aries', 'taurus', ...
  moon_degree   DOUBLE PRECISION,
  is_void_of_course BOOLEAN DEFAULT FALSE,
  void_start    TIMESTAMPTZ,
  void_end      TIMESTAMPTZ,
  metadata      JSONB DEFAULT '{}'
);

ALTER TABLE public.moon_phases ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Alle können Mondphasen lesen"
  ON public.moon_phases FOR SELECT
  USING (auth.role() = 'authenticated');


-- ---------------------------------------------------------------------------
-- SHARED: Subscriptions (serverseitig verifiziert)
-- ---------------------------------------------------------------------------

CREATE TABLE public.subscriptions (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id           UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  app               TEXT NOT NULL CHECK (app IN ('glow', 'tide', 'path')),
  product_id        TEXT NOT NULL,         -- Apple/Google Product ID
  platform          TEXT NOT NULL CHECK (platform IN ('ios', 'android', 'web')),
  status            TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'expired', 'cancelled', 'grace_period', 'paused')),
  purchase_token    TEXT,                  -- Für serverseitige Verifikation
  expires_at        TIMESTAMPTZ,
  auto_renew        BOOLEAN DEFAULT TRUE,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(user_id, app, platform)
);

ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users können eigene Subscriptions lesen"
  ON public.subscriptions FOR SELECT
  USING (auth.uid() = user_id);


-- ---------------------------------------------------------------------------
-- GLOW: Favoriten & Lesezeichen
-- ---------------------------------------------------------------------------

CREATE TABLE public.glow_favorites (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id       UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  content_id    UUID NOT NULL REFERENCES public.daily_content(id) ON DELETE CASCADE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(user_id, content_id)
);

ALTER TABLE public.glow_favorites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users können eigene Favoriten lesen"
  ON public.glow_favorites FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users können Favoriten erstellen"
  ON public.glow_favorites FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users können Favoriten löschen"
  ON public.glow_favorites FOR DELETE
  USING (auth.uid() = user_id);


-- ---------------------------------------------------------------------------
-- TIDE: Zyklusdaten (für Phase 3 vorbereitet)
-- ---------------------------------------------------------------------------

CREATE TABLE public.tide_cycle_entries (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  entry_date      DATE NOT NULL,
  cycle_day       INTEGER,                 -- Tag im aktuellen Zyklus
  phase           TEXT CHECK (phase IN ('menstruation', 'follicular', 'ovulation', 'luteal')),
  flow_intensity  TEXT CHECK (flow_intensity IN ('light', 'medium', 'heavy', 'spotting')),
  mood            TEXT,                    -- Freitext oder vordefinierte Werte
  energy_level    INTEGER CHECK (energy_level BETWEEN 1 AND 5),
  symptoms        JSONB DEFAULT '[]',      -- Array von Symptom-Strings
  notes           TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(user_id, entry_date)
);

ALTER TABLE public.tide_cycle_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users können eigene Zyklusdaten lesen"
  ON public.tide_cycle_entries FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users können Zyklusdaten erstellen"
  ON public.tide_cycle_entries FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users können Zyklusdaten ändern"
  ON public.tide_cycle_entries FOR UPDATE
  USING (auth.uid() = user_id);


-- ---------------------------------------------------------------------------
-- PATH: Coaching-Fortschritt (für Phase 4 vorbereitet)
-- ---------------------------------------------------------------------------

CREATE TABLE public.path_coaching_progress (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  module_id       TEXT NOT NULL,            -- z.B. 'fire_element_1', 'self_worth_intro'
  phase           TEXT NOT NULL,            -- 'discovery', 'reflection', 'integration', 'mastery'
  status          TEXT NOT NULL DEFAULT 'not_started' CHECK (status IN ('not_started', 'in_progress', 'paused', 'completed')),
  started_at      TIMESTAMPTZ,
  completed_at    TIMESTAMPTZ,
  paused_at       TIMESTAMPTZ,
  metadata        JSONB DEFAULT '{}'
);

ALTER TABLE public.path_coaching_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users können eigenen Fortschritt lesen"
  ON public.path_coaching_progress FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users können Fortschritt erstellen"
  ON public.path_coaching_progress FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users können Fortschritt ändern"
  ON public.path_coaching_progress FOR UPDATE
  USING (auth.uid() = user_id);


CREATE TABLE public.path_journal_entries (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  entry_date      DATE NOT NULL,
  prompt          TEXT,                    -- Die Frage/der Impuls
  response        TEXT NOT NULL,           -- User-Eingabe
  mood            TEXT,
  aha_moment      BOOLEAN DEFAULT FALSE,   -- Markiert als AHA-Moment
  module_id       TEXT,                    -- Verknüpfung zum Coaching-Modul
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.path_journal_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users können eigene Journal-Einträge lesen"
  ON public.path_journal_entries FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users können Journal-Einträge erstellen"
  ON public.path_journal_entries FOR INSERT
  WITH CHECK (auth.uid() = user_id);


-- ---------------------------------------------------------------------------
-- FUNCTIONS: Auto-Update von updated_at
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_profiles_updated
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER on_subscriptions_updated
  BEFORE UPDATE ON public.subscriptions
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();


-- ---------------------------------------------------------------------------
-- FUNCTIONS: Neuen User automatisch in profiles anlegen
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'display_name', NEW.raw_user_meta_data->>'full_name', 'Nutzerin')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Hinweis: birth_date wird beim Onboarding gesetzt (UPDATE), nicht beim Sign-Up.
-- Der Trigger erstellt nur ein Minimal-Profil.
-- birth_date hat zwar NOT NULL, daher muss das Onboarding VOR dem ersten
-- richtigen App-Zugriff abgeschlossen sein. Alternative: DEFAULT setzen
-- und im Onboarding updaten.

-- Pragmatische Lösung: birth_date nullable machen bis Onboarding durch ist:
ALTER TABLE public.profiles ALTER COLUMN birth_date DROP NOT NULL;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
