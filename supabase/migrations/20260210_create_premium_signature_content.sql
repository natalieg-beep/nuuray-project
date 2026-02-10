-- Migration: Premium Signature Content
-- Erstellt: 2026-02-10
-- Beschreibung: Speichert personalisierte Premium-Texte für jede Userin (einmalig generiert)

-- Premium Signature Content Tabelle
CREATE TABLE IF NOT EXISTS premium_signature_content (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  locale TEXT NOT NULL, -- 'de', 'en'

  -- Die große Synthese (~400-600 Wörter)
  cosmic_synthesis TEXT,

  -- Detaillierte Texte pro Position (~200 Wörter)
  sun_detail TEXT,
  moon_detail TEXT,
  rising_detail TEXT,
  day_master_detail TEXT,

  -- Interaktionen (~150 Wörter)
  sun_moon_interaction TEXT,
  pillar_synthesis TEXT,
  numerology_analysis TEXT,

  -- Metadata
  generated_at TIMESTAMPTZ DEFAULT NOW(),
  tokens_used INTEGER, -- Claude API Token-Usage für Tracking

  -- Unique Constraint: Pro User + Locale nur ein Eintrag
  UNIQUE(user_id, locale)
);

-- Index für User-Lookups
CREATE INDEX idx_premium_signature_user
  ON premium_signature_content(user_id);

-- Kommentar
COMMENT ON TABLE premium_signature_content IS
  'Premium-Content: Personalisierte Synthese-Texte, einmalig generiert von Claude API';

COMMENT ON COLUMN premium_signature_content.cosmic_synthesis IS
  'Die große Synthese: Verbindet alle drei Systeme (~400-600 Wörter)';

COMMENT ON COLUMN premium_signature_content.sun_moon_interaction IS
  'Interaktion zwischen Sonne und Mond im Geburts-Chart';

COMMENT ON COLUMN premium_signature_content.tokens_used IS
  'Token-Usage für Kostenkalkulation (~$0.03-0.04 pro Generierung)';

-- RLS aktivieren
ALTER TABLE premium_signature_content ENABLE ROW LEVEL SECURITY;

-- Policy: User sehen nur ihre eigenen Premium-Texte
CREATE POLICY premium_signature_select_own
  ON premium_signature_content
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Policy: Edge Function kann schreiben (via Service Role)
CREATE POLICY premium_signature_insert_service
  ON premium_signature_content
  FOR INSERT
  TO service_role
  WITH CHECK (true);

-- Policy: Edge Function kann aktualisieren (z.B. Re-Generierung)
CREATE POLICY premium_signature_update_service
  ON premium_signature_content
  FOR UPDATE
  TO service_role
  USING (true);
