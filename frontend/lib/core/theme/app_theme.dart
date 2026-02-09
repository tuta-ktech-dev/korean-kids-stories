import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Korean Kids App Color Palette - Soft Pastels
  static const Color primaryPink = Color(0xFFFFB7C5);      // 핑크 - hồng nhạt
  static const Color primaryMint = Color(0xFFB5EAD7);      // 민트 - xanh mint
  static const Color primaryLavender = Color(0xFFE2F0CB);  // 라벤더 - vàng nhạt
  static const Color primarySky = Color(0xFF95C8F3);       // 하늘 - xanh da trờ
  static const Color primaryCoral = Color(0xFFFFB7B2);     // 코랄 - cam san hô

  // Background colors
  static const Color backgroundCream = Color(0xFFFFF9F0);  // Kem nhạt
  static const Color backgroundSoft = Color(0xFFF5F5F5);   // Xám nhạt

  // Text colors
  static const Color textDark = Color(0xFF2D3436);
  static const Color textMedium = Color(0xFF636E72);
  static const Color textLight = Color(0xFFB2BEC3);

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
        background: backgroundCream,
        onPrimary: Colors.white,
        onSecondary: textDark,
      ),
      // Korean apps love rounded everything
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
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
      // Soft app bar
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: backgroundCream,
        titleTextStyle: GoogleFonts.notoSansKr(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
      ),
      // Rounded inputs
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

  // Text styles with Korean fonts
  static TextStyle get headingLarge => GoogleFonts.gmarketSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textDark,
        height: 1.3,
      );

  static TextStyle get headingMedium => GoogleFonts.gmarketSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textDark,
        height: 1.3,
      );

  static TextStyle get bodyLarge => GoogleFonts.notoSansKr(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textDark,
        height: 1.6,
      );

  static TextStyle get bodyMedium => GoogleFonts.notoSansKr(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textMedium,
        height: 1.5,
      );

  static TextStyle get caption => GoogleFonts.notoSansKr(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textLight,
      );

  // Korean children's book style - rounded, friendly
  static TextStyle get storyTitle => GoogleFonts.cafe24Ssurround(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textDark,
        height: 1.4,
      );

  static TextStyle get storyContent => GoogleFonts.notoSansKr(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: textDark,
        height: 2.0,
        letterSpacing: 0.5,
      );
}
