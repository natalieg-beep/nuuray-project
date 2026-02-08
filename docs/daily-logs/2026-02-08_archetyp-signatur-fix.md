# 🐛 Bug-Fix: Archetyp-Signatur wird nicht generiert — 2026-02-08

## 📋 Problem

Nach Abschluss des Onboardings wurde die Archetyp-Signatur nicht generiert. Stattdessen zeigte der Home Screen den Placeholder-Text: _"Tippe hier, um deine persönliche Signatur zu erstellen"_.

User konnte Onboarding erfolgreich abschließen und Home Screen wurde angezeigt, aber `signature_text` blieb `null` in der Datenbank.

---

## 🔍 Root Causes (2 Bugs)

### Bug 1: Falsche Sprach-Vergleiche in `archetype_signature_service.dart`

**Problem:**
```dart
// Zeile 162, 199, 232, 269
if (language == 'DE') {  // ❌ Vergleicht mit Großbuchstaben
```

**Ursache:**
- UserProfile speichert `language` als **Kleinbuchstaben**: `'de'` (siehe `user_profile.dart` Zeile 59)
- Service-Code verglich mit **Großbuchstaben**: `'DE'`
- Match schlug fehl → Fallback auf englische Texte → Prompt hatte falsche Sprache

**Impact:**
- Archetyp-Namen wurden als `nameKey` statt lokalisiert übergeben
- Bazi-Adjektive wurden als `adjectiveKey` statt lokalisiert übergeben
- Prompt bekam englische Texte obwohl User Deutsch eingestellt hatte

**Fix:**
```dart
// Zeile 162, 199, 232, 269 - alle 4 Lokalisierungs-Methoden
if (language.toUpperCase() == 'DE') {  // ✅ Case-insensitive
```

---

### Bug 2: API Key wird falsch geladen in `onboarding_flow_screen.dart`

**Problem:**
```dart
// Zeile 102 (alt)
final anthropicApiKey = const String.fromEnvironment('ANTHROPIC_API_KEY');
if (anthropicApiKey.isEmpty) {  // ❌ Immer leer!
  log('Archetyp-Signatur: ANTHROPIC_API_KEY nicht gesetzt');
  return;
}
```

**Ursache:**
- `const String.fromEnvironment()` funktioniert nur mit `--dart-define` beim Compile-Time
- Glow-App nutzt aber `flutter_dotenv` für Secrets (`.env` Datei)
- API Key war immer leer → Signatur-Generierung wurde übersprungen

**Bestehende Lösung:**
- Es gibt bereits einen `claudeApiServiceProvider` in `app_providers.dart`
- Dieser lädt den Key korrekt aus `dotenv.env['ANTHROPIC_API_KEY']`

**Fix:**
```dart
// Neu: Nutze existierenden Provider
final claudeService = ref.read(claudeApiServiceProvider);
if (claudeService == null) {
  log('⚠️ [Archetyp] Claude API Service nicht verfügbar');
  return;
}

// ClaudeApiService direkt verwenden (ist bereits initialisiert)
final archetypeService = ArchetypeSignatureService(
  supabase: Supabase.instance.client,
  claudeService: claudeService,
);
```

**Zusätzlich:**
- Entfernt: Import von `claude_api_service.dart` (nicht mehr nötig)
- Hinzugefügt: Import von `app_providers.dart` (für `claudeApiServiceProvider`)
- Verbesserte Logging-Ausgaben mit Emoji-Prefixes für bessere Lesbarkeit

---

## ✅ Dateien geändert

### 1. `apps/glow/lib/src/features/signature/services/archetype_signature_service.dart`

**Änderungen:**
- Zeile 162: `language.toUpperCase() == 'DE'` in `_getLocalizedArchetypeName()`
- Zeile 199: `language.toUpperCase() == 'DE'` in `_getLocalizedBaziAdjective()`
- Zeile 232: `language.toUpperCase() == 'DE'` in `_getZodiacSignName()`
- Zeile 269: `language.toUpperCase() == 'DE'` in `_getBaziElementName()`

**Impact:**
- Lokalisierung funktioniert jetzt auch mit `'de'` (Kleinbuchstaben)
- Archetyp-Namen und Bazi-Adjektive werden korrekt übersetzt
- Claude API bekommt die richtige Sprache im Prompt

---

### 2. `apps/glow/lib/src/features/onboarding/screens/onboarding_flow_screen.dart`

**Änderungen:**

**Imports:**
```dart
// Hinzugefügt:
import '../../../core/providers/app_providers.dart';

// Entfernt:
import '../../../core/services/claude_api_service.dart';
```

**`_generateArchetypeSignature()` Methode (Zeile 69-127):**
```dart
// ALT:
final anthropicApiKey = const String.fromEnvironment('ANTHROPIC_API_KEY');
if (anthropicApiKey.isEmpty) {
  log('Archetyp-Signatur: ANTHROPIC_API_KEY nicht gesetzt');
  return;
}
final claudeService = ClaudeApiService(apiKey: anthropicApiKey);

// NEU:
final claudeService = ref.read(claudeApiServiceProvider);
if (claudeService == null) {
  log('⚠️ [Archetyp] Claude API Service nicht verfügbar (API Key fehlt?)');
  return;
}
```

**Verbesserte Logs:**
- Alle Logs haben jetzt `[Archetyp]` Prefix und Emojis
- Detaillierte Status-Meldungen für jeden Schritt
- Ausgabe von Life Path Number und Bazi Day Stem

**Impact:**
- API Key wird jetzt korrekt aus `.env` geladen (via `dotenv`)
- Signatur-Generierung wird nicht mehr übersprungen
- Bessere Debugging-Möglichkeiten durch detaillierte Logs

---

## 🧪 Testing

### Vorher (Bug):
1. User registriert sich → Onboarding durchlaufen
2. Archetyp-Generierung silent fail (keine Logs, kein Error)
3. Home Screen zeigt Placeholder: "Tippe hier, um..."
4. `signature_text` in DB = `null`

### Nachher (Fix):
1. User registriert sich → Onboarding durchlaufen
2. Terminal zeigt detaillierte Logs:
   ```
   🎨 [Archetyp] Starte Signatur-Generierung für User: abc-123
   📊 [Archetyp] Berechne BirthChart...
   ✅ [Archetyp] BirthChart erfolgreich berechnet
      Life Path: 5
      Bazi Day Stem: Jia
   🤖 [Archetyp] Claude API Service bereit, starte Generierung...
   ✨ [Archetyp] Signatur erfolgreich generiert!
      Text: "In dir verbindet sich..."
   ```
3. Home Screen zeigt personalisierten Archetyp-Text
4. `signature_text` in DB enthält Claude-generierten Text

### Checklist:
- [ ] Neu registrieren mit frischem User
- [ ] Onboarding komplett durchlaufen
- [ ] Terminal-Logs beobachten (sollten alle `[Archetyp]` Steps zeigen)
- [ ] Home Screen: Archetyp-Header zeigt personalisierten Text
- [ ] Supabase: `profiles.signature_text` ist nicht null

---

## 🎯 Status

**Beide Bugs gefixt:**
- ✅ Sprach-Vergleiche case-insensitive
- ✅ API Key wird korrekt aus `.env` geladen
- ✅ Verbesserte Logging-Ausgaben

**Nächster Schritt:**
User soll mit neuem Account testen und Terminal-Logs zur Verfügung stellen.

---

**Datum:** 2026-02-08
**Dauer:** ~15 Minuten
**Dateien:** 2 geändert
**Lines of Code:** ~30 Zeilen
