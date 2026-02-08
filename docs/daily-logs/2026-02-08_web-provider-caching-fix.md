# Web Provider Caching Fix - FINAL

**Datum:** 2026-02-08
**Problem:** Profil konnte in Chrome/Web nicht geladen werden (nach Login)
**Status:** ✅ GELÖST

---

## 🐛 Problem-Analyse

### Symptome
- **Chrome/Web:** Nach Login erscheint "Profil konnte nicht geladen werden"
- **macOS:** Funktioniert perfekt
- **Settings:** Profil ist leer in Web

### Console Logs zeigten:
```
❌ getUserProfile: Kein User eingeloggt
📊 getUserProfile: Lade Profil für User f6d845b4-...
✅ getUserProfile: Profil-Daten empfangen: id, display_name, ...
✅ getUserProfile: Profil erfolgreich geparst für Natalie
```

### Root Cause: **Provider Caching**

Der `userProfileProvider` wurde **ZWEIMAL** aufgerufen:

1. **Erster Call (zu früh):**
   - Beim App-Start, noch bevor User eingeloggt ist
   - Result: `null` (kein User)
   - **Provider cached dieses `null`-Ergebnis**

2. **Zweiter Call (nach Login):**
   - Nach erfolgreichem Login
   - Result: ✅ Profil erfolgreich geladen
   - **ABER:** Provider nutzt gecachtes `null` statt neues Ergebnis

**Warum funktioniert es auf macOS?**
- Timing-Unterschied: macOS lädt schneller, Provider wird erst NACH Login aufgerufen
- Web ist langsamer, Provider wird VOR Login initialisiert

---

## ✅ Lösung

### 1. Provider nach Login invalidieren

**Datei:** `apps/glow/lib/src/features/auth/screens/login_screen.dart`

```dart
// VORHER (ohne Invalidierung):
if (result.isSuccess) {
  context.go('/splash');
}

// NACHHER (mit Invalidierung):
if (result.isSuccess) {
  // Provider invalidieren damit Profil neu geladen wird
  ref.invalidate(userProfileProvider);

  context.go('/splash');
}
```

**Import hinzugefügt:**
```dart
import '../../profile/providers/user_profile_provider.dart';
```

### 2. Debug-Logging verbessert

**Datei:** `apps/glow/lib/src/features/profile/services/user_profile_service.dart`

**Änderung:** `log()` → `print()` für Web-Kompatibilität

```dart
Future<UserProfile?> getUserProfile() async {
  try {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      print('❌ getUserProfile: Kein User eingeloggt');
      return null;
    }

    print('📊 getUserProfile: Lade Profil für User $userId');

    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) {
      print('❌ getUserProfile: Kein Profil gefunden für User $userId');
      return null;
    }

    print('✅ getUserProfile: Profil-Daten empfangen: ${response.keys.join(", ")}');

    final profile = UserProfile.fromJson(response);
    print('✅ getUserProfile: Profil erfolgreich geparst für ${profile.displayName}');

    return profile;
  } catch (e, stackTrace) {
    print('❌ getUserProfile Fehler: $e');
    print('Stack: $stackTrace');
    return null;
  }
}
```

**Warum `print()` statt `log()`?**
- `log()` aus `dart:developer` erscheint nicht in Chrome Console
- `print()` ist Web-kompatibel und erscheint direkt in der Console

### 3. Web-sicheres DateTime-Parsing (Bonus)

**Datei:** `packages/nuuray_core/lib/src/models/user_profile.dart`

Obwohl das nicht das Hauptproblem war, haben wir auch DateTime-Parsing verbessert:

```dart
/// Sicheres DateTime-Parsing (Web-kompatibel)
static DateTime? _parseDateTimeSafe(dynamic value) {
  if (value == null) return null;
  try {
    return DateTime.parse(value as String);
  } catch (e) {
    return null;  // Kein Crash, nur null
  }
}

/// Sicheres Parsing von Zeitstrings (HH:MM:SS Format aus DB)
static DateTime? _parseBirthTime(dynamic value) {
  if (value == null) return null;
  try {
    final timeStr = value as String;
    final parts = timeStr.split(':');
    if (parts.isEmpty) return null;

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

    return DateTime(2000, 1, 1, hour, minute);
  } catch (e) {
    return null;
  }
}
```

---

## 📊 Betroffene Dateien

### Geändert: 3
1. **`apps/glow/lib/src/features/auth/screens/login_screen.dart`**
   - Import: `user_profile_provider.dart`
   - Login-Handler: `ref.invalidate(userProfileProvider)` nach erfolgreichem Login

2. **`apps/glow/lib/src/features/profile/services/user_profile_service.dart`**
   - `log()` → `print()` für Web-Konsole
   - Detailliertes Logging für Debugging

3. **`packages/nuuray_core/lib/src/models/user_profile.dart`**
   - `_parseDateTimeSafe()` Methode
   - `_parseBirthTime()` Methode
   - `fromJson()` nutzt sichere Parsing-Methoden

---

## 🧪 Testing

### Vorher (Chrome/Web)
```
1. App Start → userProfileProvider wird initialisiert
2. Provider Call #1: ❌ Kein User eingeloggt → cached null
3. Login → Success
4. Navigation zu /splash → /home
5. Provider nutzt gecachtes null
6. UI: "Profil konnte nicht geladen werden" ❌
```

### Nachher (Chrome/Web)
```
1. App Start → userProfileProvider wird initialisiert
2. Provider Call #1: ❌ Kein User eingeloggt → cached null
3. Login → Success
4. ref.invalidate(userProfileProvider) → Cache gelöscht ✨
5. Navigation zu /splash → /home
6. Provider Call #2: ✅ Profil geladen
7. UI: Zeigt alle Daten korrekt ✅
```

---

## 💡 Lessons Learned

### 1. Provider Lifecycle beachten
Riverpod Provider werden beim ersten Access initialisiert, nicht beim Build. Wenn ein Provider VOR dem Login aufgerufen wird, cached er das Ergebnis für "nicht eingeloggt".

**Best Practice:** Nach Auth-Änderungen immer relevante Provider invalidieren:
```dart
ref.invalidate(userProfileProvider);
ref.invalidate(signatureProvider);
```

### 2. Web vs Native Timing
Web-Apps haben andere Timing-Charakteristiken als Native:
- Langsameres Laden
- Provider werden früher initialisiert
- Was auf Native funktioniert, kann auf Web brechen

**Best Practice:** Immer auf beiden Plattformen testen!

### 3. Logging auf Web
`dart:developer` `log()` funktioniert auf Web anders als auf Native.

**Best Practice:**
- Entwicklung: `print()` für sofortige Sichtbarkeit
- Produktion: Logging-Service (Sentry, Firebase, etc.)

### 4. Defensive Programming
Alle externen Daten (DB, API) immer mit Try-Catch wrappen:
```dart
try {
  return DateTime.parse(value);
} catch (e) {
  return null;  // Graceful degradation
}
```

---

## 🔮 Weitere Optimierungen (Optional)

### 1. Globaler Auth-State Listener
Statt manuell in jedem Login-Flow zu invalidieren, könnte man einen globalen Listener einrichten:

```dart
ref.listen(authServiceProvider.select((s) => s.isAuthenticated), (prev, next) {
  if (prev == false && next == true) {
    // User hat sich eingeloggt
    ref.invalidate(userProfileProvider);
    ref.invalidate(signatureProvider);
  } else if (prev == true && next == false) {
    // User hat sich ausgeloggt
    ref.invalidate(userProfileProvider);
    ref.invalidate(signatureProvider);
  }
});
```

### 2. Provider Auto-Refresh
Provider mit `autoDispose` markieren, damit sie sich selbst aufräumen:
```dart
final userProfileProvider = FutureProvider.autoDispose<UserProfile?>((ref) async {
  // ...
});
```

### 3. Error State im UI
Statt nur "Profil konnte nicht geladen werden", könnte man detailliertere Fehler zeigen:
```dart
userProfileAsync.when(
  data: (profile) => profile != null ? ProfileView() : ErrorView('Kein Profil'),
  loading: () => LoadingView(),
  error: (err, stack) => ErrorView('Fehler: $err'),
);
```

---

## 📝 Zusammenfassung

### Problem
Provider-Caching: Profil-Load wurde VOR Login initialisiert und cached `null`.

### Lösung
Provider nach erfolgreichem Login invalidieren: `ref.invalidate(userProfileProvider)`

### Impact
- ✅ Web funktioniert jetzt genauso wie Native
- ✅ Profil lädt korrekt nach Login
- ✅ Besseres Logging für Debugging
- ✅ Robusteres DateTime-Parsing

### Testing
- ✅ Chrome/Web: Funktioniert
- ✅ macOS: Funktioniert weiterhin
- ✅ Beide Plattformen zeigen Profil korrekt

---

**Datum:** 2026-02-08
**Status:** ✅ KOMPLETT GELÖST
**Dauer:** ~45 Minuten (Debugging + Fix + Dokumentation)
**Lines of Code:** ~40 Zeilen
**Ready for Production:** JA
