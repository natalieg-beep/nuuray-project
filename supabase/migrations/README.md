# Supabase Migrationen

## Deployment

Migrationen werden manuell über das Supabase Dashboard deployed:

1. Öffne: https://supabase.com/dashboard/project/ykkayjbplutdodummcte/editor
2. Gehe zu "SQL Editor"
3. Kopiere den Inhalt der Migration-Datei
4. Führe das SQL aus
5. Verifiziere die Tabelle im "Table Editor"

## Migrationen-Historie

| Datei | Beschreibung | Status |
|-------|--------------|--------|
| `001_initial_schema.sql` | Basis-Schema (profiles, birth_charts) | ✅ Deployed |
| `002_add_onboarding_fields.sql` | Onboarding-Felder (Namen, Geburtsort) | ✅ Deployed |
| `003_cleanup_profile_columns.sql` | Alte Spalten entfernen | ✅ Deployed |
| `20260206_add_premium_status.sql` | Premium-Status & Subscriptions | ✅ Deployed |
| `20260207_add_daily_horoscopes.sql` | Daily Horoscopes Tabelle | ⏳ Bereit für Deployment |

## Naming Convention

- Format: `YYYYMMDD_description.sql`
- Beschreibung in snake_case
- Immer mit `-- Migration:` Kommentar starten
