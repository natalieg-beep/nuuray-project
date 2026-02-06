#!/bin/bash
# =============================================================================
# Test Script für geocode-place Edge Function
# =============================================================================

set -e

# Farben für Output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Konfiguration
PROJECT_URL="https://ykkayjbplutdodummcte.supabase.co"
ANON_KEY="sb_publishable_kcM8qKBrYN2xqOrevEHQGA_DdtvgmBb"

# Test cases
declare -a TEST_PLACES=(
    "Friedrichshafen, Deutschland"
    "München, Deutschland"
    "Berlin, Deutschland"
    "Wien, Österreich"
    "Zürich, Schweiz"
)

echo "🧪 Testing geocode-place Edge Function"
echo "======================================="
echo ""

# Prüfe ob User Token vorhanden ist
echo "⚠️  Für diesen Test wird ein gültiger User JWT Token benötigt."
echo "   Du kannst dich in der App einloggen und den Token aus den DevTools kopieren."
echo ""
read -p "User JWT Token eingeben (oder Enter für Anon Key): " USER_TOKEN
echo ""

if [ -z "$USER_TOKEN" ]; then
    AUTH_HEADER="Bearer $ANON_KEY"
    echo "${YELLOW}⚠️  Nutze Anon Key (könnte zu Auth-Fehler führen)${NC}"
else
    AUTH_HEADER="Bearer $USER_TOKEN"
    echo "${GREEN}✓ Nutze User Token${NC}"
fi
echo ""

# Test function
test_geocode() {
    local place=$1
    echo "Testing: ${YELLOW}$place${NC}"

    response=$(curl -s -w "\n%{http_code}" --location --request POST \
        "${PROJECT_URL}/functions/v1/geocode-place" \
        --header "Authorization: $AUTH_HEADER" \
        --header "Content-Type: application/json" \
        --data "{\"query\":\"$place\"}")

    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n-1)

    if [ "$http_code" -eq 200 ]; then
        echo "${GREEN}✓ Success (HTTP $http_code)${NC}"
        echo "$body" | jq '.'
    else
        echo "${RED}✗ Failed (HTTP $http_code)${NC}"
        echo "$body" | jq '.'
    fi
    echo ""
}

# Run all tests
for place in "${TEST_PLACES[@]}"; do
    test_geocode "$place"
    sleep 1 # Rate limiting
done

echo "======================================="
echo "🎉 Tests abgeschlossen"
