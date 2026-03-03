-- Migration: Report-Kapitel Cache-Spalten
-- Datum: 2026-02-23
--
-- Fügt 3 TEXT-Spalten für Claude-generierte Report-Kapitel hinzu.
-- Werden einmalig pro User generiert und gecacht (wie deep_synthesis_text).

ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS chapter_western TEXT,
ADD COLUMN IF NOT EXISTS chapter_bazi TEXT,
ADD COLUMN IF NOT EXISTS chapter_numerology TEXT;

-- Kommentar: Kein RLS-Update nötig — profiles hat bereits RLS,
-- User sehen nur ihre eigenen Daten (auth.uid() = id).
