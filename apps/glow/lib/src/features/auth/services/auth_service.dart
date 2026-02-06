import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Auth Service für Email-Login, Sign-Up und Session-Management
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Gibt den aktuellen User zurück (null wenn nicht eingeloggt)
  User? get currentUser => _supabase.auth.currentUser;

  /// Prüft ob User eingeloggt ist
  bool get isAuthenticated => currentUser != null;

  /// Auth State Stream für Listener
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Sign-Up mit Email & Passwort
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return AuthResult.error('Registrierung fehlgeschlagen');
      }

      log('Sign-Up erfolgreich: ${response.user!.email}');
      return AuthResult.success(response.user!);
    } on AuthException catch (e) {
      log('Sign-Up Fehler: ${e.message}');
      return AuthResult.error(_parseAuthError(e));
    } catch (e) {
      log('Sign-Up unerwarteter Fehler: $e');
      return AuthResult.error('Ein Fehler ist aufgetreten');
    }
  }

  /// Login mit Email & Passwort
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return AuthResult.error('Login fehlgeschlagen');
      }

      log('Login erfolgreich: ${response.user!.email}');
      return AuthResult.success(response.user!);
    } on AuthException catch (e) {
      log('Login Fehler: ${e.message}');
      return AuthResult.error(_parseAuthError(e));
    } catch (e) {
      log('Login unerwarteter Fehler: $e');
      return AuthResult.error('Ein Fehler ist aufgetreten');
    }
  }

  /// Logout
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      log('Logout erfolgreich');
    } catch (e) {
      log('Logout Fehler: $e');
    }
  }

  /// Passwort zurücksetzen (Email mit Reset-Link senden)
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      log('Passwort-Reset Email gesendet an: $email');
      return AuthResult.success(null, message: 'Email wurde gesendet');
    } on AuthException catch (e) {
      log('Passwort-Reset Fehler: ${e.message}');
      return AuthResult.error(_parseAuthError(e));
    } catch (e) {
      log('Passwort-Reset unerwarteter Fehler: $e');
      return AuthResult.error('Ein Fehler ist aufgetreten');
    }
  }

  /// Auth-Fehler in benutzerfreundliche Nachrichten übersetzen
  String _parseAuthError(AuthException error) {
    switch (error.message) {
      case 'Invalid login credentials':
        return 'Ungültige Email oder Passwort';
      case 'Email not confirmed':
        return 'Bitte bestätige deine Email-Adresse';
      case 'User already registered':
        return 'Diese Email ist bereits registriert';
      case 'Password should be at least 6 characters':
        return 'Passwort muss mindestens 6 Zeichen lang sein';
      default:
        return error.message;
    }
  }
}

/// Ergebnis-Klasse für Auth-Operationen
class AuthResult {
  final User? user;
  final String? error;
  final String? message;

  AuthResult._({this.user, this.error, this.message});

  factory AuthResult.success(User? user, {String? message}) {
    return AuthResult._(user: user, message: message);
  }

  factory AuthResult.error(String error) {
    return AuthResult._(error: error);
  }

  bool get isSuccess => error == null;
  bool get isError => error != null;
}
