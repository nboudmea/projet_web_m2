import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Thème Material 3 complet — miroir du design system Angular / Tailwind.
abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          surface: AppColors.surface,
          onSurface: AppColors.foreground,
          primary: AppColors.primary,
          onPrimary: AppColors.primaryForeground,
          secondary: AppColors.accent,
          onSecondary: AppColors.accentForeground,
          error: AppColors.destructive,
          onError: AppColors.destructiveForeground,
          outline: AppColors.border,
        ),
        textTheme: _buildTextTheme(),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.primaryForeground,
            elevation: 0,
            shape: const StadiumBorder(),
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            textStyle: GoogleFonts.inter(
                fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.primaryForeground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            textStyle: GoogleFonts.inter(
                fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.foreground,
            textStyle: GoogleFonts.inter(
                fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.input),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.input),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.ring, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.destructive),
          ),
          labelStyle: GoogleFonts.inter(
              color: AppColors.mutedForeground, fontSize: 14),
          hintStyle: GoogleFonts.inter(
              color: AppColors.mutedForeground, fontSize: 14),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.foreground,          // #111111 — miroir sidebar Angular
          indicatorColor: Colors.white.withAlpha(25),      // rgba(255,255,255,.10)
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.accent); // lime actif
            }
            return const IconThemeData(
                color: Color(0x8CFFFFFF)); // rgba(255,255,255,.55)
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final base = GoogleFonts.inter(fontSize: 12);
            if (states.contains(WidgetState.selected)) {
              return base.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white);
            }
            return base.copyWith(color: const Color(0x8CFFFFFF));
          }),
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
          space: 0,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surface,
          selectedColor: AppColors.foreground,
          labelStyle:
              GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999)),
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.foreground,
          contentTextStyle: GoogleFonts.inter(
              color: AppColors.primaryForeground, fontSize: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.foreground,    // #111111 — miroir sidebar Angular
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: Colors.white,
          ),
          iconTheme:
              const IconThemeData(color: Colors.white),
          actionsIconTheme:
              const IconThemeData(color: Color(0x8CFFFFFF)), // rgba(255,255,255,.55)
        ),
      );

  static TextTheme _buildTextTheme() {
    return TextTheme(
      // 48px ExtraBold — grands titres affichage
      displayLarge: GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        height: 1.1,
        color: AppColors.foreground,
      ),
      // 30px ExtraBold
      headlineLarge: GoogleFonts.inter(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        height: 1.1,
        color: AppColors.foreground,
      ),
      // 24px ExtraBold — section titles
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
        height: 1.1,
        color: AppColors.foreground,
      ),
      // 20px Bold
      headlineSmall: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.foreground,
      ),
      // 18px SemiBold
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.foreground,
      ),
      // 16px Medium
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.foreground,
      ),
      // 14px Medium
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.foreground,
      ),
      // 16px Normal
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.foreground,
      ),
      // 14px Normal
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.foreground,
      ),
      // 12px Normal
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.mutedForeground,
      ),
      // 12px Medium — labels, badges
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.foreground,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.mutedForeground,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.mutedForeground,
      ),
    );
  }
}
