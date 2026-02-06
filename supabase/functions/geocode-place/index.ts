// =============================================================================
// NUURAY — Edge Function: Geocode Place
// =============================================================================
// Nimmt einen Ortsnamen entgegen und gibt Koordinaten + Timezone zurück.
// Nutzt Google Places API (Autocomplete + Place Details) server-seitig.
//
// Aufruf: POST /functions/v1/geocode-place
// Body: { "query": "Friedrichshafen, Deutschland" }
// Response: { "place": "...", "latitude": 47.65, "longitude": 9.48, "timezone": "Europe/Berlin" }
//
// Auth: User JWT Token
// =============================================================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const GOOGLE_PLACES_API_KEY = Deno.env.get("GOOGLE_PLACES_API_KEY")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;

interface PlaceAutocompleteResponse {
  predictions: Array<{
    place_id: string;
    description: string;
  }>;
  status: string;
}

interface PlaceDetailsResponse {
  result: {
    geometry: {
      location: {
        lat: number;
        lng: number;
      };
    };
    formatted_address: string;
    utc_offset?: number; // in minutes
  };
  status: string;
}

interface TimezoneResponse {
  timeZoneId: string;
  timeZoneName: string;
  status: string;
}

async function getPlaceIdFromQuery(query: string): Promise<string | null> {
  const url = new URL("https://maps.googleapis.com/maps/api/place/autocomplete/json");
  url.searchParams.append("input", query);
  url.searchParams.append("key", GOOGLE_PLACES_API_KEY);
  url.searchParams.append("types", "locality|administrative_area_level_3"); // Nur Städte/Orte
  url.searchParams.append("language", "de");

  const response = await fetch(url.toString());

  if (!response.ok) {
    throw new Error(`Autocomplete API Fehler: ${response.status}`);
  }

  const data: PlaceAutocompleteResponse = await response.json();

  if (data.status === "ZERO_RESULTS" || !data.predictions || data.predictions.length === 0) {
    return null;
  }

  if (data.status !== "OK") {
    throw new Error(`Autocomplete API Status: ${data.status}`);
  }

  return data.predictions[0].place_id;
}

async function getPlaceDetails(placeId: string): Promise<{
  latitude: number;
  longitude: number;
  formattedAddress: string;
}> {
  const url = new URL("https://maps.googleapis.com/maps/api/place/details/json");
  url.searchParams.append("place_id", placeId);
  url.searchParams.append("key", GOOGLE_PLACES_API_KEY);
  url.searchParams.append("fields", "geometry,formatted_address");
  url.searchParams.append("language", "de");

  const response = await fetch(url.toString());

  if (!response.ok) {
    throw new Error(`Place Details API Fehler: ${response.status}`);
  }

  const data: PlaceDetailsResponse = await response.json();

  if (data.status !== "OK") {
    throw new Error(`Place Details API Status: ${data.status}`);
  }

  return {
    latitude: data.result.geometry.location.lat,
    longitude: data.result.geometry.location.lng,
    formattedAddress: data.result.formatted_address,
  };
}

async function getTimezone(latitude: number, longitude: number): Promise<string> {
  // Nutze aktuelle Zeit für Timezone-Lookup (berücksichtigt DST)
  const timestamp = Math.floor(Date.now() / 1000);

  const url = new URL("https://maps.googleapis.com/maps/api/timezone/json");
  url.searchParams.append("location", `${latitude},${longitude}`);
  url.searchParams.append("timestamp", timestamp.toString());
  url.searchParams.append("key", GOOGLE_PLACES_API_KEY);

  const response = await fetch(url.toString());

  if (!response.ok) {
    console.warn(`Timezone API Fehler: ${response.status}, verwende Fallback`);
    return "UTC"; // Fallback
  }

  const data: TimezoneResponse = await response.json();

  if (data.status !== "OK") {
    console.warn(`Timezone API Status: ${data.status}, verwende Fallback`);
    return "UTC"; // Fallback
  }

  return data.timeZoneId;
}

serve(async (req) => {
  // CORS Headers
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
      },
    });
  }

  try {
    // Request-Body parsen (KEINE AUTH ERFORDERLICH für Onboarding!)
    const { query } = await req.json();

    if (!query || typeof query !== "string") {
      return new Response(
        JSON.stringify({ error: "Parameter 'query' fehlt oder ist ungültig" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    // Schritt 1: Place ID von Autocomplete bekommen
    const placeId = await getPlaceIdFromQuery(query);

    if (!placeId) {
      return new Response(
        JSON.stringify({ error: "Kein Ort gefunden für diese Suche" }),
        { status: 404, headers: { "Content-Type": "application/json" } }
      );
    }

    // Schritt 2: Koordinaten von Place Details bekommen
    const { latitude, longitude, formattedAddress } = await getPlaceDetails(placeId);

    // Schritt 3: Timezone von Coordinates bekommen
    const timezone = await getTimezone(latitude, longitude);

    return new Response(
      JSON.stringify({
        place: formattedAddress,
        latitude,
        longitude,
        timezone,
      }),
      {
        status: 200,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  } catch (err) {
    console.error("Geocoding Fehler:", err);
    return new Response(
      JSON.stringify({ error: err.message || "Interner Server-Fehler" }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  }
});
