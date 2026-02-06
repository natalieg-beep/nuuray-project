// =============================================================================
// NUURAY — Edge Function: Tägliche Content-Generierung
// =============================================================================
// Wird als Cron-Job ausgeführt (täglich um 04:00 UTC).
// Generiert Basis-Horoskope für alle 12 Sternzeichen via Claude API.
// Sprachen: Deutsch + Englisch.
//
// Aufruf: POST /functions/v1/generate-daily-content
// Auth: Service-Role Key (nicht User-Token)
// =============================================================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const ANTHROPIC_API_KEY = Deno.env.get("ANTHROPIC_API_KEY")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const ZODIAC_SIGNS = [
  "aries", "taurus", "gemini", "cancer", "leo", "virgo",
  "libra", "scorpio", "sagittarius", "capricorn", "aquarius", "pisces",
];

const LANGUAGES = ["de", "en"];

interface ClaudeResponse {
  content: Array<{ type: string; text: string }>;
}

async function callClaude(prompt: string): Promise<string> {
  const response = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-api-key": ANTHROPIC_API_KEY,
      "anthropic-version": "2023-06-01",
    },
    body: JSON.stringify({
      model: "claude-sonnet-4-20250514",
      max_tokens: 500,
      messages: [{ role: "user", content: prompt }],
    }),
  });

  if (!response.ok) {
    throw new Error(`Claude API Fehler: ${response.status} ${await response.text()}`);
  }

  const data: ClaudeResponse = await response.json();
  return data.content
    .filter((block) => block.type === "text")
    .map((block) => block.text)
    .join("");
}

serve(async (req) => {
  try {
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
    const today = new Date().toISOString().split("T")[0];

    // Prüfen ob Content für heute schon existiert
    const { data: existing } = await supabase
      .from("daily_content")
      .select("id")
      .eq("content_date", today)
      .eq("content_type", "horoscope")
      .limit(1);

    if (existing && existing.length > 0) {
      return new Response(
        JSON.stringify({ message: "Content für heute existiert bereits.", date: today }),
        { headers: { "Content-Type": "application/json" } }
      );
    }

    // TODO: Mondphase und Tagesenergie berechnen/abrufen
    // Für MVP: Platzhalter-Werte
    const moonPhase = "zunehmender Mond"; // Aus moon_phases Tabelle laden
    const dailyEnergy = "reflektiv";

    const results: Array<{ sign: string; lang: string; status: string }> = [];

    for (const sign of ZODIAC_SIGNS) {
      for (const lang of LANGUAGES) {
        try {
          const prompt = buildHoroscopePrompt(sign, today, moonPhase, dailyEnergy, lang);
          const horoscope = await callClaude(prompt);

          const { error } = await supabase.from("daily_content").insert({
            content_date: today,
            content_type: "horoscope",
            sun_sign: sign,
            language: lang,
            title: null,
            body: horoscope,
            metadata: { moon_phase: moonPhase, daily_energy: dailyEnergy },
            app: "glow",
          });

          if (error) throw error;
          results.push({ sign, lang, status: "ok" });
        } catch (err) {
          results.push({ sign, lang, status: `error: ${err.message}` });
        }

        // Rate Limiting: 500ms Pause zwischen Calls
        await new Promise((resolve) => setTimeout(resolve, 500));
      }
    }

    return new Response(
      JSON.stringify({ date: today, results }),
      { headers: { "Content-Type": "application/json" } }
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});

function buildHoroscopePrompt(
  sign: string,
  date: string,
  moonPhase: string,
  dailyEnergy: string,
  language: string
): string {
  const langInstruction = language === "de"
    ? "Schreibe auf Deutsch."
    : "Write in English.";

  return `Du bist eine charmante, kluge Astrologin, die täglich Horoskope schreibt.
Dein Stil ist warm, überraschend und nie langweilig. Du vermeidest Klischees.

Schreibe ein Tageshoroskop für ${sign} am ${date}.

Kontext:
- Mondphase: ${moonPhase}
- Tagesenergie: ${dailyEnergy}

${langInstruction}
Länge: 150-200 Wörter
Ton: Lebendig, überraschend, mit einem konkreten Tipp für den Tag.
Format: Fließtext, keine Aufzählungen. Ein Absatz.

Beginne NICHT mit "Liebe/r ${sign}" oder ähnlichen Floskeln.
Beginne stattdessen mit einer konkreten, überraschenden Beobachtung.`;
}
