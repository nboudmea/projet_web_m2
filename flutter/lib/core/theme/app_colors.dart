import 'package:flutter/material.dart';

/// Tokens de couleur — source unique de vérité.
/// Miroir exact des variables CSS Angular (:root) et des variables SCSS des composants.
abstract final class AppColors {
  // ── Fond / surface ────────────────────────────────────────────────────────
  /// #F9FAFB — fond de page ($light)
  static const background = Color(0xFFF9FAFB);

  /// #FFFFFF — fond des cartes
  static const surface = Color(0xFFFFFFFF);

  // ── Texte ─────────────────────────────────────────────────────────────────
  /// #111111 — texte principal ($dark)
  static const foreground = Color(0xFF111111);

  /// #6B7280 — texte secondaire, labels ($muted)
  static const mutedForeground = Color(0xFF6B7280);

  // ── Bouton principal ──────────────────────────────────────────────────────
  static const primary = Color(0xFF111111);
  static const primaryForeground = Color(0xFFFFFFFF);

  // ── Accent Vert Lime ──────────────────────────────────────────────────────
  /// #D4FF3F — vert lime ($lime)
  static const accent = Color(0xFFD4FF3F);
  static const accentForeground = Color(0xFF111111);

  // ── Destructive ───────────────────────────────────────────────────────────
  static const destructive = Color(0xFFEF4444);
  static const destructiveForeground = Color(0xFFFFFFFF);

  // ── Bordures / champs ─────────────────────────────────────────────────────
  /// #E5E7EB — bordures et champs de saisie
  static const border = Color(0xFFE5E7EB);
  static const input  = Color(0xFFE5E7EB);
  static const ring   = Color(0xFF111111);

  // ── Accent de bordure sur les stat cards (miroir Angular .stat-card mods) ─
  /// Élève — tâches terminées : border-top 3px solid #86EFAC  (vert pâle)
  static const statBorderDoneEleve = Color(0xFF86EFAC);

  /// Bénévole — tâches en cours : border-left 4px solid #FCD34D  (ambre)
  static const statBorderPendingBenevole = Color(0xFFFCD34D);

  /// Bénévole — tâches terminées : border-left 4px solid #6EE7B7  (teal)
  static const statBorderDoneBenevole = Color(0xFF6EE7B7);

  // ── Badge rôle ────────────────────────────────────────────────────────────
  /// Élève : fond lime / texte dark → utilise accent / accentForeground

  /// Bénévole : #E0E7FF / #3730A3 (indigo-100 / indigo-800)
  static const badgeBenevoleBg = Color(0xFFE0E7FF);
  static const badgeBenevoleFg = Color(0xFF3730A3);

  // ── Badges de tâches élève ────────────────────────────────────────────────
  /// Fond ambre (tâches en cours) : #FEF3C7 / #92400E
  static const taskBadgeBg  = Color(0xFFFEF3C7);
  static const taskBadgeFg  = Color(0xFF92400E);
  /// Fond neutre (0 tâche) : #F3F4F6
  static const taskBadgeZeroBg = Color(0xFFF3F4F6);

  // ── Fond neutre (tag, group count) ────────────────────────────────────────
  static const tagBg = Color(0xFFF3F4F6);

  // ── Ombres (miroir exact Angular) ─────────────────────────────────────────
  /// Carte auth :  0 4px 32px rgba(0,0,0,.10)  +  0 1px 4px rgba(0,0,0,.06)
  static const shadowCardLarge = BoxShadow(
    color: Color(0x1A000000), // .10
    blurRadius: 32,
    offset: Offset(0, 4),
  );
  static const shadowCardInner = BoxShadow(
    color: Color(0x0F000000), // .06
    blurRadius: 4,
    offset: Offset(0, 1),
  );

  /// Douce — .page sections, AppCard :  0 2px 16px rgba(0,0,0,.06)
  static const shadowSoft = BoxShadow(
    color: Color(0x0F000000),
    blurRadius: 16,
    offset: Offset(0, 2),
  );

  /// Stat card :  0 2px 12px rgba(0,0,0,.06)
  static const shadowStatCard = BoxShadow(
    color: Color(0x0F000000),
    blurRadius: 12,
    offset: Offset(0, 2),
  );

  /// Item (tâche, élève) :  0 1px 6px rgba(0,0,0,.05)
  static const shadowItem = BoxShadow(
    color: Color(0x0D000000), // .05
    blurRadius: 6,
    offset: Offset(0, 1),
  );

  /// Survol :  0 4px 16px rgba(0,0,0,.08)
  static const shadowHover = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 16,
    offset: Offset(0, 4),
  );
}
