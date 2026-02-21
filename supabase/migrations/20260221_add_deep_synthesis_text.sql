-- Migration: 20260221_add_deep_synthesis_text
-- Beschreibung: Fügt deep_synthesis_text Feld für die tiefe Drei-System-Synthese hinzu
--
-- Diese Spalte speichert die einmalig generierte, tiefe Synthese aus
-- Western Astrology + Bazi + Numerologie (700-1000 Wörter).
-- Wird via Claude API generiert und gecacht, ähnlich wie signature_text.

-- Füge deep_synthesis_text Spalte zu profiles Tabelle hinzu
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS deep_synthesis_text TEXT NULL;

COMMENT ON COLUMN profiles.deep_synthesis_text IS
  'Tiefe Drei-System-Synthese (700-1000 Wörter), generiert via Claude API. '
  'Einmalig pro User, gecacht. Folgt NUURAY Brand Soul Philosophie: '
  'Verwobene Synthese aus Western Astrology + Bazi + Numerologie.';
