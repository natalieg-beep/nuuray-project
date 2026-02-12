# Signatur-Screen Umstrukturierung

> **Datum:** 2026-02-10
> **Referenz:** `docs/SIGNATUR_SCREEN_ANLEITUNG.md`
> **Status:** ✅ **IMPLEMENTIERT**

---

## 🎯 Was wurde gemacht

Der Signatur-Detail-Screen wurde umstrukturiert, um dieselbe Archetyp-Darstellung wie der Home Screen zu zeigen und Überleitungstexte hinzuzufügen.

**Geänderte Dateien:**
- `packages/nuuray_ui/lib/src/l10n/app_de.arb`
- `packages/nuuray_ui/lib/src/l10n/app_en.arb`
- `apps/glow/lib/src/features/signature/screens/signature_dashboard_screen.dart`

---

## ❌ Vorher (Problem)

### Was angezeigt wurde:

```
Deine Signatur
━━━━━━━━━━━━━━━━━━━━━

Deine kosmische Identität                    ← Hardcoded Header
Eine Synthese aus drei Weisheitstraditionen  ← Generischer Text

[Western Astrology Card]
[Bazi Card]
[Numerology Card]

ℹ️ Alle drei Systeme arbeiten zusammen...    ← Info-Footer
```

**Probleme:**
- ❌ Archetyp-Titel + Synthese fehlen (obwohl auf Home vorhanden)
- ❌ Keine Verbindung zwischen "Archetyp" (Home) und "Signatur" (Detail)
- ❌ Generischer Header-Text ("kosmische Identität") statt Brand Voice
- ❌ Keine Überleitung vor den drei Karten
- ❌ Info-Footer ist isoliert, kein "Und so fügt sich alles zusammen"-Moment

---

## ✅ Nachher (Lösung)

### Was jetzt angezeigt wird:

```
Deine Signatur
━━━━━━━━━━━━━━━━━━━━━

✨ Dein Archetyp
━━━━━━━━━━━━━━━━━━━━━
Die großzügige Perfektionistin            ← Archetyp-Titel (geparst)

Alles in dir will nach vorne — Schütze-   ← Archetyp-Synthese (geparst)
Feuer, Löwe-Aszendent, eine 8 als
Lebensweg. Aber dein Yin-Metall...

━━━━━━━━━━━━━━━━━━━━━

Deine Signatur setzt sich aus drei       ← signatureOverviewIntro
Perspektiven zusammen — jede zeigt
einen anderen Aspekt von dir.

[Western Astrology Card]                  ← Wer du bist
[Bazi Card]                               ← Was du brauchst
[Numerology Card]                         ← Wohin du gehst

Und so fügt sich alles zusammen:          ← signatureOverviewOutro

ℹ️ Alle drei Systeme arbeiten zusammen... ← Info-Footer (Kosmische Synthese)
```

**Vorteile:**
- ✅ Archetyp-Hero Section identisch mit Home Screen (gleiche Datenquelle!)
- ✅ Klare Überleitung: "setzt sich aus drei Perspektiven zusammen"
- ✅ Dramaturgischer Bogen: Intro → Details → Outro → Synthese
- ✅ Brand Voice konform (keine "kosmische Identität")
- ✅ User versteht Zusammenhang zwischen Home und Detail

---

## 🔧 Technische Details

### 1. i18n-Keys hinzugefügt

**Datei:** `packages/nuuray_ui/lib/src/l10n/app_de.arb`

```json
{
  "signatureOverviewIntro": "Deine Signatur setzt sich aus drei Perspektiven zusammen — jede zeigt einen anderen Aspekt von dir.",
  "@signatureOverviewIntro": {
    "description": "Überleitung vor den drei Signaturen-Karten (nach Archetyp-Hero)"
  },

  "signatureOverviewOutro": "Und so fügt sich alles zusammen:",
  "@signatureOverviewOutro": {
    "description": "Outro-Satz vor der kosmischen Synthese (vor Info-Footer)"
  }
}
```

**Datei:** `packages/nuuray_ui/lib/src/l10n/app_en.arb`

```json
{
  "signatureOverviewIntro": "Your signature is composed of three perspectives — each reveals a different aspect of you.",
  "signatureOverviewOutro": "And this is how it all comes together:"
}
```

### 2. Sektions-Untertitel mit Brand Voice aktualisiert

**Vorher (generisch):**
```json
"signatureWesternSubtitle": "Deine psychologische Blaupause",
"signatureBaziSubtitle": "Deine energetische Signatur",
"signatureNumerologySubtitle": "Dein Seelenrhythmus"
```

**Nachher (Brand Voice):**
```json
"signatureWesternSubtitle": "Wer du bist — deine psychologische Signatur",
"signatureBaziSubtitle": "Was du brauchst — deine energetische Architektur",
"signatureNumerologySubtitle": "Wohin du gehst — dein Seelenrhythmus"
```

**Warum besser:**
- ✅ Formulierung zeigt Perspektive ("Wer", "Was", "Wohin")
- ✅ Kein "Blaupause"-Jargon
- ✅ "Architektur" statt "Signatur" (weniger Wiederholung)
- ✅ Kurz, prägnant, ohne Kitsch

### 3. Signature Dashboard Screen umgebaut

**Datei:** `apps/glow/lib/src/features/signature/screens/signature_dashboard_screen.dart`

#### Imports hinzugefügt:

```dart
import 'package:nuuray_core/nuuray_core.dart';
import 'package:nuuray_ui/nuuray_ui.dart';
import '../../home/widgets/archetype_header.dart';
import '../../profile/providers/user_profile_provider.dart';
```

#### Archetyp-Objekt erstellen (gleiche Logik wie Home Screen):

```dart
final profileAsync = ref.watch(userProfileProvider);
final l10n = AppLocalizations.of(context)!;

// ...

final profile = profileAsync.value;
final archetype = Archetype.fromBirthChart(
  lifePathNumber: birthChart.lifePathNumber ?? 1,
  dayMasterStem: birthChart.baziDayStem ?? 'Jia',
  signatureText: profile?.signatureText,  // ← Gleiche Quelle wie Home!
);
```

#### UI-Struktur (Zeile 60-142):

**Vorher:**
```dart
children: [
  // Header
  Text('Deine kosmische Identität', ...),
  Text('Eine Synthese aus drei Weisheitstraditionen', ...),
  const SizedBox(height: 32),

  // Cards
  WesternAstrologyCard(birthChart: birthChart),
  BaziCard(birthChart: birthChart),
  NumerologyCard(birthChart: birthChart),
  const SizedBox(height: 40),

  // Info Footer
  Container(...),
]
```

**Nachher:**
```dart
children: [
  // Archetyp-Hero Section (wie auf Home Screen)
  ArchetypeHeader(archetype: archetype),
  const SizedBox(height: 24),

  // Überleitung: "Deine Signatur setzt sich aus drei Perspektiven zusammen..."
  Text(
    l10n.signatureOverviewIntro,
    style: TextStyle(
      fontSize: 15,
      color: Colors.grey[700],
      height: 1.5,
    ),
  ),
  const SizedBox(height: 32),

  // Western Astrology Card
  WesternAstrologyCard(birthChart: birthChart),
  const SizedBox(height: 20),

  // Bazi Card
  BaziCard(birthChart: birthChart),
  const SizedBox(height: 20),

  // Numerology Card
  NumerologyCard(birthChart: birthChart),
  const SizedBox(height: 40),

  // Outro: "Und so fügt sich alles zusammen:"
  Text(
    l10n.signatureOverviewOutro,
    style: TextStyle(
      fontSize: 15,
      color: Colors.grey[700],
      fontWeight: FontWeight.w500,
      height: 1.5,
    ),
  ),
  const SizedBox(height: 16),

  // Kosmische Synthese (Info Footer)
  Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(
          Icons.info_outline,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Alle drei Systeme arbeiten zusammen und ergänzen sich gegenseitig.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  ),
]
```

---

## 🎯 Datenquelle-Konsistenz

**Wichtig:** Home Screen und Signatur Screen lesen Archetyp aus **EINER Quelle:**

### Home Screen (`apps/glow/lib/src/features/home/screens/home_screen.dart`):

```dart
final archetype = Archetype.fromBirthChart(
  lifePathNumber: birthChart.lifePathNumber ?? 1,
  dayMasterStem: birthChart.baziDayStem ?? 'Jia',
  signatureText: profile.signatureText,  // ← Aus UserProfile!
);

// Render:
ArchetypeHeader(archetype: archetype)
```

### Signatur Screen (`signature_dashboard_screen.dart`):

```dart
final profile = profileAsync.value;
final archetype = Archetype.fromBirthChart(
  lifePathNumber: birthChart.lifePathNumber ?? 1,
  dayMasterStem: birthChart.baziDayStem ?? 'Jia',
  signatureText: profile?.signatureText,  // ← Aus UserProfile!
);

// Render:
ArchetypeHeader(archetype: archetype)
```

**✅ Resultat:** Beide Screens zeigen **identischen** Archetyp-Titel + Synthese!

---

## 📋 Checkliste (aus SIGNATUR_SCREEN_ANLEITUNG.md)

- ✅ **Datenquelle Archetyp:** Home + Signatur lesen aus EINER Quelle (`profile.signatureText`)
- ✅ **i18n-Key `signatureOverviewIntro`** in `app_de.arb` und `app_en.arb` eingefügt
- ✅ **i18n-Key `signatureOverviewOutro`** in `app_de.arb` und `app_en.arb` eingefügt
- ✅ **Optional:** Sektions-Untertitel mit Brand Voice aktualisiert
- ✅ **Überleitung im UI platziert** (nach Archetyp-Hero, vor Western Card)
- ✅ **Outro im UI platziert** (vor Kosmische Synthese / Info-Footer)
- ⏳ **`flutter gen-l10n` ausführen** (nächster Schritt)
- ⏳ **App testen:** Home → Signatur Detail, Archetyp-Titel identisch?

---

## 🧪 Testing

### 1. Archetyp-Titel Konsistenz

**Schritte:**
1. App öffnen → Home Screen
2. Notiere Archetyp-Titel (z.B. "Die großzügige Perfektionistin")
3. Tippe auf "Deine Signatur" → Detail Screen
4. Prüfe Archetyp-Hero Section am Anfang

**Erwartung:**
- ✅ Titel ist **identisch** auf beiden Screens
- ✅ Synthese ist **identisch** auf beiden Screens
- ✅ Kein "Deine kosmische Identität" mehr sichtbar

### 2. Überleitung + Outro

**Erwartung:**
- ✅ Nach Archetyp-Hero: "Deine Signatur setzt sich aus drei Perspektiven zusammen..."
- ✅ Vor Info-Footer: "Und so fügt sich alles zusammen:"
- ✅ Info-Footer bleibt erhalten (als "Kosmische Synthese")

### 3. Regenerierung

**Schritte:**
1. Profile Edit → Feld ändern (z.B. Rufname)
2. Speichern → Warte 2-3 Sekunden (Claude API Call)
3. Home Screen prüfen → Neuer Archetyp-Titel?
4. Signatur Screen prüfen → Neuer Archetyp-Titel auch hier?

**Erwartung:**
- ✅ Beide Screens zeigen **neuen Titel** sofort
- ✅ Keine Diskrepanz zwischen Home und Detail

---

## 🐛 Bekannte Edge Cases

### 1. User hat noch keine Signatur (`signature_text = NULL`)

**Symptom:**
- Archetyp-Header zeigt Fallback-Titel (alte Komposition: "Die feine Strategin")
- Fallback-Synthese: "Noch keine Signatur generiert"

**Lösung:**
- Fallback funktioniert (bereits in `archetype_header.dart` implementiert)
- User kann Signatur über Profile Edit → Speichern neu generieren

### 2. Profile ist noch nicht geladen (`profileAsync.value = null`)

**Symptom:**
- `archetype` wird mit `signatureText: null` erstellt
- Fallback-Logik greift

**Lösung:**
- Code ist defensiv: `signatureText: profile?.signatureText`
- Fallback-Darstellung funktioniert

### 3. i18n-Keys fehlen nach Code-Änderung

**Symptom:**
- App crasht mit "Missing key: signatureOverviewIntro"

**Lösung:**
- **WICHTIG:** `flutter gen-l10n` ausführen (nächster Schritt!)
- ARB-Dateien werden zu Dart-Code generiert

---

## 📊 Zusammenfassung

| Was | Vorher | Nachher |
|-----|--------|---------|
| **Archetyp-Hero** | ❌ Fehlt | ✅ Identisch mit Home Screen |
| **Überleitung** | ❌ Fehlt | ✅ "Deine Signatur setzt sich aus drei Perspektiven zusammen..." |
| **Outro** | ❌ Fehlt | ✅ "Und so fügt sich alles zusammen:" |
| **Datenquelle** | N/A | ✅ `profile.signatureText` (gleich wie Home) |
| **Sektions-Untertitel** | ⚠️ Generisch | ✅ Brand Voice konform |
| **Dramaturgie** | ❌ Flach | ✅ Hook → Details → Synthese |

---

## 🚀 Nächste Schritte

### Sofort (User)
1. ✅ **Code geändert** (ARB-Dateien + `signature_dashboard_screen.dart`)
2. ⏳ **`flutter gen-l10n` ausführen** (Lokalisierungen generieren)
3. ⏳ **App testen:** Home → Signatur Detail, Archetyp-Titel identisch?

### Optional (später)
1. **Alte "kosmische Identität"-Texte prüfen:**
   - Sind noch andere Screens betroffen?
   - Gibt es noch mehr generische Header-Texte?

2. **Card-Untertitel in UI anzeigen:**
   - Aktuell: ARB-Keys existieren, aber werden sie in den Cards verwendet?
   - Falls nicht: Cards updaten (Western/Bazi/Numerology Cards)

---

## 📝 Dokumentation

**Erstellt:**
- `docs/daily-logs/2026-02-10_signatur-screen-restructure.md` — Dieser Session-Log

**Aktualisiert:**
- `packages/nuuray_ui/lib/src/l10n/app_de.arb` — i18n-Keys hinzugefügt
- `packages/nuuray_ui/lib/src/l10n/app_en.arb` — i18n-Keys hinzugefügt
- `apps/glow/lib/src/features/signature/screens/signature_dashboard_screen.dart` — UI umgebaut

---

**Letzte Aktualisierung:** 2026-02-10
**Status:** ✅ **READY FOR LOCALIZATION GENERATION**
