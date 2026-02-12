-- Force Chart Recalculation
-- Löscht das Birth Chart → Beim nächsten App-Start wird es neu berechnet

DELETE FROM birth_charts
WHERE user_id = '584f27d2-09a2-47e6-8f70-c0f3a015b1b6';

-- Nach Ausführung:
-- 1. App neu starten ODER
-- 2. Zum Signature Screen navigieren
-- → Chart wird automatisch neu berechnet mit aktuellen Profil-Daten
