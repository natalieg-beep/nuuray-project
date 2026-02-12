-- Migration: Gender-Feld zu profiles Tabelle hinzufügen
-- Erstellt: 2026-02-10
--
-- Zweck: Personalisierte Content-Generierung mit korrekter Ansprache
-- Werte: 'female', 'male', 'diverse', 'prefer_not_to_say'

-- 1. Spalte hinzufügen
ALTER TABLE profiles
ADD COLUMN gender TEXT CHECK (gender IN ('female', 'male', 'diverse', 'prefer_not_to_say'));

-- 2. Default-Wert für existierende User: null (optional)
-- User werden beim nächsten Login im Onboarding gefragt

-- 3. Index für schnellere Abfragen (optional, für spätere Analytics)
CREATE INDEX idx_profiles_gender ON profiles(gender);

-- 4. Kommentar
COMMENT ON COLUMN profiles.gender IS 'Geschlechtsidentität für personalisierte Content-Generierung. Optional.';
