-- =============================================================================
-- Migration 004: Language-Spalte hinzufügen
-- =============================================================================
-- Fügt die language-Spalte zur profiles-Tabelle hinzu für i18n-Support

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS language TEXT DEFAULT 'de' CHECK (language IN ('de', 'en', 'es', 'fr', 'tr'));

-- Kommentar: Wir nutzen lowercase (de, en) sowohl in der DB als auch in der App
-- Konsistent mit der Flutter Locale (Locale('de'), Locale('en'))
