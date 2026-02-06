#!/bin/bash
# =============================================================================
# Supabase Edge Functions — Deploy Script
# =============================================================================

set -e

echo "🚀 Deploying Supabase Edge Functions..."
echo ""

# Prüfe ob Supabase CLI installiert ist
if ! command -v supabase &> /dev/null; then
    echo "❌ Supabase CLI nicht gefunden!"
    echo "   Installiere mit: brew install supabase/tap/supabase"
    exit 1
fi

# Prüfe ob mit Projekt verbunden
if [ ! -f .temp/project-ref ]; then
    echo "⚠️  Noch nicht mit Supabase Projekt verbunden."
    echo "   Führe aus: supabase link --project-ref ykkayjbplutdodummcte"
    read -p "Jetzt verbinden? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        supabase link --project-ref ykkayjbplutdodummcte
    else
        exit 1
    fi
fi

echo "📦 Deploying functions..."
echo ""

# Deploy geocode-place
echo "1️⃣  Deploying geocode-place..."
supabase functions deploy geocode-place
echo "✅ geocode-place deployed"
echo ""

# Deploy generate-daily-content
echo "2️⃣  Deploying generate-daily-content..."
supabase functions deploy generate-daily-content
echo "✅ generate-daily-content deployed"
echo ""

echo "🎉 Alle Functions erfolgreich deployed!"
echo ""
echo "📝 Nächste Schritte:"
echo "   1. Secrets setzen (falls noch nicht geschehen):"
echo "      supabase secrets set GOOGLE_PLACES_API_KEY=..."
echo "   2. Functions testen:"
echo "      supabase functions logs geocode-place --follow"
