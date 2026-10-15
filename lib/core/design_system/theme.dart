// Qalculyn - Design System
// Defines all design tokens: colors, typography, spacing, animations, etc.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QColors {
  // Primary palette
  static const primaryPurple = Color(0xFF7C3AED);
  static const primaryPurpleLight = Color(0xFF8B5CF6);
  static const primaryPurpleDark = Color(0xFF6D28D9);
  static const accentLavender = Color(0xFFB794F6);
  static const accentViolet = Color(0xFFA78BFA);

  // Dark theme surfaces
  static const darkBackground = Color(0xFF0F0B1A);
  static const darkSurface = Color(0xFF1A1428);
  static const darkSurfaceVariant = Color(0xFF241D35);
  static const darkCard = Color(0xFF1E1730);
  static const darkElevated = Color(0xFF2A2240);

  // Light theme surfaces
  static const lightBackground = Color(0xFFF8F6FF);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFF0ECFA);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightElevated = Color(0xFFF5F2FF);

  // Text colors
  static const darkTextPrimary = Color(0xFFF0ECFA);
  static const darkTextSecondary = Color(0xFFB8B0CC);
  static const darkTextTertiary = Color(0xFF7A7290);
  static const lightTextPrimary = Color(0xFF1A1428);
  static const lightTextSecondary = Color(0xFF5A5270);
  static const lightTextTertiary = Color(0xFF8A8298);

  // Functional
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // Button colors (dark)
  static const darkNumberButton = Color(0xFF241D38);
  static const darkOperatorButton = Color(0xFF2D2248);
  static const darkFunctionButton = Color(0xFF1E1730);
  static const darkEqualsButton = Color(0xFF7C3AED);

  // Button colors (light)
  static const lightNumberButton = Color(0xFFFFFFFF);
  static const lightOperatorButton = Color(0xFFF0ECFA);
  static const lightFunctionButton = Color(0xFFE8E4F5);
  static const lightEqualsButton = Color(0xFF7C3AED);

  // Operator text colors
  static const operatorColor = Color(0xFF8B5CF6);

  // Divider
  static const darkDivider = Color(0xFF2A2240);
  static const lightDivider = Color(0xFFE0DCF0);
}

class QSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;
}

class QRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double full = 100;

  static final borderRadiusSm = BorderRadius.circular(sm);
  static final borderRadiusMd = BorderRadius.circular(md);
  static final borderRadiusLg = BorderRadius.circular(lg);
  static final borderRadiusXl = BorderRadius.circular(xl);
  static final borderRadiusXxl = BorderRadius.circular(xxl);
  static final borderRadiusFull = BorderRadius.circular(full);
}

class QDurations {
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);
  static const sheet = Duration(milliseconds: 350);
}

class QCurves {
  static const standard = Curves.easeInOut;
  static const enter = Curves.easeOut;
  static const exit = Curves.easeIn;
  static const bounce = Curves.elasticOut;
  static const decelerate = Curves.decelerate;
}

class QElevation {
  static const none = 0.0;
  static const sm = 2.0;
  static const md = 4.0;
  static const lg = 8.0;
  static const xl = 16.0;
}

class QTypography {
  static TextStyle displayLarge(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.w300,
        letterSpacing: -1.5,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle displayMedium(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle displaySmall(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle headlineLarge(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle headlineMedium(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle titleLarge(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle titleMedium(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle bodyLarge(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle bodyMedium(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle bodySmall(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );

  static TextStyle labelLarge(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle labelSmall(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );

  // Calculator-specific
  static TextStyle calcExpression(BuildContext context) =>
      GoogleFonts.jetBrainsMono(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );

  static TextStyle calcResult(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: 52,
        fontWeight: FontWeight.w300,
        letterSpacing: -2,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle calcButton(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle calcOperator(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: 26,
        fontWeight: FontWeight.w500,
        color: QColors.primaryPurple,
      );

  static TextStyle calcScientific(BuildContext context) =>
      GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );
}

class QTheme {
  static ThemeData light({Color? accentColor}) {
    final primary = accentColor ?? QColors.primaryPurple;
    final colorScheme = ColorScheme.light(
      primary: primary,
      primaryContainer: primary.withValues(alpha: 0.15),
      secondary: primary,
      secondaryContainer: primary.withValues(alpha: 0.12),
      surface: QColors.lightSurface,
      onSurface: QColors.lightTextPrimary,
      onSurfaceVariant: QColors.lightTextSecondary,
      error: QColors.error,
      outline: QColors.lightDivider,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: QColors.lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: QColors.lightBackground,
        foregroundColor: QColors.lightTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: QColors.lightTextPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: QColors.lightCard,
        elevation: QElevation.sm,
        shape: RoundedRectangleBorder(borderRadius: QRadius.borderRadiusLg),
        margin: const EdgeInsets.symmetric(horizontal: QSpacing.lg, vertical: QSpacing.sm),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: QColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(QRadius.xxl)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: QColors.lightDivider,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(color: QColors.lightTextSecondary),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? primary : QColors.lightTextTertiary),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? primary.withValues(alpha: 0.5)
                : QColors.lightDivider),
      ),
    );
  }

  static ThemeData dark({Color? accentColor, bool amoledBlack = false}) {
    final primary = accentColor ?? QColors.primaryPurple;
    final bg = amoledBlack ? Colors.black : QColors.darkBackground;
    final surface = amoledBlack ? const Color(0xFF0C0C0C) : QColors.darkSurface;
    final card = amoledBlack ? const Color(0xFF141414) : QColors.darkCard;

    final colorScheme = ColorScheme.dark(
      primary: primary,
      primaryContainer: primary.withValues(alpha: 0.25),
      secondary: primary,
      secondaryContainer: primary.withValues(alpha: 0.18),
      surface: surface,
      onSurface: QColors.darkTextPrimary,
      onSurfaceVariant: QColors.darkTextSecondary,
      error: QColors.error,
      outline: amoledBlack ? const Color(0xFF222222) : QColors.darkDivider,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: QColors.darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: QColors.darkTextPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: QElevation.none,
        shape: RoundedRectangleBorder(borderRadius: QRadius.borderRadiusLg),
        margin: const EdgeInsets.symmetric(horizontal: QSpacing.lg, vertical: QSpacing.sm),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(QRadius.xxl)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: amoledBlack ? const Color(0xFF222222) : QColors.darkDivider,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(color: QColors.darkTextSecondary),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? primary : QColors.darkTextTertiary),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? primary.withValues(alpha: 0.5)
                : (amoledBlack ? const Color(0xFF222222) : QColors.darkDivider)),
      ),
    );
  }
}
