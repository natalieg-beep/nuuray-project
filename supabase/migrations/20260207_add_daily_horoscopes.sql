-- Migration: daily_horoscopes Tabelle für gecachte Tageshoroskope
-- Erstellt: 2026-02-07
--
-- Strategie:
-- - Basis-Horoskope werden täglich um 4:00 UTC generiert (Cron Job via Edge Function)
-- - Ein Horoskop pro Sternzeichen + Mondphase + Sprache
-- - Cache: 24h (bis nächste Generierung)
-- - User sehen gecachten Content (kosteneffizient)
-- - Premium User bekommen zusätzliche Personalisierung (später)

-- 1. Tabelle erstellen
CREATE TABLE IF NOT EXISTS daily_horoscopes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Content-Identifikation
  date DATE NOT NULL,                                    -- Datum des Horoskops (UTC)
  zodiac_sign TEXT NOT NULL,                             -- Sternzeichen (en: "aries", "taurus", ...)
  language TEXT NOT NULL DEFAULT 'de',                   -- Sprache ("de", "en")
  moon_phase TEXT,                                       -- Mondphase ("new_moon", "waxing_crescent", ...)

  -- Generierter Content
  content_text TEXT NOT NULL,                            -- Haupttext des Horoskops (von Claude API)
  content_metadata JSONB,                                -- Zusätzliche Metadaten (Energie-Level, Keywords, etc.)

  -- Claude API Metadaten
  model_used TEXT,                                       -- Claude Model (z.B. "claude-sonnet-4-20250514")
  tokens_used INTEGER,                                   -- Token-Count für Cost-Tracking
  generation_time_ms INTEGER,                            -- Generierungsdauer in ms

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Unique Constraint: Ein Horoskop pro Tag + Sternzeichen + Sprache + Mondphase
CREATE UNIQUE INDEX idx_daily_horoscopes_unique
  ON daily_horoscopes(date, zodiac_sign, language, COALESCE(moon_phase, 'none'));

-- 3. Indizes für schnelle Abfragen
CREATE INDEX idx_daily_horoscopes_date ON daily_horoscopes(date);
CREATE INDEX idx_daily_horoscopes_zodiac ON daily_horoscopes(zodiac_sign);
CREATE INDEX idx_daily_horoscopes_language ON daily_horoscopes(language);
CREATE INDEX idx_daily_horoscopes_date_zodiac ON daily_horoscopes(date, zodiac_sign);

-- 4. RLS aktivieren (Public Read für alle authentifizierten User)
ALTER TABLE daily_horoscopes ENABLE ROW LEVEL SECURITY;

-- 5. Policy: Alle authentifizierten User können Horoskope lesen
CREATE POLICY "Authenticated users can read daily horoscopes"
  ON daily_horoscopes FOR SELECT
  TO authenticated
  USING (true);

-- 6. Policy: Nur Service Role kann Horoskope erstellen/updaten (für Edge Function)
CREATE POLICY "Service role can insert/update daily horoscopes"
  ON daily_horoscopes FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- 7. Funktion: Automatisches updated_at Timestamp
CREATE OR REPLACE FUNCTION update_daily_horoscopes_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_daily_horoscopes_updated_at
  BEFORE UPDATE ON daily_horoscopes
  FOR EACH ROW
  EXECUTE FUNCTION update_daily_horoscopes_updated_at();

-- 8. Funktion: Alte Horoskope löschen (Cleanup, älter als 7 Tage)
CREATE OR REPLACE FUNCTION cleanup_old_daily_horoscopes()
RETURNS void AS $$
BEGIN
  DELETE FROM daily_horoscopes
  WHERE date < CURRENT_DATE - INTERVAL '7 days';
END;
$$ LANGUAGE plpgsql;

-- 9. Beispiel-Daten (für Testing, kann später entfernt werden)
INSERT INTO daily_horoscopes (date, zodiac_sign, language, moon_phase, content_text, model_used, tokens_used)
VALUES
  (CURRENT_DATE, 'aries', 'de', 'waxing_moon',
   'Heute ist ein großartiger Tag für neue Beginne! Die Energie des zunehmenden Mondes unterstützt dich dabei, mutig voranzuschreiten. Vertraue auf deine Intuition und lass dich nicht von Zweifeln aufhalten.',
   'claude-sonnet-4-20250514', 150),
  (CURRENT_DATE, 'cancer', 'de', 'waxing_moon',
   'Der zunehmende Mond lädt dich ein, deine emotionalen Bedürfnisse zu pflegen. Nimm dir heute Zeit für Selbstfürsorge und vertraue darauf, dass deine Sensibilität eine Stärke ist.',
   'claude-sonnet-4-20250514', 145)
ON CONFLICT (date, zodiac_sign, language, COALESCE(moon_phase, 'none'))
DO NOTHING;

-- 10. Kommentare für Dokumentation
COMMENT ON TABLE daily_horoscopes IS 'Gecachte Tageshoroskope, täglich um 4:00 UTC generiert via Edge Function';
COMMENT ON COLUMN daily_horoscopes.zodiac_sign IS 'Englische Lowercase-Namen: aries, taurus, gemini, cancer, leo, virgo, libra, scorpio, sagittarius, capricorn, aquarius, pisces';
COMMENT ON COLUMN daily_horoscopes.moon_phase IS 'Mondphase zum Zeitpunkt der Generierung (Optional, kann null sein)';
COMMENT ON COLUMN daily_horoscopes.content_metadata IS 'JSONB für zusätzliche Daten wie Energy-Level, Keywords, Premium-Hints';
