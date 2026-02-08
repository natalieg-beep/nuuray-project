-- Migration: Archetyp Signatur-Satz Feld zu profiles hinzufügen
-- Erstellt: 2026-02-08
-- Beschreibung: Fügt signature_text Feld für Claude API generierten Archetyp-Signatur-Satz hinzu

-- Füge signature_text Spalte zu profiles Tabelle hinzu
ALTER TABLE profiles
ADD COLUMN signature_text TEXT NULL;

-- Kommentar für Dokumentation
COMMENT ON COLUMN profiles.signature_text IS
'Personalisierter Archetyp-Signatur-Satz (2-3 Sätze, ~150-200 Zeichen).
Wird einmalig beim Onboarding via Claude API generiert und gecacht.
Kombiniert Archetyp-Name (aus Lebenszahl) + Bazi-Adjektiv (aus Day Master) + alle drei Systeme in einer Synthese.';
