-- Migration: Fix RLS Policy für daily_horoscopes
-- Erstellt: 2026-02-10
--
-- Problem: Authenticated users können keine Horoskope einfügen
-- Lösung: Policy für INSERT hinzufügen (für Client-seitige Cache-Generierung)

-- 1. Neue Policy: Authenticated users können Horoskope einfügen
CREATE POLICY "Authenticated users can insert daily horoscopes"
  ON daily_horoscopes FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Anmerkung:
-- - Die Unique-Constraint verhindert Duplikate
-- - Authenticated users können nur lesen und einfügen, nicht updaten/löschen
-- - Service role hat weiterhin volle Kontrolle (für Edge Functions)
