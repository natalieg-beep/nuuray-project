-- =============================================================================
-- Migration: Erweiterte Numerologie-Felder für birth_charts
-- Datum: 2026-02-10
-- =============================================================================
-- Fügt alle fehlenden Numerologie-Spalten hinzu, die im BirthChart-Model
-- definiert sind, aber noch nicht in der Datenbank existieren.
-- =============================================================================

-- Numerologie - Kern-Zahlen
ALTER TABLE public.birth_charts
ADD COLUMN IF NOT EXISTS display_name_number INTEGER,
ADD COLUMN IF NOT EXISTS birthday_number INTEGER,
ADD COLUMN IF NOT EXISTS attitude_number INTEGER,
ADD COLUMN IF NOT EXISTS personal_year INTEGER,
ADD COLUMN IF NOT EXISTS maturity_number INTEGER;

-- Numerologie - Birth Energy (Geburtsname)
ALTER TABLE public.birth_charts
ADD COLUMN IF NOT EXISTS birth_expression_number INTEGER,
ADD COLUMN IF NOT EXISTS birth_soul_urge_number INTEGER,
ADD COLUMN IF NOT EXISTS birth_personality_number INTEGER,
ADD COLUMN IF NOT EXISTS birth_name TEXT;

-- Numerologie - Current Energy (aktueller Name)
ALTER TABLE public.birth_charts
ADD COLUMN IF NOT EXISTS current_expression_number INTEGER,
ADD COLUMN IF NOT EXISTS current_soul_urge_number INTEGER,
ADD COLUMN IF NOT EXISTS current_personality_number INTEGER,
ADD COLUMN IF NOT EXISTS current_name TEXT;

-- Numerologie - Erweitert (Karmic Debt, Challenges, Lessons, Bridges)
ALTER TABLE public.birth_charts
ADD COLUMN IF NOT EXISTS karmic_debt_life_path INTEGER,
ADD COLUMN IF NOT EXISTS karmic_debt_expression INTEGER,
ADD COLUMN IF NOT EXISTS karmic_debt_soul_urge INTEGER,
ADD COLUMN IF NOT EXISTS challenge_numbers INTEGER[],  -- Array von Zahlen
ADD COLUMN IF NOT EXISTS karmic_lessons INTEGER[],     -- Array von Zahlen
ADD COLUMN IF NOT EXISTS bridge_life_path_expression INTEGER,
ADD COLUMN IF NOT EXISTS bridge_soul_urge_personality INTEGER;

-- Kommentar für zukünftige Entwickler
COMMENT ON COLUMN public.birth_charts.display_name_number IS 'Numerologie des Rufnamens (z.B. "Natalie" = 8)';
COMMENT ON COLUMN public.birth_charts.birth_expression_number IS 'Expression Number basierend auf Geburtsnamen';
COMMENT ON COLUMN public.birth_charts.current_expression_number IS 'Expression Number basierend auf aktuellem Namen (falls geändert)';
COMMENT ON COLUMN public.birth_charts.challenge_numbers IS 'Array von Challenge Numbers (typisch 4 Zahlen)';
COMMENT ON COLUMN public.birth_charts.karmic_lessons IS 'Array von fehlenden Zahlen im Namen (Karmic Lessons)';
