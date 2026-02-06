import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/constants/app_colors.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authService = ref.read(authServiceProvider);
    final result = await authService.signInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result.isSuccess) {
      // Zum Splash → prüft Onboarding-Status und leitet weiter
      context.go('/splash');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Login fehlgeschlagen'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo/Icon
                  const Icon(
                    Icons.nightlight_round,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),

                  // Titel
                  Text(
                    'Nuuray Glow',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Untertitel
                  Text(
                    'Kosmische Unterhaltung',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Email-Feld
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bitte Email eingeben';
                      }
                      if (!value.contains('@')) {
                        return 'Ungültige Email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Passwort-Feld
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleLogin(),
                    decoration: InputDecoration(
                      labelText: 'Passwort',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bitte Passwort eingeben';
                      }
                      if (value.length < 6) {
                        return 'Passwort muss mindestens 6 Zeichen haben';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Passwort vergessen
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Passwort-Reset-Flow
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Passwort-Reset kommt bald!'),
                          ),
                        );
                      },
                      child: const Text('Passwort vergessen?'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login-Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Anmelden'),
                  ),
                  const SizedBox(height: 16),

                  // Zur Registrierung
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Noch kein Account?'),
                      TextButton(
                        onPressed: () => context.push('/signup'),
                        child: const Text('Jetzt registrieren'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
