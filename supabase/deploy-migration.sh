#!/bin/bash

# Deploy Migration zu Supabase
# Usage: ./deploy-migration.sh 20260207_add_daily_horoscopes.sql

MIGRATION_FILE=$1

if [ -z "$MIGRATION_FILE" ]; then
  echo "❌ Fehler: Keine Migration angegeben"
  echo "Usage: ./deploy-migration.sh <migration-file.sql>"
  exit 1
fi

MIGRATION_PATH="migrations/$MIGRATION_FILE"

if [ ! -f "$MIGRATION_PATH" ]; then
  echo "❌ Fehler: Migration nicht gefunden: $MIGRATION_PATH"
  exit 1
fi

echo "📦 Migration bereit für Deployment: $MIGRATION_FILE"
echo ""
echo "🔗 Öffne Supabase Dashboard:"
echo "   https://supabase.com/dashboard/project/ykkayjbplutdodummcte/editor"
echo ""
echo "📋 Migration-Inhalt (kopieren & im SQL Editor einfügen):"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat "$MIGRATION_PATH"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ Nach dem Deployment:"
echo "   1. Verifiziere die Tabelle im 'Table Editor'"
echo "   2. Teste ein SELECT: SELECT * FROM daily_horoscopes LIMIT 5;"
echo "   3. Prüfe RLS Policies: SELECT * FROM pg_policies WHERE tablename = 'daily_horoscopes';"
