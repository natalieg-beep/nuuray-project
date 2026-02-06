-- =============================================================================
-- Migration 003: Profile Spalten aufräumen
-- =============================================================================

-- Entferne doppelte/alte Spalten, behalte nur die neuen
ALTER TABLE public.profiles
  DROP COLUMN IF EXISTS birth_city,
  DROP COLUMN IF EXISTS birth_lat,
  DROP COLUMN IF EXISTS birth_lng;

-- Kommentar: Wir nutzen jetzt nur noch:
-- - birth_place (statt birth_city)
-- - birth_latitude (statt birth_lat)
-- - birth_longitude (statt birth_lng)
-- - birth_timezone (neu)
