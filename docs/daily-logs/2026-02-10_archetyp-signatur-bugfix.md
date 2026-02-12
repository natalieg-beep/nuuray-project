# Archetyp-Signatur Bugfix: signature_text wurde überschrieben

> **Datum:** 2026-02-10
> **Bug:** Archetyp ändert sich bei jedem Login + Signatur-Screen zeigt alten Archetyp
> **Root Cause:** `updateUserProfile()` überschreibt `signature_text` mit `null`
> **Status:** ✅ **GEFIXT**

---

## 🐛 Problem-Beschreibung

### Symptom 1: Archetyp ändert sich bei jedem Login
- User loggt sich aus und wieder ein
- Archetyp-Titel ist plötzlich anders
- Sollte konstant bleiben (gecacht in DB)

### Symptom 2: Home Screen ≠ Signatur Screen
- Home Screen zeigt einen Archetyp-Titel
- Signatur-Detail-Screen zeigt einen ANDEREN Archetyp-Titel
- Beide sollten identisch sein (gleiche Datenquelle!)

---

## 🔍 Root Cause Analysis

### Der Bug (gefunden in `user_profile_service.dart`):

```dart
// Zeile 74-88 (VORHER)
Future<bool> updateUserProfile(UserProfile profile) async {
  try {
    await _supabase
        .from('profiles')
        .update(profile.copyWith(updatedAt: DateTime.now()).toJson())  // ← HIER!
        .eq('id', profile.id);

    log('Profil aktualisiert für User ${profile.id}');
    return true;
  } catch (e) {
    log('updateUserProfile Fehler: $e');
    return false;
  }
}
```

**Warum ist das ein Problem?**

1. **`profile.toJson()` serialisiert das GESAMTE Objekt** — auch `null`-Werte
2. **Edit Profile Screen** erstellt ein `UserProfile`-Objekt nur mit Edit-Feldern:
   ```dart
   final updatedProfile = UserProfile(
     id: currentProfile.id,
     displayName: _displayNameController.text,
     birthDate: _birthDate,
     // ... andere Felder ...
     // ABER: signature_text ist NICHT Teil des Formulars → bleibt null!
   );
   ```
3. **`toJson()` inkludiert `signature_text: null`** in der Update-Map
4. **Supabase UPDATE überschreibt `signature_text` in DB mit `null`**
5. **Bei nächstem Login:** Archetyp-Signatur wird neu generiert (weil Cache leer!)

---

## 🛠️ Die Lösung

### Fix 1: `updateUserProfile()` nur non-null Felder senden

**Datei:** `apps/glow/lib/src/features/profile/services/user_profile_service.dart`

**Vorher:**
```dart
await _supabase
    .from('profiles')
    .update(profile.copyWith(updatedAt: DateTime.now()).toJson())
    .eq('id', profile.id);
```

**Nachher:**
```dart
// Erstelle Update-Map nur mit non-null Feldern
final Map<String, dynamic> updateData = {};

// Basis-Felder (immer setzen falls vorhanden)
if (profile.displayName != null) {
  updateData['display_name'] = profile.displayName;
}
if (profile.callName != null) {
  updateData['call_name'] = profile.callName;
}
// ... etc. für alle Felder ...

// WICHTIG: signature_text wird NICHT überschrieben!
// Das wird nur via generateAndCacheArchetypeSignature() gesetzt.

// Updated-At immer setzen
updateData['updated_at'] = DateTime.now().toIso8601String();

log('📝 updateUserProfile: Update-Felder: ${updateData.keys.join(", ")}');

await _supabase.from('profiles').update(updateData).eq('id', profile.id);
```

**Vorteile:**
- ✅ `signature_text` wird NIEMALS überschrieben (außer explizit)
- ✅ Nur tatsächlich geänderte Felder werden gesendet
- ✅ Besseres Logging (welche Felder werden updated?)

### Fix 2: `createUserProfile()` auch anpassen

**Vorher:**
```dart
final data = profile.toJson();
await _supabase.from('profiles').insert(data);
```

**Nachher:**
```dart
final data = profile.toJson();

// WICHTIG: signature_text wird bei INSERT nicht gesetzt (wird später generiert)
data.remove('signature_text');

log('Sende Daten an Supabase: ${data.keys.join(", ")}');
await _supabase.from('profiles').insert(data);
```

**Warum wichtig?**
- Auch beim ersten Profil-Erstellen kann `signature_text` auf `null` gesetzt werden
- Das würde den Cache-Check umgehen (NULL vs. nicht vorhanden)

---

## 🎯 Wie der Cache-Check funktioniert

**In `archetype_signature_service.dart` (Zeile 43-56):**

```dart
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
    return existingSignature;  // ← RETURN EXISTING (keine neue Generierung!)
  }
}

// Nur wenn signature_text NULL oder leer ist → Generiere neu
```

**Der Cache-Check funktioniert perfekt — ER WURDE NUR UMGANGEN!**

Warum?
- Nach Profile-Edit war `signature_text = null` in DB
- Cache-Check fand `null` → generiert neu
- Bei jedem Login/Edit dasselbe

---

## 🧪 Testing

### Test 1: Profile-Edit überschreibt nicht mehr signature_text

**Schritte:**
1. Login als bestehender User (mit signature_text in DB)
2. Navigiere zu Edit Profile
3. Ändere z.B. `display_name`
4. Speichere
5. **Erwartung:** `signature_text` bleibt in DB erhalten

**Prüfung:**
```sql
SELECT signature_text FROM profiles WHERE id = 'user-id';
-- Sollte GLEICH bleiben nach Edit!
```

### Test 2: Archetyp bleibt konstant

**Schritte:**
1. Login
2. Notiere Archetyp-Titel auf Home Screen
3. Logout
4. Erneut Login
5. **Erwartung:** Archetyp-Titel ist IDENTISCH

### Test 3: Home Screen = Signatur Screen

**Schritte:**
1. Home Screen: Notiere Archetyp-Titel
2. Tippe auf "Deine Signatur" → Signatur-Detail-Screen
3. **Erwartung:** Archetyp-Titel ist IDENTISCH

---

## 📊 Betroffene Dateien

| Datei | Änderung | Zeilen |
|-------|----------|--------|
| `user_profile_service.dart` | `updateUserProfile()` umgebaut: Nur non-null Felder senden | 74-148 |
| `user_profile_service.dart` | `createUserProfile()` angepasst: `signature_text` entfernen bei INSERT | 55-66 |

---

## 🚀 Follow-Up Tasks

### Sofort (für User zum Testen):
1. ✅ **Code geändert** (`user_profile_service.dart`)
2. ⏳ **App neu starten**
3. ⏳ **Test 1:** Profile Edit → `signature_text` bleibt erhalten?
4. ⏳ **Test 2:** Logout/Login → Archetyp bleibt gleich?
5. ⏳ **Test 3:** Home + Signatur Screen → Titel identisch?

### Optional (später):
1. **DB-Migration:** Alle User die `signature_text = null` haben, neu generieren
   ```sql
   -- Finde User ohne Signatur:
   SELECT id, display_name
   FROM profiles
   WHERE signature_text IS NULL
   AND onboarding_completed = true;
   ```

2. **Monitoring:** Log erweitern um zu tracken:
   - Wie oft wird Cache-Check HIT vs. MISS?
   - Wie viele User haben `signature_text = null`?

---

## 💡 Lessons Learned

### Anti-Pattern: `toJson()` für Updates
**Problem:**
- `toJson()` serialisiert das GESAMTE Model
- Null-Werte werden zu `null` in JSON
- DB-Update überschreibt auch `null`-Werte

**Bessere Praxis:**
- Nur geänderte Felder in Update-Map packen
- Explizite Kontrolle über was gesendet wird
- Felder die nicht geändert werden → nicht in Update inkludieren

### Pattern: "Immutable Fields"
**Beispiel:** `signature_text` ist ein "immutable field":
- Wird nur einmal generiert (beim Onboarding)
- Wird gecacht in DB
- Sollte NIEMALS durch normale Profil-Updates überschrieben werden
- Nur via **dedizierte Methode** änderbar (z.B. `regenerateSignature()`)

**Umsetzung:**
```dart
// FALSCH:
await supabase.from('profiles').update(profile.toJson()).eq('id', userId);

// RICHTIG:
final updateData = {
  'display_name': newName,
  'birth_date': newDate,
  // signature_text NICHT inkludieren!
};
await supabase.from('profiles').update(updateData).eq('id', userId);
```

---

## 📝 Dokumentation

**Erstellt:**
- `docs/daily-logs/2026-02-10_archetyp-signatur-bugfix.md` — Dieser Session-Log
- `docs/ARCHETYP_SIGNATUR_BUG_ANALYSE.md` — Detaillierte Bug-Analyse (vorher)

**Aktualisiert:**
- `apps/glow/lib/src/features/profile/services/user_profile_service.dart` — `updateUserProfile()` + `createUserProfile()`

---

**Letzte Aktualisierung:** 2026-02-10
**Status:** ✅ **GEFIXT - READY FOR TESTING**
