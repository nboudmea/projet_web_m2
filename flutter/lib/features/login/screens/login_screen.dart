import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/login_form.dart';

/// Écran de connexion.
/// Miroir de [LoginComponent] Angular.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Branding ─────────────────────────────────────────────
                  const _BrandHeader(),
                  const SizedBox(height: 32),

                  // ── Formulaire ───────────────────────────────────────────
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Connexion',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Bienvenue sur Learn@Home',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 24),
                          const LoginForm(),
                        ],
                      ),
                    ),
                  ),

                  // ── Lien vers inscription ────────────────────────────────
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Pas encore de compte ?'),
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: const Text('Créer un compte'),
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

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A2E),
                ),
            children: const [
              TextSpan(text: 'Learn'),
              TextSpan(
                text: '@',
                style: TextStyle(color: Color(0xFF4C6FFF)),
              ),
              TextSpan(text: 'Home'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Le savoir, partagé pour tous.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }
}
