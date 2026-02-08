// Edge Function: Generate Daily Horoscopes (Phase 2 - INAKTIV)
//
// Zweck: Täglich um 4:00 UTC ausführen (via Cron Job)
// Generiert Horoskope NUR für aktive User (sun_sign + preferred_language)
// Cached in daily_horoscopes Tabelle
//
// Status: Vorbereitet, aber NICHT deployed (Phase 1 nutzt On-Demand)
// Kosten: ~$0.50/Tag = ~$15/Monat (wenn aktiviert)

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// Environment Variables werden von Supabase Edge Functions Secrets bereitgestellt
// Secrets müssen über: Edge Functions → Secrets (nicht Vault!) gesetzt werden

const ANTHROPIC_API_KEY = Deno.env.get('ANTHROPIC_API_KEY')!
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

const ALL_ZODIAC_SIGNS = [
  'aries',
  'taurus',
  'gemini',
  'cancer',
  'leo',
  'virgo',
  'libra',
  'scorpio',
  'sagittarius',
  'capricorn',
  'aquarius',
  'pisces',
]

const languages = ['de', 'en']

interface HoroscopeResult {
  zodiacSign: string
  language: string
  text: string
  tokens: number
  success: boolean
  error?: string
}

serve(async (req) => {
  try {
    console.log('🌟 Starting daily horoscope generation...')

    // Supabase Client (mit Service Role Key für Admin-Zugriff)
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

    const today = new Date().toISOString().split('T')[0]
    const results: HoroscopeResult[] = []
    let totalTokens = 0
    let successCount = 0
    let errorCount = 0

    // 🎯 SMART: Finde heraus welche Zeichen + Sprachen aktive User nutzen
    console.log('🔍 Prüfe aktive User-Profile (Zeichen + Sprachen)...')
    const { data: activeUsers, error: usersError} = await supabase
      .from('profiles')
      .select('sun_sign, preferred_language')
      .not('sun_sign', 'is', null)

    if (usersError) {
      console.warn('⚠️ Konnte User-Profile nicht abfragen, generiere alle:', usersError)
    }

    // Extrahiere unique Zeichen+Sprache-Kombinationen
    const neededCombinations = activeUsers && activeUsers.length > 0
      ? [...new Set(activeUsers.map(u => `${u.sun_sign}:${u.preferred_language || 'de'}`).filter(Boolean))]
      : ALL_ZODIAC_SIGNS.flatMap(sign => languages.map(lang => `${sign}:${lang}`)) // Fallback

    console.log(`📊 Benötigte Kombinationen: ${neededCombinations.length}`)
    console.log(`   Beispiele: ${neededCombinations.slice(0, 3).join(', ')}...`)

    // Generiere nur benötigte Kombinationen (keine doppelten Sprachen!)
    // Mit Batching (5 parallel) um Worker-Limits zu vermeiden
    const tasks = neededCombinations.map(combo => {
      const [zodiacSign, language] = combo.split(':')
      return { zodiacSign, language }
    })

    console.log(`📝 Starte Generierung von ${tasks.length} Horoskopen...`)

    // Batching: Verarbeite 5 Horoskope parallel, dann nächste 5, etc.
    // Verhindert Worker-Limits bei vielen Usern
    const BATCH_SIZE = 5
    const batches = []
    for (let i = 0; i < tasks.length; i += BATCH_SIZE) {
      batches.push(tasks.slice(i, i + BATCH_SIZE))
    }

    console.log(`📦 Verarbeite in ${batches.length} Batches (${BATCH_SIZE} parallel pro Batch)`)

    // Verarbeite Batches nacheinander, innerhalb jedes Batches parallel
    for (let batchIndex = 0; batchIndex < batches.length; batchIndex++) {
      const batch = batches[batchIndex]
      console.log(`\n🔄 Batch ${batchIndex + 1}/${batches.length} (${batch.length} Horoskope)`)

      const batchPromises = batch.map(async ({ zodiacSign, language }) => {
      try {
        // Prüfe ob bereits vorhanden (Idempotenz)
        const { data: existing } = await supabase
          .from('daily_horoscopes')
          .select('id')
          .eq('date', today)
          .eq('zodiac_sign', zodiacSign)
          .eq('language', language)
          .maybeSingle()

        if (existing) {
          console.log(`⏭️  Skip: ${zodiacSign} (${language}) - bereits vorhanden`)
          return {
            zodiacSign,
            language,
            text: '(bereits vorhanden)',
            tokens: 0,
            success: true,
            skipped: true,
          }
        }

        console.log(`📝 Generiere: ${zodiacSign} (${language})`)

        // 1. Claude API Call
        const horoscope = await generateHoroscope(zodiacSign, language, today)

        // 2. In DB speichern
        const { error } = await supabase.from('daily_horoscopes').upsert({
          date: today,
          zodiac_sign: zodiacSign,
          language: language,
          content_text: horoscope.text,
          moon_phase: null, // TODO: Mondphase berechnen
          tokens_used: horoscope.tokens,
          model_used: 'claude-sonnet-4-20250514',
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        })

        if (error) throw error

        console.log(`✅ Erfolg: ${zodiacSign} (${language}) - ${horoscope.tokens} tokens`)
        return {
          zodiacSign,
          language,
          text: horoscope.text.substring(0, 100) + '...',
          tokens: horoscope.tokens,
          success: true,
        }
      } catch (error) {
        console.error(`❌ Fehler bei ${zodiacSign} (${language}):`, error)
        return {
          zodiacSign,
          language,
          text: '',
          tokens: 0,
          success: false,
          error: error instanceof Error ? error.message : String(error),
        }
      }
    })

      // Warte auf diesen Batch
      const batchResults = await Promise.all(batchPromises)

      // Sammle Statistiken für diesen Batch
      for (const result of batchResults) {
        results.push(result)
        if (result.success) {
          successCount++
          totalTokens += result.tokens
        } else {
          errorCount++
        }
      }

      console.log(`✅ Batch ${batchIndex + 1} abgeschlossen: ${batchResults.filter(r => r.success).length}/${batchResults.length} erfolgreich`)
    }

    // 3. Cleanup: Lösche alte Horoskope (älter als 7 Tage)
    const sevenDaysAgo = new Date()
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7)
    const cleanupDate = sevenDaysAgo.toISOString().split('T')[0]

    const { error: cleanupError } = await supabase
      .from('daily_horoscopes')
      .delete()
      .lt('date', cleanupDate)

    if (cleanupError) {
      console.warn('⚠️ Cleanup-Fehler:', cleanupError)
    } else {
      console.log(`🗑️  Alte Horoskope gelöscht (vor ${cleanupDate})`)
    }

    // 4. Kosten-Kalkulation (Claude Sonnet 4 Pricing)
    // Input: ~$3/MTok, Output: ~$15/MTok
    // Durchschnitt: ~300 tokens pro Horoskop → ~$0.02
    const estimatedCost = (totalTokens / 1000) * 0.015 // Näherung

    console.log('\n\n📊 ZUSAMMENFASSUNG:')
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
    console.log(`✅ Erfolgreich: ${successCount}/${tasks.length}`)
    console.log(`❌ Fehler: ${errorCount}/${tasks.length}`)
    console.log(`🪙  Tokens gesamt: ${totalTokens}`)
    console.log(`💰 Geschätzte Kosten: ~$${estimatedCost.toFixed(3)}`)
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n')

    return new Response(
      JSON.stringify({
        success: true,
        date: today,
        generated: successCount,
        errors: errorCount,
        totalTokens,
        estimatedCost: `$${estimatedCost.toFixed(3)}`,
        results,
      }),
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    console.error('💥 FATALER FEHLER:', error)
    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : String(error),
      }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})

// ============================================================================
// HELPER: Claude API Call
// ============================================================================

async function generateHoroscope(
  zodiacSign: string,
  language: string,
  date: string
): Promise<{ text: string; tokens: number }> {
  const prompt = buildPrompt(zodiacSign, language, date)
  const systemPrompt = getSystemPrompt(language)

  const response = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': ANTHROPIC_API_KEY,
      'anthropic-version': '2023-06-01',
    },
    body: JSON.stringify({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 512, // ~100-150 Wörter
      system: systemPrompt,
      messages: [
        {
          role: 'user',
          content: prompt,
        },
      ],
    }),
  })

  if (!response.ok) {
    const error = await response.text()
    throw new Error(`Claude API Error (${response.status}): ${error}`)
  }

  const data = await response.json()
  const text = data.content[0].text
  const tokens = data.usage.input_tokens + data.usage.output_tokens

  return { text, tokens }
}

// ============================================================================
// PROMPTS
// ============================================================================

function buildPrompt(zodiacSign: string, language: string, date: string): string {
  const zodiacNamesDe: Record<string, string> = {
    aries: 'Widder',
    taurus: 'Stier',
    gemini: 'Zwillinge',
    cancer: 'Krebs',
    leo: 'Löwe',
    virgo: 'Jungfrau',
    libra: 'Waage',
    scorpio: 'Skorpion',
    sagittarius: 'Schütze',
    capricorn: 'Steinbock',
    aquarius: 'Wassermann',
    pisces: 'Fische',
  }

  const zodiacNamesEn: Record<string, string> = {
    aries: 'Aries',
    taurus: 'Taurus',
    gemini: 'Gemini',
    cancer: 'Cancer',
    leo: 'Leo',
    virgo: 'Virgo',
    libra: 'Libra',
    scorpio: 'Scorpio',
    sagittarius: 'Sagittarius',
    capricorn: 'Capricorn',
    aquarius: 'Aquarius',
    pisces: 'Pisces',
  }

  if (language === 'de') {
    const zodiacName = zodiacNamesDe[zodiacSign] || zodiacSign
    return `Schreibe ein Tageshoroskop für ${zodiacName} am ${date}.

Anforderungen:
- Länge: 80-120 Wörter
- Ton: Unterhaltsam, inspirierend, bodenständig
- Struktur: 2-3 Absätze (fließender Text)
- Keine Auflistungen oder Bullet-Points
- Fokus: Persönlichkeitsentwicklung und konkrete Impulse
- Keine leeren Versprechen

Vermeide: Esoterischen Jargon, Angstmache, Verallgemeinerungen

Format: Reiner Fließtext, keine Überschriften.`
  } else {
    const zodiacName = zodiacNamesEn[zodiacSign] || zodiacSign
    return `Write a daily horoscope for ${zodiacName} on ${date}.

Requirements:
- Length: 80-120 words
- Tone: Entertaining, inspiring, grounded
- Structure: 2-3 paragraphs (flowing text)
- No bullet points or lists
- Focus: Personal growth and actionable insights
- No empty promises

Avoid: Esoteric jargon, fear-mongering, generalizations

Format: Pure flowing text, no headings.`
  }
}

function getSystemPrompt(language: string): string {
  if (language === 'de') {
    return `Du bist eine erfahrene Astrologin, die für die Nuuray Glow App Tageshoroskope schreibt.

**Dein Charakter:**
- Unterhaltsam & inspirierend (wie eine gute Freundin)
- Staunend über die Magie des Kosmos
- Bodenständig & realistisch (keine leeren Versprechen)
- Empowernd (Fokus auf Handlungsfähigkeit)

**Deine Aufgabe:**
Schreibe Horoskope, die den Tag der Leserin verschönern und ihr kleine Impulse geben.

**Wichtig:**
- Keine Angstmache oder Drama
- Keine unrealistischen Versprechen
- Fokus auf inneres Wachstum, nicht externe Ereignisse
- Jedes Horoskop ist EINZIGARTIG (keine Templates!)

**Ton:**
Warm, direkt, authentisch. Du sprichst die Leserin wie eine Freundin an.`
  } else {
    return `You are an experienced astrologer writing daily horoscopes for the Nuuray Glow app.

**Your Character:**
- Entertaining & inspiring (like a good friend)
- Amazed by the magic of the cosmos
- Grounded & realistic (no empty promises)
- Empowering (focus on agency)

**Your Task:**
Write horoscopes that brighten the reader's day and give her small impulses.

**Important:**
- No fear-mongering or drama
- No unrealistic promises
- Focus on inner growth, not external events
- Each horoscope is UNIQUE (no templates!)

**Tone:**
Warm, direct, authentic. You speak to the reader like a friend.`
  }
}
