import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Carte de base du design system — fond blanc, radius 20px, ombre douce.
/// Miroir du `$radius: 20px` et `.card` Angular.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [AppColors.shadowSoft],
      ),
      padding: padding ?? const EdgeInsets.all(24),
      child: child,
    );
  }
}

/// Petite carte statistique — miroir des `.stat-card` Angular.
/// Supporte une bordure colorée en haut (élève) ou à gauche (bénévole).
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.borderTopColor,
    this.borderLeftColor,
  });

  final String value;
  final String label;

  /// Élève — border-top 3px (ex. tâches terminées : #86EFAC, progression : lime)
  final Color? borderTopColor;

  /// Bénévole — border-left 4px (ex. en cours : #FCD34D, terminées : #6EE7B7)
  final Color? borderLeftColor;

  @override
  Widget build(BuildContext context) {
    Border? border;
    if (borderTopColor != null) {
      border = Border(top: BorderSide(color: borderTopColor!, width: 3));
    } else if (borderLeftColor != null) {
      border = Border(left: BorderSide(color: borderLeftColor!, width: 4));
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: border,
        boxShadow: const [AppColors.shadowStatCard],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -2,
              height: 1,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bouton principal noir avec cercle Vert Lime — miroir du composant Angular.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        shape: const StadiumBorder(),
        padding:
            const EdgeInsets.only(left: 20, right: 8, top: 10, bottom: 10),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryForeground,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
          const SizedBox(width: 12),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward,
              color: AppColors.accentForeground,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}

/// Barre de progression horizontale — miroir de `.progress-bar-track/fill` Angular.
/// Fond : #E5E7EB, remplissage : Vert Lime #D4FF3F.
class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.value, this.label});

  /// Entre 0.0 et 1.0
  final double value;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[          Text(
            label!,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 8),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: AppColors.border, // #E5E7EB
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.accent), // lime
          ),
        ),
      ],
    );
  }
}

/// État vide illustré — miroir des `.empty-state` Angular.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
  });

  final String icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge de rôle — miroir de `.badge-role` Angular.
/// Élève : fond lime / texte dark.  Bénévole : fond indigo-100 / texte indigo-800.
class RoleBadge extends StatelessWidget {
  const RoleBadge({super.key, required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final isBenevole = role == 'benevole';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isBenevole ? AppColors.badgeBenevoleBg : AppColors.accent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isBenevole ? 'Bénévole' : 'Élève',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: isBenevole
              ? AppColors.badgeBenevoleFg
              : AppColors.accentForeground,
        ),
      ),
    );
  }
}
