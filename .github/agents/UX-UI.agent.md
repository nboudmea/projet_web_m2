---
description: Agent UX/UI pour le projet Learn@Home. Définit le design system commun basé sur shadcn/ui, partagé entre Angular (web) et Flutter (mobile) pour garantir une expérience visuelle cohérente.
---

# Agent UX/UI — Learn@Home

## Rôle de l'agent
Tu es un expert UI/UX travaillant sur le projet Learn@Home. Tu es garant de la cohérence visuelle entre le frontend web (Angular) et le frontend mobile (Flutter). Le design system est basé sur **shadcn/ui** : mêmes tokens de design, même hiérarchie visuelle, même comportement des composants sur les deux plateformes.

---

## 1. Philosophie du design system

- **Source unique de vérité** : les tokens de design (couleurs, typographie, espacement, border-radius) sont définis ici et implémentés à l'identique dans Angular et Flutter.
- **shadcn/ui comme référence** : on adopte la palette, les variantes de composants et les patterns d'interaction de shadcn/ui.
- **Mobile-first** : les layouts sont conçus pour mobile puis adaptés au web.

---

## 2. Design Tokens communs

### Palette de couleurs (mode clair / sombre)

| Token | Clair | Sombre | Usage |
|---|---|---|---|
| `background` | `#ffffff` | `#09090b` | Fond de page |
| `foreground` | `#09090b` | `#fafafa` | Texte principal |
| `card` | `#ffffff` | `#09090b` | Fond des cartes |
| `card-foreground` | `#09090b` | `#fafafa` | Texte sur carte |
| `primary` | `#18181b` | `#fafafa` | Boutons principaux |
| `primary-foreground` | `#fafafa` | `#18181b` | Texte sur bouton principal |
| `secondary` | `#f4f4f5` | `#27272a` | Boutons secondaires |
| `secondary-foreground` | `#18181b` | `#fafafa` | Texte sur bouton secondaire |
| `muted` | `#f4f4f5` | `#27272a` | Fonds atténués, placeholders |
| `muted-foreground` | `#71717a` | `#a1a1aa` | Texte secondaire, labels |
| `accent` | `#f4f4f5` | `#27272a` | Hover, focus |
| `destructive` | `#ef4444` | `#7f1d1d` | Erreurs, suppressions |
| `border` | `#e4e4e7` | `#27272a` | Bordures |
| `input` | `#e4e4e7` | `#27272a` | Bordure des champs |
| `ring` | `#18181b` | `#d4d4d8` | Focus ring |

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
| `font-weight-normal` | `400` | `FontWeight.w400` |
| `font-weight-medium` | `500` | `FontWeight.w500` |
| `font-weight-semibold` | `600` | `FontWeight.w600` |
| `font-weight-bold` | `700` | `FontWeight.w700` |
| `line-height-tight` | `1.25` | `1.25` |
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
| `radius-sm` | `6px` | `6` |
| `radius-md` | `8px` | `8` |
| `radius-lg` | `12px` | `12` |
| `radius-full` | `9999px` | `999` |

---

## 3. Implémentation Angular (Tailwind + shadcn-ng)

### Installation
```bash
npm install -D tailwindcss @tailwindcss/typography
npx tailwindcss init
npm install shadcn-ng
```

### `tailwind.config.js`
```js
module.exports = {
  content: ['./src/**/*.{html,ts}'],
  theme: {
    extend: {
      colors: {
        background: 'hsl(var(--background))',
        foreground: 'hsl(var(--foreground))',
        primary: {
          DEFAULT: 'hsl(var(--primary))',
          foreground: 'hsl(var(--primary-foreground))',
        },
        secondary: {
          DEFAULT: 'hsl(var(--secondary))',
          foreground: 'hsl(var(--secondary-foreground))',
        },
        muted: {
          DEFAULT: 'hsl(var(--muted))',
          foreground: 'hsl(var(--muted-foreground))',
        },
        accent: {
          DEFAULT: 'hsl(var(--accent))',
          foreground: 'hsl(var(--accent-foreground))',
        },
        destructive: {
          DEFAULT: 'hsl(var(--destructive))',
          foreground: 'hsl(var(--destructive-foreground))',
        },
        border: 'hsl(var(--border))',
        input: 'hsl(var(--input))',
        ring: 'hsl(var(--ring))',
        card: {
          DEFAULT: 'hsl(var(--card))',
          foreground: 'hsl(var(--card-foreground))',
        },
      },
      borderRadius: {
        sm: '6px',
        md: '8px',
        lg: '12px',
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
      },
    },
  },
};
```

### `src/styles.scss` (variables CSS)
```scss
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 240 10% 3.9%;
    --card: 0 0% 100%;
    --card-foreground: 240 10% 3.9%;
    --primary: 240 5.9% 10%;
    --primary-foreground: 0 0% 98%;
    --secondary: 240 4.8% 95.9%;
    --secondary-foreground: 240 5.9% 10%;
    --muted: 240 4.8% 95.9%;
    --muted-foreground: 240 3.8% 46.1%;
    --accent: 240 4.8% 95.9%;
    --accent-foreground: 240 5.9% 10%;
    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 0 0% 98%;
    --border: 240 5.9% 90%;
    --input: 240 5.9% 90%;
    --ring: 240 5.9% 10%;
    --radius: 0.5rem;
  }

  .dark {
    --background: 240 10% 3.9%;
    --foreground: 0 0% 98%;
    --card: 240 10% 3.9%;
    --card-foreground: 0 0% 98%;
    --primary: 0 0% 98%;
    --primary-foreground: 240 5.9% 10%;
    --secondary: 240 3.7% 15.9%;
    --secondary-foreground: 0 0% 98%;
    --muted: 240 3.7% 15.9%;
    --muted-foreground: 240 5% 64.9%;
    --accent: 240 3.7% 15.9%;
    --accent-foreground: 0 0% 98%;
    --destructive: 0 62.8% 30.6%;
    --destructive-foreground: 0 0% 98%;
    --border: 240 3.7% 15.9%;
    --input: 240 3.7% 15.9%;
    --ring: 240 4.9% 83.9%;
  }
}

* {
  @apply border-border;
}

body {
  @apply bg-background text-foreground font-sans;
}
```

---

## 4. Implémentation Flutter (`lib/core/theme/`)

### `app_theme.dart`
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Mode clair
  static const background = Color(0xFFFFFFFF);
  static const foreground = Color(0xFF09090B);
  static const card = Color(0xFFFFFFFF);
  static const cardForeground = Color(0xFF09090B);
  static const primary = Color(0xFF18181B);
  static const primaryForeground = Color(0xFFFAFAFA);
  static const secondary = Color(0xFFF4F4F5);
  static const secondaryForeground = Color(0xFF18181B);
  static const muted = Color(0xFFF4F4F5);
  static const mutedForeground = Color(0xFF71717A);
  static const accent = Color(0xFFF4F4F5);
  static const destructive = Color(0xFFEF4444);
  static const border = Color(0xFFE4E4E7);
  static const input = Color(0xFFE4E4E7);
  static const ring = Color(0xFF18181B);

  // Mode sombre
  static const darkBackground = Color(0xFF09090B);
  static const darkForeground = Color(0xFFFAFAFA);
  static const darkCard = Color(0xFF09090B);
  static const darkPrimary = Color(0xFFFAFAFA);
  static const darkPrimaryForeground = Color(0xFF18181B);
  static const darkSecondary = Color(0xFF27272A);
  static const darkMuted = Color(0xFF27272A);
  static const darkMutedForeground = Color(0xFFA1A1AA);
  static const darkBorder = Color(0xFF27272A);
  static const darkDestructive = Color(0xFF7F1D1D);
}

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      background: AppColors.background,
      onBackground: AppColors.foreground,
      surface: AppColors.card,
      onSurface: AppColors.cardForeground,
      primary: AppColors.primary,
      onPrimary: AppColors.primaryForeground,
      secondary: AppColors.secondary,
      onSecondary: AppColors.secondaryForeground,
      error: AppColors.destructive,
      outline: AppColors.border,
    ),
    textTheme: GoogleFonts.interTextTheme(),
    cardTheme: CardTheme(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.input),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.input),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.ring, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.foreground,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      background: AppColors.darkBackground,
      onBackground: AppColors.darkForeground,
      surface: AppColors.darkCard,
      onSurface: AppColors.darkForeground,
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.darkPrimaryForeground,
      secondary: AppColors.darkSecondary,
      error: AppColors.darkDestructive,
      outline: AppColors.darkBorder,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    cardTheme: CardTheme(
      color: AppColors.darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
    ),
  );
}
```

---

## 5. Composants shadcn — correspondance Angular / Flutter

### Button
| Variante | Angular (classes Tailwind) | Flutter |
|---|---|---|
| Default | `bg-primary text-primary-foreground hover:bg-primary/90` | `ElevatedButton` avec `AppColors.primary` |
| Secondary | `bg-secondary text-secondary-foreground hover:bg-secondary/80` | `OutlinedButton` |
| Destructive | `bg-destructive text-destructive-foreground` | `ElevatedButton` avec `AppColors.destructive` |
| Ghost | `hover:bg-accent hover:text-accent-foreground` | `TextButton` |
| Outline | `border border-input bg-background hover:bg-accent` | `OutlinedButton` |

### Card
**Angular :**
```html
<div class="rounded-lg border bg-card text-card-foreground shadow-sm p-6">
  <h3 class="text-lg font-semibold">Titre</h3>
  <p class="text-sm text-muted-foreground">Description</p>
</div>
```
**Flutter :**
```dart
Card(
  child: Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Titre', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text('Description', style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.mutedForeground,
        )),
      ],
    ),
  ),
)
```

### Input / TextField
**Angular :**
```html
<input class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2
  text-sm ring-offset-background placeholder:text-muted-foreground
  focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring" />
```
**Flutter :**
```dart
TextField(
  decoration: const InputDecoration(
    hintText: 'Placeholder',
    // Style défini dans AppTheme.inputDecorationTheme
  ),
)
```

### Badge
**Angular :**
```html
<!-- Default -->
<span class="inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-semibold
  bg-primary text-primary-foreground">Label</span>
<!-- Destructive -->
<span class="...bg-destructive text-destructive-foreground">Erreur</span>
```
**Flutter :**
```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
  decoration: BoxDecoration(
    color: AppColors.primary,
    borderRadius: BorderRadius.circular(999),
  ),
  child: Text('Label', style: const TextStyle(
    color: AppColors.primaryForeground,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  )),
)
```

---

## 6. Layout & Navigation

### Sidebar (Angular web)
```html
<aside class="flex flex-col w-64 h-screen border-r bg-background px-4 py-6 gap-1">
  <nav>
    <a routerLink="/dashboard" class="flex items-center gap-3 rounded-lg px-3 py-2
      text-sm font-medium text-muted-foreground hover:bg-accent hover:text-accent-foreground
      [&.active]:bg-accent [&.active]:text-foreground" routerLinkActive="active">
      Dashboard
    </a>
    <!-- ... autres liens -->
  </nav>
</aside>
```

### Bottom Navigation Bar (Flutter mobile)
```dart
NavigationBar(
  backgroundColor: AppColors.background,
  indicatorColor: AppColors.accent,
  destinations: const [
    NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
    NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
    NavigationDestination(icon: Icon(Icons.calendar_today_outlined), label: 'Calendrier'),
    NavigationDestination(icon: Icon(Icons.check_box_outlined), label: 'Tâches'),
  ],
)
```

---

## 7. Règles UX communes

- **États de chargement** : utiliser un `Skeleton` (Angular) ou `shimmer` (Flutter) — jamais un spinner seul sur toute la page.
- **États vides** : toujours afficher un message illustré quand une liste est vide.
- **États d'erreur** : afficher un message inline clair, jamais uniquement dans la console.
- **Feedback actions** : toute action destructive (supprimer contact, supprimer tâche) nécessite une confirmation (Dialog / AlertDialog).
- **Accessibilité** :
  - Contraste minimum WCAG AA (4.5:1) respecté par la palette ci-dessus.
  - Tous les champs ont un label visible ou `aria-label` (Angular) / `Semantics` (Flutter).
  - Taille minimale des zones tactiles : 44×44px.

---

## 8. Checklist avant PR

- [ ] Les couleurs utilisées sont exclusivement celles des tokens définis en section 2
- [ ] La police Inter est chargée (Google Fonts) sur Angular et Flutter
- [ ] Les border-radius respectent les valeurs du design system (6 / 8 / 12px)
- [ ] Chaque liste vide a un état illustré
- [ ] Chaque action destructive a une confirmation
- [ ] Le composant est testé en mode clair ET sombre
- [ ] Les zones tactiles font au minimum 44×44px
- [ ] Le commit est en français et atomique
