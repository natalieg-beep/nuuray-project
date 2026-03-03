-- =============================================================
-- Migration: 20260302_invalidate_degree_cache
-- Zweck: Cache-Invalidierung nach Bugfix der Grad-Berechnung
--
-- Bugfix: _calculateDegreeInSign() für Mond und Aszendent
-- verwendete fehlerhafte Zeit-Approximationen statt der
-- astronomischen Längenberechnungen aus ZodiacCalculator.
--
-- Folge: moon_degree und ascendant_degree waren falsch gecacht.
-- Beispiel: Natalies Mond zeigte 10° Waage statt korrekt 23°.
--
-- Fix: Alle birth_charts löschen → werden beim nächsten App-Start
-- automatisch mit korrekten Werten neu berechnet.
-- Außerdem chapter_western/bazi/numerology löschen, da diese
-- auf die falschen Grad-Werte referenzieren konnten.
-- =============================================================

-- 1. Alle berechneten Birth Charts löschen
-- (werden automatisch neu berechnet beim nächsten App-Start via signatureProvider)
DELETE FROM birth_charts;

-- 2. Gecachte Claude-Kapitel zurücksetzen die Grad-Werte enthalten können
-- (chapter_western kann "bei X Grad" Aussagen enthalten — werden neu generiert)
UPDATE profiles
SET
  chapter_western = NULL,
  chapter_bazi = NULL,
  chapter_numerology = NULL
WHERE
  chapter_western IS NOT NULL
  OR chapter_bazi IS NOT NULL
  OR chapter_numerology IS NOT NULL;

-- HINWEIS: deep_synthesis_text, key_insights und reflection_questions
-- werden NICHT zurückgesetzt, da diese keine spezifischen Grad-Angaben enthalten.
-- Sie können wiederverwendet werden.
