import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Master Design Tokens (White + Light Blue + Dark Navy Palette)
  static const Color backgroundColor = Color(0xFFFFFFFF);     // Pure White Base
  static const Color backgroundWhite = Color(0xFFFFFFFF);     // Alias
  static const Color cardColor = Color(0xFFF8FBFF);           // Surface Card Background
  static const Color softBlue = Color(0xFFF0F7FF);            // Soft Blue Background
  static const Color softBlueBackground = Color(0xFFF0F7FF);  // Alias
  static const Color primaryColor = Color(0xFF0A84FF);        // Primary Blue Action
  static const Color primaryBlue = Color(0xFF0A84FF);         // Alias
  static const Color deepBlue = Color(0xFF0874E8);            // Hover / Active Blue
  static const Color hoverBlue = Color(0xFF0874E8);           // Alias
  static const Color lightBlue = Color(0xFFEAF4FF);           // Tag & Badge Fill
  static const Color textPrimary = Color(0xFF0B1F33);         // Dark Navy Text
  static const Color navyDark = Color(0xFF0B1F33);            // Alias
  static const Color textSecondary = Color(0xFF5B6B7A);       // Slate Body Text
  static const Color navyMuted = Color(0xFF5B6B7A);           // Alias
  static const Color borderColor = Color(0xFFE4EDF5);         // Crisp Container Border
  static const Color borderLight = Color(0xFFE4EDF5);         // Alias
  static const Color hoverColor = Color(0xFFF2F8FF);          // Table/Card Hover State
  static const Color successColor = Color(0xFF10B981);        // Professional Green
  static const Color dangerColor = Color(0xFFEF4444);         // Professional Red
  static const Color warningColor = Color(0xFFF59E0B);        // Amber Warning

  // Border Radius Tokens
  static final BorderRadius radiusSm = BorderRadius.circular(8);
  static final BorderRadius radiusMd = BorderRadius.circular(12);
  static final BorderRadius radiusLg = BorderRadius.circular(16);

  // Shadows
  static final BoxShadow softShadow = BoxShadow(
    color: const Color(0xFF0B1F33).withValues(alpha: 0.04),
    blurRadius: 16,
    offset: const Offset(0, 4),
  );

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      dividerColor: borderColor,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          elevation: 0,
          side: const BorderSide(color: borderColor, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        hintStyle: GoogleFonts.inter(color: textSecondary, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: textSecondary, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: const BorderSide(color: borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: const BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: const BorderSide(color: dangerColor, width: 1.5),
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: deepBlue,
        surface: cardColor,
        error: dangerColor,
      ),
    );
  }

  static ThemeData get darkTheme {
    const darkBg = Color(0xFF0F172A);
    const darkCard = Color(0xFF1E293B);
    const darkBorder = Color(0xFF334155);
    const darkTextPrimary = Color(0xFFF8FAFC);
    const darkTextSecondary = Color(0xFF94A3B8);

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBg,
      cardColor: darkCard,
      dividerColor: darkBorder,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: darkTextPrimary,
        displayColor: darkTextPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: darkTextPrimary),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkTextPrimary,
          elevation: 0,
          side: const BorderSide(color: darkBorder, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        hintStyle: GoogleFonts.inter(color: darkTextSecondary, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: darkTextSecondary, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: const BorderSide(color: darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: const BorderSide(color: darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: const BorderSide(color: dangerColor, width: 1.5),
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: deepBlue,
        surface: darkCard,
        error: dangerColor,
      ),
    );
  }
}

