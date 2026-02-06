-- =============================================================================
-- Migration 002: Onboarding-Felder hinzufügen
-- =============================================================================

-- Felder für vollständige Name-Daten
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS full_first_names TEXT,
  ADD COLUMN IF NOT EXISTS last_name TEXT,
  ADD COLUMN IF NOT EXISTS birth_name TEXT;

-- Onboarding-Status
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS onboarding_completed BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS has_birth_time BOOLEAN DEFAULT FALSE;

-- Timezone und Geburtsort (alternative Spalten-Namen für Kompatibilität)
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS birth_place TEXT,
  ADD COLUMN IF NOT EXISTS birth_latitude DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS birth_longitude DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS birth_timezone TEXT;

-- Index für Onboarding-Status
CREATE INDEX IF NOT EXISTS idx_profiles_onboarding
  ON public.profiles(onboarding_completed);
