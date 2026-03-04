import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/auth_widgets.dart';
import '../widgets/login_form.dart';

/// Écran de connexion.
/// Miroir visuel de [LoginComponent] Angular — panneau droit (mobile-first).
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Logo ─────────────────────────────────────────────────
                  const Center(child: AuthLogo()),
                  const SizedBox(height: 32),

                  // ── Carte auth ───────────────────────────────────────────
                  AuthCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // En-tête
                        const AuthHeader(
                          title: 'Connexion',
                          subtitle: 'Bienvenue sur Learn\u0040Home',
                        ),
                        const SizedBox(height: 24),

                        // Formulaire
                        const LoginForm(),

                        // Pied de carte
                        const SizedBox(height: 20),
                        const AuthFooterDivider(),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => context.go('/register'),
                          child: Text.rich(
                            TextSpan(
                              text: 'Pas encore de compte ? ',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.mutedForeground,
                              ),
                              children: const [
                                TextSpan(
                                  text: 'S\'inscrire',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.foreground,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
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
