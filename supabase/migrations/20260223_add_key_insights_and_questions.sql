-- Migration: Key Insights + Reflection Questions für Signatur-Screen
-- Erstellt: 2026-02-23
-- Kontext: Ersetzt den 3-Tap Check-In durch statische Schlüsselerkenntnisse + Reflexionsfragen
--          die via Claude API aus der Deep Synthesis extrahiert werden.

-- 1. key_insights: 3 Schlüsselerkenntnisse als JSONB-Array
--    Format: [{"label": "Das Muster", "text": "Du startest hundert..."}, ...]
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS key_insights JSONB;

-- 2. reflection_questions: 7 Reflexionsfragen als JSONB-Array
--    Format: ["Frage 1", "Frage 2", ...]
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS reflection_questions JSONB;

-- Kein separates RLS nötig — profiles hat bereits RLS aktiv:
-- User sehen nur eigene Daten (auth.uid() = id)

-- Hinweis: Bei Profil-Änderung (Geburtsdaten) müssen key_insights + reflection_questions
-- zusammen mit deep_synthesis_text gelöscht werden (Cache-Invalidierung).
