-- Migration: Signatur-Check-In Tabellen
-- Erstellt: 2026-02-22
-- Beschreibung: Cache-Tabelle für Check-In Ergebnisse + History-Tabelle

-- ============================================================
-- 1. CACHE-TABELLE: signature_checkin_results
-- ============================================================
-- Speichert das aktuelle Ergebnis pro User + Kombination.
-- UPSERT-Logik: Bei gleicher Kombination wird überschrieben.

CREATE TABLE IF NOT EXISTS signature_checkin_results (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  checkin_key TEXT NOT NULL,           -- z.B. "work_exhausted_clarity"
  language TEXT NOT NULL DEFAULT 'de',
  result_text TEXT NOT NULL,           -- Die 2-3 Sätze
  impulse_text TEXT NOT NULL,          -- Der konkrete Impuls
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, checkin_key, language)
);

COMMENT ON TABLE signature_checkin_results IS 'Cache für Signatur-Check-In Ergebnisse. Pro User + Kombination (4×4×4 = 64) ein Eintrag.';
COMMENT ON COLUMN signature_checkin_results.checkin_key IS 'Format: {kategorie}_{gefühl}_{bedürfnis}, z.B. "work_exhausted_clarity"';

-- RLS
ALTER TABLE signature_checkin_results ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own checkin results"
  ON signature_checkin_results FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own checkin results"
  ON signature_checkin_results FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own checkin results"
  ON signature_checkin_results FOR UPDATE
  USING (auth.uid() = user_id);

-- Index
CREATE INDEX IF NOT EXISTS idx_checkin_results_user_key
  ON signature_checkin_results(user_id, checkin_key, language);

-- ============================================================
-- 2. HISTORY-TABELLE: signature_checkin_history
-- ============================================================
-- Append-Only: Jeder Check-In wird gespeichert (auch wiederholte Kombinationen).
-- Ermöglicht spätere History-Ansicht.

CREATE TABLE IF NOT EXISTS signature_checkin_history (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  checkin_key TEXT NOT NULL,
  language TEXT NOT NULL DEFAULT 'de',
  result_text TEXT NOT NULL,
  impulse_text TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE signature_checkin_history IS 'History aller Check-Ins pro User. Append-Only für spätere Verlaufsansicht.';

-- RLS
ALTER TABLE signature_checkin_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own checkin history"
  ON signature_checkin_history FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own checkin history"
  ON signature_checkin_history FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Index
CREATE INDEX IF NOT EXISTS idx_checkin_history_user
  ON signature_checkin_history(user_id, created_at DESC);
