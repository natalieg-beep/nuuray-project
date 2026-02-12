-- =============================================================================
-- 🚀 ANLEITUNG: Diese SQL im Supabase Dashboard SQL Editor ausführen
-- =============================================================================
-- 1. Gehe zu: https://supabase.com/dashboard/project/YOUR_PROJECT_ID/sql/new
-- 2. Kopiere dieses SQL
-- 3. Klicke "RUN" (unten rechts)
-- =============================================================================

-- Erweiterte Numerologie-Felder hinzufügen
ALTER TABLE public.birth_charts
ADD COLUMN IF NOT EXISTS display_name_number INTEGER,
ADD COLUMN IF NOT EXISTS birthday_number INTEGER,
ADD COLUMN IF NOT EXISTS attitude_number INTEGER,
ADD COLUMN IF NOT EXISTS personal_year INTEGER,
ADD COLUMN IF NOT EXISTS maturity_number INTEGER,
ADD COLUMN IF NOT EXISTS birth_expression_number INTEGER,
ADD COLUMN IF NOT EXISTS birth_soul_urge_number INTEGER,
ADD COLUMN IF NOT EXISTS birth_personality_number INTEGER,
ADD COLUMN IF NOT EXISTS birth_name TEXT,
ADD COLUMN IF NOT EXISTS current_expression_number INTEGER,
ADD COLUMN IF NOT EXISTS current_soul_urge_number INTEGER,
ADD COLUMN IF NOT EXISTS current_personality_number INTEGER,
ADD COLUMN IF NOT EXISTS current_name TEXT,
ADD COLUMN IF NOT EXISTS karmic_debt_life_path INTEGER,
ADD COLUMN IF NOT EXISTS karmic_debt_expression INTEGER,
ADD COLUMN IF NOT EXISTS karmic_debt_soul_urge INTEGER,
ADD COLUMN IF NOT EXISTS challenge_numbers INTEGER[],
ADD COLUMN IF NOT EXISTS karmic_lessons INTEGER[],
ADD COLUMN IF NOT EXISTS bridge_life_path_expression INTEGER,
ADD COLUMN IF NOT EXISTS bridge_soul_urge_personality INTEGER;

-- Bestätigung
SELECT
  'Migration erfolgreich!' as status,
  COUNT(*) as total_columns
FROM information_schema.columns
WHERE table_name = 'birth_charts'
  AND table_schema = 'public';
