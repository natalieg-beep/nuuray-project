-- Migration: Display Name Number hinzufügen
-- Datum: 2026-02-08
-- Beschreibung: Fügt display_name_number Spalte zur birth_charts Tabelle hinzu
--               für Rufnamen-Numerologie (z.B. "Natalie" → 8)

-- Display Name Number Spalte hinzufügen
ALTER TABLE birth_charts
ADD COLUMN IF NOT EXISTS display_name_number INTEGER;

-- Kommentar hinzufügen
COMMENT ON COLUMN birth_charts.display_name_number IS 'Numerologie-Zahl des Rufnamens (1-9/11/22/33). Beispiel: "Natalie" = 8';
