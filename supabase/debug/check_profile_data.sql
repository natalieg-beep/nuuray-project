-- Debug: Check Profile Data für Karmic Debt
-- Ausführen in Supabase SQL Editor

SELECT
  id,
  display_name,
  full_first_names,
  birth_name,
  last_name,
  birth_date,
  birth_time,
  birth_latitude,
  birth_longitude,
  birth_timezone
FROM profiles
WHERE id = '584f27d2-09a2-47e6-8f70-c0f3a015b1b6';

-- Erwartung:
-- full_first_names = 'Natalie Frauke'
-- birth_name = 'Pawlowski'
-- Wenn eines dieser Felder NULL ist, kann keine Karmic Debt berechnet werden!
