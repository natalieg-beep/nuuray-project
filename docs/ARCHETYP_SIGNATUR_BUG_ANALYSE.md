# Archetyp-Signatur Bug-Analyse

> **Datum:** 2026-02-10
> **Problem:** Archetyp-Titel ändert sich bei jedem Login + Signatur-Screen zeigt alten Archetyp

---

## 🐛 Gemeldete Probleme

### Problem 1: Archetyp ändert sich bei jedem Neu-Einloggen
**Symptom:**
- User loggt sich aus und wieder ein
- Archetyp-Titel ist plötzlich anders (z.B. "Die großzügige Perfektionistin" → "Die mutige Visionärin")

**Erwartetes Verhalten:**
- Archetyp-Titel + Synthese sollten KONSTANT bleiben (außer bei manueller Regenerierung)
- `signature_text` in DB sollte gecacht werden

### Problem 2: Signatur-Screen zeigt alten Archetyp
**Symptom:**
- Home Screen zeigt neuen Archetyp-Titel
- Signatur-Detail-Screen zeigt alten Archetyp-Titel
- Titel müssen identisch sein!

**Erwartetes Verhalten:**
- Beide Screens lesen aus **EINER** Datenquelle (`profile.signatureText`)
- Beide zeigen identischen Titel

---

## 🔍 Code-Analyse

### Stellen wo Signatur generiert wird:

| Datei | Zeile | Kontext | Wann getriggert |
|-------|-------|---------|-----------------|
| `onboarding_flow_screen.dart` | 261 | `await _generateArchetypeSignature(...)` | Bei Onboarding-Abschluss (Speichern) |
| `home_screen.dart` | 108 | `await archetypeService.generateAndCacheArchetypeSignature(...)` | Manuelle Regenerierung (Button-Click) |
| `edit_profile_screen.dart` | 310 | `await archetypeService.generateAndCacheArchetypeSignature(...)` | Bei Profile-Edit Speichern |

### Cache-Check in `archetype_signature_service.dart`:

```dart
// Zeile 43-56
// 1. Prüfe ob Signatur bereits existiert
final profile = await _supabase
    .from('profiles')
    .select('signature_text')
    .eq('id', userId)
    .maybeSingle();

if (profile != null) {
  final existingSignature = profile['signature_text'] as String?;
  if (existingSignature != null && existingSignature.isNotEmpty) {
    log('✅ Archetyp-Signatur bereits gecacht, nutze bestehende');
    return existingSignature;  // ← RETURN EXISTING!
  }
}
```

**✅ Der Cache-Check funktioniert theoretisch korrekt!**
Wenn `signature_text` in der DB existiert, wird es returniert (keine neue Generierung).

---

## 🕵️ Hypothesen

### Hypothese 1: Cache-Check wird umgangen
**Theorie:** Die Funktion wird zwar gecalled, aber irgendetwas löscht `signature_text` vorher.

**Test:**
- Prüfe ob bei Profile-Update das Feld `signature_text` auf `null` gesetzt wird
- Schaue in `edit_profile_screen.dart` oder `user_profile_service.dart`

### Hypothese 2: Provider-State ist nicht synchron
**Theorie:** `userProfileProvider` cached einen alten Wert und lädt nicht neu aus DB.

**Beweise:**
- Zeile 271 in `onboarding_flow_screen.dart`: `ref.invalidate(userProfileProvider)`
- Zeile 117 in `home_screen.dart`: `ref.invalidate(userProfileProvider)`
- **ABER:** Invalidierung ≠ sofortiges Reload

**Problem:**
- `FutureProvider` macht einen Fetch, cached das Ergebnis
- Wenn zwischen Invalidierung und nächstem Render die DB sich geändert hat → Race Condition!

### Hypothese 3: Signatur-Screen nutzt separaten State
**Theorie:** Signatur-Screen lädt das Profil separat und der State ist nicht synchronisiert.

**Beweise:**
```dart
// signature_dashboard_screen.dart (Zeile 21-22)
final signatureAsync = ref.watch(signatureProvider);
final profileAsync = ref.watch(userProfileProvider);
```

- Wenn `userProfileProvider` gecacht ist und nicht neu lädt → alter Wert
- Wenn `signatureProvider` (birthChart) neu lädt, aber `profileAsync` nicht → Diskrepanz!

---

## 🧪 Debugging-Plan

### Schritt 1: Logging verbessern

In `archetype_signature_service.dart` erweitere ich das Logging:

```dart
// Zeile 50-56 erweitern
if (profile != null) {
  final existingSignature = profile['signature_text'] as String?;
  log('🔍 [ArchetypeService] Cache-Check:');
  log('   User ID: $userId');
  log('   Existing signature: "${existingSignature ?? "NULL"}"');
  log('   Is empty: ${existingSignature?.isEmpty ?? true}');

  if (existingSignature != null && existingSignature.isNotEmpty) {
    log('✅ [ArchetypeService] CACHE HIT - nutze bestehende Signatur');
    return existingSignature;
  } else {
    log('⚠️ [ArchetypeService] CACHE MISS - generiere neue Signatur');
  }
}
```

### Schritt 2: Profile-Update checken

Prüfe ob `user_profile_service.dart` bei `updateProfile` das Feld `signature_text` überschreibt:

```dart
// Suche nach: update({ ... }) in user_profile_service.dart
// Prüfe ob 'signature_text' explizit auf null gesetzt wird
```

### Schritt 3: Provider-Invalidierung testen

Teste ob `userProfileProvider` nach Invalidierung wirklich neu aus DB lädt:

```dart
// Nach ref.invalidate(userProfileProvider):
await Future.delayed(Duration(milliseconds: 100));
final freshProfile = await ref.read(userProfileProvider.future);
log('🔄 Fresh profile signature: ${freshProfile?.signatureText}');
```

---

## 🛠️ Lösungsvorschläge

### Lösung 1: StateNotifierProvider statt FutureProvider

**Problem:** `FutureProvider` ist immutable nach erstem Fetch.

**Lösung:** Wandle `userProfileProvider` in `StateNotifierProvider` um:

```dart
class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final UserProfileService _service;

  UserProfileNotifier(this._service) : super(const AsyncValue.loading()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _service.getUserProfile();
      state = AsyncValue.data(profile);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    await loadProfile();
  }
}

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>((ref) {
  final service = ref.watch(userProfileServiceProvider);
  return UserProfileNotifier(service);
});
```

**Vorteil:**
- Explizites `refresh()` zum Neu-Laden
- State bleibt synchron über alle Widgets

### Lösung 2: Signatur im Archetyp-Model cachen

**Problem:** Archetyp wird bei jedem Render neu erstellt (`Archetype.fromBirthChart(...)`).

**Lösung:** Archetyp als Provider:

```dart
final archetypeProvider = Provider<Archetype?>((ref) {
  final birthChart = ref.watch(signatureProvider).value;
  final profile = ref.watch(userProfileProvider).value;

  if (birthChart == null || profile == null) return null;

  return Archetype.fromBirthChart(
    lifePathNumber: birthChart.lifePathNumber ?? 1,
    dayMasterStem: birthChart.baziDayStem ?? 'Jia',
    signatureText: profile.signatureText,
  );
});
```

**Vorteil:**
- Archetyp wird nur einmal berechnet
- Beide Screens (Home + Signatur) nutzen **denselben Provider**
- Automatische Synchronisation

### Lösung 3: Profile-Update ohne signature_text Überschreiben

**Problem:** `edit_profile_screen.dart` überschreibt möglicherweise `signature_text`.

**Lösung:** In `updateProfile()` nur geänderte Felder senden:

```dart
// NUR die Felder die geändert wurden:
await _supabase.from('profiles').update({
  'display_name': displayName,
  'birth_date': birthDate.toIso8601String(),
  // ... ABER NICHT:
  // 'signature_text': null  ← Das NICHT machen!
}).eq('id', userId);
```

---

## 📋 Nächste Schritte

1. **Sofort:** Logging in `archetype_signature_service.dart` erweitern
2. **Sofort:** Prüfe `user_profile_service.dart` ob `signature_text` überschrieben wird
3. **Test:** App neu starten, Login, schaue Logs:
   - Wird Cache-Check ausgeführt?
   - Ist `signature_text` in DB vorhanden?
   - Wird trotzdem neu generiert?
4. **Fix:** Je nach Ergebnis:
   - Wenn Cache-Check fehlschlägt → Lösung 3 (Profile-Update)
   - Wenn Provider nicht synchron → Lösung 1 (StateNotifierProvider)
   - Wenn beide Screens unterschiedlich → Lösung 2 (Archetyp-Provider)

---

**Status:** 🔍 **ANALYSE ABGESCHLOSSEN - WARTE AUF DEBUGGING-ERGEBNISSE**
