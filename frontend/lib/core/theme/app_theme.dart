import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Korean Kids App Color Palette - Soft Pastels (Light)
  static const Color primaryPink = Color(0xFFFFB7C5);
  static const Color primaryMint = Color(0xFFB5EAD7);
  static const Color primaryLavender = Color(0xFFE2F0CB);
  static const Color primarySky = Color(0xFF95C8F3);
  static const Color primaryCoral = Color(0xFFFFB7B2);
  static const Color primaryPurple = Color(0xFFC4B5FD);

  // Dark mode colors - softer for kids' eyes at night
  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color darkSurface = Color(0xFF16213E);
  static const Color darkCard = Color(0xFF1F2937);
  static const Color darkPrimaryPink = Color(0xFFFF8FA3);
  static const Color darkPrimaryMint = Color(0xFF7DD3C0);
  static const Color darkPrimarySky = Color(0xFF60A5FA);
  static const Color darkPrimaryCoral = Color(0xFFFF9AA2);
  static const Color darkPrimaryPurple = Color(0xFFA78BFA);

  // Background colors (Light)
  static const Color backgroundCream = Color(0xFFFFF9F0);
  static const Color backgroundSoft = Color(0xFFF5F5F5);

  // Text colors (Light)
  static const Color textDark = Color(0xFF2D3436);
  static const Color textMedium = Color(0xFF636E72);
  static const Color textLight = Color(0xFFB2BEC3);

  // Text colors (Dark)
  static const Color darkTextLight = Color(0xFFF8FAFC);
  static const Color darkTextMedium = Color(0xFFCBD5E1);
  static const Color darkTextMuted = Color(0xFF94A3B8);

  // Korean-style rounded shapes
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 20.0;
  static const double radiusLarge = 28.0;
  static const double radiusXLarge = 36.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundCream,
      colorScheme: const ColorScheme.light(
        primary: primaryPink,
        secondary: primaryMint,
        surface: Colors.white,
        surfaceTint: backgroundCream,
        onPrimary: Colors.white,
        onSecondary: textDark,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
        ),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
          backgroundColor: primaryPink,
          foregroundColor: Colors.white,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: backgroundCream,
        titleTextStyle: GoogleFonts.notoSansKr(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primaryPink, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimaryPink,
        secondary: darkPrimaryMint,
        surface: darkSurface,
        surfaceTint: darkBackground,
        onPrimary: Colors.white,
        onSecondary: darkTextLight,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        color: darkCard,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
          backgroundColor: darkPrimaryPink,
          foregroundColor: Colors.white,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: darkBackground,
        titleTextStyle: GoogleFonts.notoSansKr(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: darkTextLight,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: darkPrimaryPink, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  // Text styles with Korean fonts (adapt to theme) - Kids-friendly larger sizes
  static TextStyle headingLarge(BuildContext context) => GoogleFonts.notoSansKr(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).brightness == Brightness.dark
            ? darkTextLight
            : textDark,
        height: 1.3,
      );

  static TextStyle headingMedium(BuildContext context) => GoogleFonts.notoSansKr(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).brightness == Brightness.dark
            ? darkTextLight
            : textDark,
        height: 1.3,
      );

  static TextStyle bodyLarge(BuildContext context) => GoogleFonts.notoSansKr(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).brightness == Brightness.dark
            ? darkTextLight
            : textDark,
        height: 1.6,
      );

  static TextStyle bodyMedium(BuildContext context) => GoogleFonts.notoSansKr(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).brightness == Brightness.dark
            ? darkTextMedium
            : textMedium,
        height: 1.5,
      );

  static TextStyle caption(BuildContext context) => GoogleFonts.notoSansKr(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).brightness == Brightness.dark
            ? darkTextMuted
            : textLight,
      );

  static TextStyle storyTitle(BuildContext context) => GoogleFonts.notoSansKr(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).brightness == Brightness.dark
            ? darkTextLight
            : textDark,
        height: 1.4,
      );

  static TextStyle storyContent(BuildContext context) => GoogleFonts.notoSansKr(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).brightness == Brightness.dark
            ? darkTextLight
            : textDark,
        height: 2.0,
        letterSpacing: 0.5,
      );

  // Helper to get colors based on theme
  static Color backgroundColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkBackground
          : backgroundCream;

  static Color surfaceColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkCard
          : Colors.white;

  static Color primaryColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkPrimaryPink
          : primaryPink;

  static Color textColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkTextLight
          : textDark;

  static Color textMutedColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkTextMuted
          : textLight;
}
