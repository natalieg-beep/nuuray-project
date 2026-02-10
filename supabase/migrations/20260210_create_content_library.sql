-- Migration: Content Library für Freemium-Texte
-- Erstellt: 2026-02-10
-- Beschreibung: Speichert statische Kurzbeschreibungen für alle astrologischen/numerologischen Konzepte

-- Content Library Tabelle
CREATE TABLE IF NOT EXISTS content_library (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category TEXT NOT NULL, -- 'sun_sign', 'moon_sign', 'rising_sign', 'bazi_day_master', 'life_path_number', etc.
  key TEXT NOT NULL, -- 'aries', 'taurus', 'yang_wood_rat', '1', '11', '22', etc.
  locale TEXT NOT NULL, -- 'de', 'en'
  title TEXT NOT NULL, -- "Widder", "Aries", "Yang Holz Ratte", etc.
  description TEXT NOT NULL, -- ~70 Wörter, inspirierender Text
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Unique Index für schnelle Lookups
CREATE UNIQUE INDEX idx_content_library_lookup
  ON content_library(category, key, locale);

-- Index für Kategorie-Queries
CREATE INDEX idx_content_library_category
  ON content_library(category);

-- Kommentar
COMMENT ON TABLE content_library IS
  'Freemium-Content: Statische Kurzbeschreibungen für astrologische und numerologische Konzepte';

COMMENT ON COLUMN content_library.category IS
  'Kategorie: sun_sign, moon_sign, rising_sign, bazi_day_master, bazi_element, chinese_zodiac, life_path_number, soul_urge_number, expression_number, etc.';

COMMENT ON COLUMN content_library.key IS
  'Eindeutiger Key innerhalb der Kategorie (z.B. "aries", "yang_wood_rat", "11")';

COMMENT ON COLUMN content_library.description IS
  'Kurzbeschreibung (~70 Wörter), warm & inspirierend, generiert von Claude API';

-- RLS aktivieren (Public Read für authentifizierte User)
ALTER TABLE content_library ENABLE ROW LEVEL SECURITY;

-- Policy: Alle authentifizierten User können lesen
CREATE POLICY content_library_select_authenticated
  ON content_library
  FOR SELECT
  TO authenticated
  USING (true);

-- Policy: Nur Service Role kann schreiben (für Seed-Script)
CREATE POLICY content_library_insert_service
  ON content_library
  FOR INSERT
  TO service_role
  WITH CHECK (true);

CREATE POLICY content_library_update_service
  ON content_library
  FOR UPDATE
  TO service_role
  USING (true);
