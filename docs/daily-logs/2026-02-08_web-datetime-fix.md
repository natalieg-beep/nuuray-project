# Web DateTime Parsing Fix

**Problem:** Profil lädt nicht in Chrome/Web, funktioniert aber in macOS

## Wahrscheinliche Ursache

DateTime-Parsing unterscheidet sich zwischen Web und nativen Plattformen:

### UserProfile.fromJson()
```dart
birthTime: json['birth_time'] != null
    ? DateTime.parse('2000-01-01 ${json['birth_time']}')
    : null,
```

**Problem:**
- Web: String-Concatenation kann zu ungültigem Format führen
- Native: Funktioniert meist trotzdem

### BirthChart.fromJson()
Ähnliches Problem bei:
- `calculatedAt: DateTime.parse(json['calculated_at'] as String)`
- Andere DateTime-Felder

## Mögliche Lösungen

### Option 1: Try-Catch um DateTime.parse()
```dart
birthTime: _parseDateTimeSafe(json['birth_time'], isTimeOnly: true),

static DateTime? _parseDateTimeSafe(dynamic value, {bool isTimeOnly = false}) {
  if (value == null) return null;
  try {
    if (isTimeOnly) {
      return DateTime.parse('2000-01-01 $value');
    }
    return DateTime.parse(value as String);
  } catch (e) {
    log('DateTime parsing failed: $e');
    return null;
  }
}
```

### Option 2: Explizites Zeitformat
```dart
birthTime: json['birth_time'] != null
    ? _parseTimeString(json['birth_time'] as String)
    : null,

static DateTime? _parseTimeString(String timeStr) {
  try {
    final parts = timeStr.split(':');
    if (parts.length < 2) return null;

    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    return DateTime(2000, 1, 1, hour, minute);
  } catch (e) {
    log('Time parsing failed: $e');
    return null;
  }
}
```

### Option 3: Supabase Timestamp Format
Prüfe ob Supabase timestamps im Web anders serialisiert werden.

## Debugging-Schritte

1. **Chrome DevTools Console öffnen** (F12)
2. **Nach Errors suchen:**
   - `FormatException: Invalid date format`
   - `TypeError: Cannot read properties of null`
   - Supabase-Errors

3. **Provider-State prüfen:**
   ```dart
   ref.listen(userProfileProvider, (previous, next) {
     next.when(
       data: (profile) => log('✅ Profile loaded: $profile'),
       loading: () => log('⏳ Loading profile...'),
       error: (err, stack) => log('❌ Profile error: $err\n$stack'),
     );
   });
   ```

4. **Network Tab prüfen:**
   - Geht die Supabase-Anfrage durch?
   - Kommt eine Response zurück?
   - Was steht in der Response?

## Wenn das nicht hilft

Weitere mögliche Ursachen:
- CORS-Probleme (Supabase)
- Service Worker Cache (alte Version)
- Browser localStorage Probleme
- Unterschiedliche Supabase SDK Verhalten (Web vs Native)

## Quick Fix zum Testen

In `main.dart` temporär logging hinzufügen:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Teste ob es ein Web-spezifisches Problem ist
  if (kIsWeb) {
    print('🌐 Running on Web');
  } else {
    print('📱 Running on Native');
  }

  await Supabase.initialize(/* ... */);

  runApp(const ProviderScope(child: NuurayGlowApp()));
}
```
