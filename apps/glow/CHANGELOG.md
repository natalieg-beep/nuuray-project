# NUURAY GLOW — Entwicklungs-Dokumentation

## 2026-02-05 — Projekt-Initialisierung

### Flutter-App Setup ✅
**Was wurde gemacht:**
1. Flutter-App mit `flutter create` erstellt
   - Organisation: `com.nuuray`
   - Projekt-Name: `nuuray_glow`
   - Plattformen: iOS, Android, Web, macOS, Linux, Windows

2. `pubspec.yaml` konfiguriert:
   - SDK-Version: `>=3.2.0 <4.0.0`
   - Flutter: `>=3.16.0`
   - Shared Packages hinzugefügt:
     - `nuuray_core` (Datenmodelle, Berechnungen)
     - `nuuray_api` (Supabase, Claude API)
     - `nuuray_ui` (Theme, Widgets, i18n)
   - State Management: `flutter_riverpod` + `riverpod_annotation` + `riverpod_generator`
   - Routing: `go_router`
   - Storage: `shared_preferences`
   - Linting: `flutter_lints` + `riverpod_lint`

3. Dependency-Konflikt gelöst:
   - Problem: `intl`-Version war auf `^0.19.0` fixiert, aber `flutter_localizations` braucht `0.20.2`
   - Lösung: `intl: any` in `nuuray_glow` und `nuuray_core`

4. Dependencies erfolgreich installiert (`flutter pub get`)
   - 121 Dependencies heruntergeladen
   - Supabase, Riverpod, GoRouter, Dio, etc. ready

### App-Struktur & Basis-Setup ✅
**Was wurde gemacht:**
1. Ordnerstruktur in `lib/` erstellt:
   ```
   lib/
   ├── main.dart
   └── src/
       ├── core/
       │   ├── auth/          # Auth-Services (folgt später)
       │   ├── config/        # AppConfig mit Supabase-URLs
       │   ├── navigation/    # GoRouter mit Placeholder-Screens
       │   └── providers/     # Riverpod Providers (Supabase, Auth)
       ├── features/
       │   ├── home/
       │   ├── horoscope/
       │   ├── moon_phases/
       │   ├── onboarding/
       │   ├── partner_check/
       │   └── profile/
       └── shared/
           ├── constants/     # AppColors (Glow-Farbpalette)
           ├── utils/
           └── widgets/
   ```

2. Konfigurationsdateien erstellt:
   - `app_config.dart`: App-Konfiguration mit Supabase-URLs (aus Env-Variablen)
   - `app_colors.dart`: Glow-Farbpalette (Primary: #C8956E Warm Gold)
   - `app_providers.dart`: Riverpod Providers für Supabase Client und Auth State
   - `app_router.dart`: GoRouter mit Routen für Splash, Login, Onboarding, Home

3. `main.dart` komplett neu aufgebaut:
   - Supabase-Initialisierung in `main()`
   - `ProviderScope` für Riverpod
   - `MaterialApp.router` mit GoRouter
   - Vollständiges Theme-Setup (Material 3, Glow-Farben)
   - Localization-Support (DE/EN)

4. Shared Packages Dependencies installiert:
   - `nuuray_core`: 72 Dependencies
   - `nuuray_api`: 111 Dependencies
   - `nuuray_ui`: 54 Dependencies

5. Code-Analyse erfolgreich: Keine Errors oder Warnings mehr ✅

### Nächste Schritte
1. Auth-Integration mit Supabase (Email + Apple + Google Sign-In)
2. Onboarding-Flow implementieren
3. Geburtsdaten-Engine aufbauen

### Technische Details
- Arbeitsverzeichnis: `/Users/natalieg/Downloads/nuuray-project/apps/glow`
- Flutter SDK: Verwendet System-Installation
- Packages-Path: `../../packages/` (relative zu glow/)
- Theme: Material 3 mit Glow-Farbpalette
