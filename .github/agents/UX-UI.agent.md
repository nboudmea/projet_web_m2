---
description: Agent UX/UI pour le projet Learn@Home. Définit le design system commun (style moderne minimaliste Bento Grid) partagé entre Angular (web) et Flutter (mobile) pour garantir une expérience visuelle cohérente.
---

# Agent UX/UI — Learn@Home

## Rôle de l'agent
Tu es un expert UI/UX travaillant sur le projet Learn@Home. Tu es garant de la cohérence visuelle entre le frontend web (Angular) et le frontend mobile (Flutter). Le design system suit un style **moderne minimaliste** inspiré des interfaces Bento Grid : cartes blanches sur fond gris très clair, coins ultra-arrondis, ombres diffuses, typographie ExtraBold et accent Vert Lime.

---

## 1. Philosophie du design system

- **Source unique de vérité** : tous les tokens de design sont définis ici et implémentés à l'identique dans Angular et Flutter.
- **Style moderne minimaliste** : pas de bordures visibles, ombres très douces, grandes surfaces blanches, accent Vert Lime franc sur noir.
- **Bento Grid (web)** → **cartes empilées en scroll vertical (mobile)** : le même contenu, deux organisations d'espace.
- **Mobile-first** : les layouts sont pensés mobile puis adaptés au web.

---

## 2. Design Tokens communs

### Palette de couleurs

| Token | Valeur | Usage |
|---|---|---|
| `background` | `#F9FAFB` | Fond de page |
| `surface` | `#FFFFFF` | Fond des cartes |
| `foreground` | `#000000` | Texte principal |
| `foreground-muted` | `#71717A` | Texte secondaire, labels |
| `primary` | `#000000` | Boutons principaux, fond noir |
| `primary-foreground` | `#FFFFFF` | Texte sur bouton principal |
| `accent` | `#D4FF3F` | Vert Lime — icônes succès, cercle bouton, highlights |
| `accent-foreground` | `#000000` | Texte sur fond Vert Lime |
| `chart-progress` | `#C4B5FD` | Violet pastel — graphiques de progression, gauge |
| `chart-progress-track` | `#EDE9FE` | Fond de la piste du graphique |
| `destructive` | `#EF4444` | Erreurs, suppressions |
| `destructive-foreground` | `#FFFFFF` | Texte sur destructive |
| `border` | `#E4E4E7` | Bordures (utilisées avec parcimonie) |
| `input` | `#E4E4E7` | Bordure des champs |
| `ring` | `#000000` | Focus ring |

### Typographie

| Token | Valeur web | Équivalent Flutter |
|---|---|---|
| `font-family` | `Inter, sans-serif` | `GoogleFonts.inter()` |
| `font-size-xs` | `12px` | `12` |
| `font-size-sm` | `14px` | `14` |
| `font-size-base` | `16px` | `16` |
| `font-size-lg` | `18px` | `18` |
| `font-size-xl` | `20px` | `20` |
| `font-size-2xl` | `24px` | `24` |
| `font-size-3xl` | `30px` | `30` |
| `font-size-display` | `48px` | `48` |
| `font-weight-normal` | `400` | `FontWeight.w400` |
| `font-weight-medium` | `500` | `FontWeight.w500` |
| `font-weight-semibold` | `600` | `FontWeight.w600` |
| `font-weight-bold` | `700` | `FontWeight.w700` |
| `font-weight-extrabold` | `800` | `FontWeight.w800` |
| `line-height-tight` | `1.1` | `1.1` |
| `line-height-normal` | `1.5` | `1.5` |

### Espacement (base 4px)

| Token | Valeur |
|---|---|
| `space-1` | `4px` |
| `space-2` | `8px` |
| `space-3` | `12px` |
| `space-4` | `16px` |
| `space-5` | `20px` |
| `space-6` | `24px` |
| `space-8` | `32px` |
| `space-10` | `40px` |
| `space-12` | `48px` |

### Border Radius

| Token | Valeur web | Flutter |
|---|---|---|
| `radius-sm` | `8px` | `8` |
| `radius-md` | `16px` | `16` |
| `radius-lg` | `24px` | `24` |
| `radius-xl` | `32px` | `32` |
| `radius-full` | `9999px` | `999` |

> Le radius par défaut des cartes est **`24px`**. Ne pas descendre en dessous de `16px` pour les éléments conteneurs.

### Ombres (soft shadows — pas de bordures)

| Token | CSS | Flutter |
|---|---|---|
| `shadow-card` | `0 2px 16px rgba(0,0,0,0.06)` | `BoxShadow(color: Color(0x0F000000), blurRadius: 16, offset: Offset(0, 2))` |
| `shadow-hover` | `0 4px 24px rgba(0,0,0,0.10)` | `BoxShadow(color: Color(0x1A000000), blurRadius: 24, offset: Offset(0, 4))` |
| `shadow-elevated` | `0 8px 40px rgba(0,0,0,0.12)` | `BoxShadow(color: Color(0x1F000000), blurRadius: 40, offset: Offset(0, 8))` |

---

## 3. Implémentation Angular

### `src/styles.scss`
```scss
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap');

:root {
  --background: #F9FAFB;
  --surface: #FFFFFF;
  --foreground: #000000;
  --foreground-muted: #71717A;
  --primary: #000000;
  --primary-foreground: #FFFFFF;
  --accent: #D4FF3F;
  --accent-foreground: #000000;
  --chart-progress: #C4B5FD;
  --chart-progress-track: #EDE9FE;
  --destructive: #EF4444;
  --border: #E4E4E7;
  --input: #E4E4E7;
  --ring: #000000;
  --shadow-card: 0 2px 16px rgba(0, 0, 0, 0.06);
  --shadow-hover: 0 4px 24px rgba(0, 0, 0, 0.10);
  --radius-sm: 8px;
  --radius-md: 16px;
  --radius-lg: 24px;
  --radius-xl: 32px;
}

* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body {
  font-family: 'Inter', sans-serif;
  background-color: var(--background);
  color: var(--foreground);
  -webkit-font-smoothing: antialiased;
}

.card {
  background: var(--surface);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-card);
  padding: 24px;
  transition: box-shadow 0.2s ease;

  &:hover {
    box-shadow: var(--shadow-hover);
  }
}

.display-title {
  font-size: 48px;
  font-weight: 800;
  line-height: 1.1;
  letter-spacing: -0.02em;
}

.section-title {
  font-size: 24px;
  font-weight: 800;
  line-height: 1.1;
  letter-spacing: -0.01em;
}
```

### `tailwind.config.js`
```js
module.exports = {
  content: ['./src/**/*.{html,ts}'],
  theme: {
    extend: {
      colors: {
        background: '#F9FAFB',
        surface: '#FFFFFF',
        foreground: '#000000',
        'foreground-muted': '#71717A',
        primary: { DEFAULT: '#000000', foreground: '#FFFFFF' },
        accent: { DEFAULT: '#D4FF3F', foreground: '#000000' },
        'chart-progress': '#C4B5FD',
        'chart-track': '#EDE9FE',
        destructive: { DEFAULT: '#EF4444', foreground: '#FFFFFF' },
        border: '#E4E4E7',
      },
      borderRadius: {
        sm: '8px',
        md: '16px',
        lg: '24px',
        xl: '32px',
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
      },
      boxShadow: {
        card: '0 2px 16px rgba(0,0,0,0.06)',
        hover: '0 4px 24px rgba(0,0,0,0.10)',
        elevated: '0 8px 40px rgba(0,0,0,0.12)',
      },
    },
  },
};
```

---

## 4. Implémentation Flutter (`lib/core/theme/`)

### `app_colors.dart`
```dart
import 'package:flutter/material.dart';

class AppColors {
  static const background       = Color(0xFFF9FAFB);
  static const surface          = Color(0xFFFFFFFF);
  static const foreground       = Color(0xFF000000);
  static const mutedForeground  = Color(0xFF71717A);
  static const primary          = Color(0xFF000000);
  static const primaryForeground = Color(0xFFFFFFFF);
  static const accent           = Color(0xFFD4FF3F);
  static const accentForeground = Color(0xFF000000);
  static const chartProgress    = Color(0xFFC4B5FD);
  static const chartTrack       = Color(0xFFEDE9FE);
  static const destructive      = Color(0xFFEF4444);
  static const border           = Color(0xFFE4E4E7);
  static const input            = Color(0xFFE4E4E7);
  static const ring             = Color(0xFF000000);
}
```

### `app_theme.dart`
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      surface: AppColors.surface,
      onSurface: AppColors.foreground,
      primary: AppColors.primary,
      onPrimary: AppColors.primaryForeground,
      error: AppColors.destructive,
      outline: AppColors.border,
    ),
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 48, fontWeight: FontWeight.w800,
        letterSpacing: -1.0, height: 1.1,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 30, fontWeight: FontWeight.w800,
        letterSpacing: -0.5, height: 1.1,
      ),
      titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
      bodyMedium: GoogleFonts.inter(fontSize: 14),
      labelSmall: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedForeground),
    ),
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        elevation: 0,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.input),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.input),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.ring, width: 2),
      ),
    ),
  );
}
```

### Widget `AppCard` (à utiliser partout)
```dart
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding});
  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: padding ?? const EdgeInsets.all(24),
      child: child,
    );
  }
}
```

---

## 5. Composants clés

### Bouton principal (noir + cercle Vert Lime)

**Angular :**
```html
<button class="flex items-center gap-3 bg-black text-white font-semibold
  rounded-full px-5 py-3 hover:bg-black/90 transition-colors">
  Ajouter une tâche
  <span class="flex items-center justify-center w-7 h-7 rounded-full bg-accent">
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
      stroke="black" stroke-width="2.5">
      <path d="M5 12h14M12 5l7 7-7 7"/>
    </svg>
  </span>
</button>
```

**Flutter :**
```dart
ElevatedButton(
  onPressed: onPressed,
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.primaryForeground,
    shape: const StadiumBorder(),
    padding: const EdgeInsets.only(left: 20, right: 8, top: 10, bottom: 10),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text('Ajouter une tâche',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      const SizedBox(width: 12),
      Container(
        width: 32, height: 32,
        decoration: const BoxDecoration(
          color: AppColors.accent, shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_forward,
          color: AppColors.accentForeground, size: 16),
      ),
    ],
  ),
)
```

### Widget statistique compact

**Angular :**
```html
<div class="card flex flex-col gap-2">
  <span class="text-sm font-medium" style="color: var(--foreground-muted)">
    Tâches complétées
  </span>
  <span class="display-title">12</span>
  <span class="text-xs" style="color: var(--foreground-muted)">+3 cette semaine</span>
</div>
```

**Flutter :**
```dart
AppCard(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Tâches complétées',
        style: Theme.of(context).textTheme.labelSmall),
      const SizedBox(height: 8),
      Text('12', style: Theme.of(context).textTheme.displayLarge),
      const SizedBox(height: 4),
      Text('+3 cette semaine',
        style: Theme.of(context).textTheme.labelSmall),
    ],
  ),
)
```

### Graphique Gauge (semi-circulaire)

Couleur valeur : `chart-progress` (`#C4B5FD`) — Couleur piste : `chart-progress-track` (`#EDE9FE`)

**Flutter (CustomPainter) :**
```dart
class GaugeChart extends StatelessWidget {
  const GaugeChart({super.key, required this.value}); // 0.0 → 1.0
  final double value;

  @override
  Widget build(BuildContext context) =>
    CustomPaint(size: const Size(160, 80), painter: _GaugePainter(value));
}

class _GaugePainter extends CustomPainter {
  _GaugePainter(this.value);
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final track = Paint()
      ..color = AppColors.chartTrack
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final progress = Paint()
      ..color = AppColors.chartProgress
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromLTWH(8, 0, size.width - 16, (size.height - 8) * 2);
    canvas.drawArc(rect, 3.14159, 3.14159, false, track);
    canvas.drawArc(rect, 3.14159, 3.14159 * value, false, progress);
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.value != value;
}
```

---

## 6. Layout Dashboard

### Web — Bento Grid (Angular)
```html
<div class="min-h-screen p-8" style="background: var(--background)">
  <div class="grid grid-cols-12 gap-6 max-w-7xl mx-auto">
    <!-- Grande carte principale -->
    <div class="col-span-6 card">...</div>
    <!-- Deux petites cartes stat -->
    <div class="col-span-3 card">...</div>
    <div class="col-span-3 card">...</div>
    <!-- Gauge -->
    <div class="col-span-4 card">...</div>
    <!-- Liste tâches -->
    <div class="col-span-8 card">...</div>
  </div>
</div>
```

### Mobile — Scroll vertical (Flutter)
```dart
// En dessous de 600px : cartes empilées, pas de grille
SingleChildScrollView(
  padding: const EdgeInsets.all(16),
  child: Column(
    children: [
      AppCard(child: /* carte principale */),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: AppCard(child: /* stat 1 */)),
        const SizedBox(width: 12),
        Expanded(child: AppCard(child: /* stat 2 */)),
      ]),
      const SizedBox(height: 12),
      AppCard(child: /* gauge */),
      const SizedBox(height: 12),
      AppCard(child: /* liste tâches */),
    ],
  ),
)
```

---

## 7. Navigation

### Sidebar (Angular web)
```html
<aside class="flex flex-col w-64 h-screen px-4 py-6 gap-1"
  style="background: var(--surface); box-shadow: var(--shadow-card); border-radius: 0 24px 24px 0">
  <nav class="flex flex-col gap-1">
    <a routerLink="/dashboard" routerLinkActive="active"
      class="flex items-center gap-3 rounded-xl px-4 py-3 text-sm font-medium
        hover:bg-background transition-colors
        [&.active]:bg-background [&.active]:font-semibold">
      Dashboard
    </a>
  </nav>
</aside>
```

### Bottom Navigation (Flutter mobile)
```dart
NavigationBar(
  backgroundColor: AppColors.surface,
  indicatorColor: AppColors.accent,
  labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
  destinations: const [
    NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
    NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
    NavigationDestination(icon: Icon(Icons.calendar_today_outlined), label: 'Calendrier'),
    NavigationDestination(icon: Icon(Icons.check_box_outlined), label: 'Tâches'),
  ],
)
```

---

## 8. Règles UX communes

- **États de chargement** : skeleton animé (Angular) ou shimmer (Flutter) — jamais un spinner seul sur toute la page.
- **États vides** : toujours afficher un message illustré quand une liste est vide.
- **États d'erreur** : afficher un message inline en couleur `destructive`, jamais dans la console uniquement.
- **Feedback actions destructives** : toute suppression nécessite une confirmation (Dialog).
- **Accessibilité** :
  - Contraste WCAG AA (4.5:1) respecté par la palette.
  - `aria-label` sur tous les boutons icône (Angular) / `Semantics` (Flutter).
  - Zones tactiles minimum : 44×44px.

---

## 9. Checklist avant PR

- [ ] Les couleurs utilisées sont exclusivement celles des tokens section 2
- [ ] Toutes les cartes ont un border-radius ≥ 24px et une soft shadow (pas de border visible)
- [ ] La police Inter est chargée en weight 400/500/600/700/800
- [ ] Les titres principaux utilisent ExtraBold (800)
- [ ] Le Vert Lime `#D4FF3F` est utilisé uniquement pour l'accent (bouton principal, succès)
- [ ] Le Violet Pastel `#C4B5FD` est utilisé uniquement pour les graphiques
- [ ] Sur mobile, le Bento Grid est remplacé par un scroll vertical
- [ ] Chaque liste vide a un état illustré
- [ ] Chaque action destructive a une confirmation
- [ ] Les zones tactiles font au minimum 44×44px
- [ ] Le commit est en français et atomique

