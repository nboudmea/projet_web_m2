import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Logo "Learn@Home" avec le @ en Vert Lime.
class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: AppColors.foreground,
        ),
        children: [
          TextSpan(text: 'Learn'),
          TextSpan(text: '@', style: TextStyle(color: AppColors.accent)),
          TextSpan(text: 'Home'),
        ],
      ),
    );
  }
}

/// Carte blanche avec coins arrondis et ombre douce — contenant du formulaire.
class AuthCard extends StatelessWidget {
  const AuthCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 32,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// En-tête de carte auth : titre (28px, w800) + sous-titre muted.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.0,
            height: 1.1,
            color: AppColors.foreground,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }
}

/// Séparateur horizontal fin utilisé dans le pied de la carte auth.
class AuthFooterDivider extends StatelessWidget {
  const AuthFooterDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: AppColors.input);
  }
}
