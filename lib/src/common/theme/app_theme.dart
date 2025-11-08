import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AppTheme provides centralized theme configuration for the entire app
/// Supports both light and dark themes with consistent styling
class AppTheme {
  // Prevent instantiation
  AppTheme._();

  // Light theme colors
  static const _lightPrimary = Color(0xff3067FE); // Primary blue from HTML
  static const Color _lightBackground = Color(0xffF0F2F5);
  static const Color _lightSurface = Colors.white;
  static const Color _lightOnBackground = Color(0xff1C1C1E);
  static const Color _lightOnSurface = Colors.black;
  static const _lightSecondary = Color(0xff4CAF50); // Green
  static const _lightError = Color(0xffF44336);

  // Dark theme colors
  static const _darkPrimary = Color(0xff3067FE); // Primary blue from HTML
  static const _darkBackground = Color(0xff121212);
  static const _darkSurface = Color(0xff1E1E1E);
  static const Color _darkOnPrimary = Colors.white;
  static const Color _darkOnBackground = Color(0xffE1E1E1);
  static const Color _darkOnSurface = Colors.white;
  static const _darkSecondary = Color(0xff66BB6A); // Light green
  static const _darkError = Color(0xffEF5350);

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: _lightPrimary,
        secondary: _lightSecondary,
        error: _lightError,
      ),

      // Scaffold background
      scaffoldBackgroundColor: _lightBackground,

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: _lightBackground,
        foregroundColor: _lightOnBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _lightOnBackground,
        ),
        iconTheme: const IconThemeData(color: _lightOnBackground),
        actionsIconTheme: const IconThemeData(color: _lightOnBackground),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: _lightSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _lightOnBackground,
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightError, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _lightSurface,
        selectedItemColor: _lightOnSurface,
        unselectedItemColor: Colors.grey,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: _lightOnSurface,
      ),

      // Text theme
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: _lightOnBackground,
        displayColor: _lightOnBackground,
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: _lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _lightOnBackground,
        contentTextStyle: GoogleFonts.inter(color: _lightBackground),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _lightPrimary,
        foregroundColor: Colors.white,
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _lightPrimary,
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: Colors.grey[300],
        thickness: 1,
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: _darkPrimary,
        secondary: _darkSecondary,
        surface: _darkSurface,
        error: _darkError,
      ),

      // Scaffold background
      scaffoldBackgroundColor: _darkBackground,

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: _darkSurface,
        foregroundColor: _darkOnBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _darkOnBackground,
        ),
        iconTheme: const IconThemeData(color: _darkOnBackground),
        actionsIconTheme: const IconThemeData(color: _darkOnBackground),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: _darkSurface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkPrimary,
          foregroundColor: _darkOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _darkOnBackground,
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkError, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _darkSurface,
        selectedItemColor: _darkOnSurface,
        unselectedItemColor: Colors.grey,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: _darkOnSurface,
      ),

      // Text theme
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: _darkOnBackground,
        displayColor: _darkOnBackground,
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: _darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _darkOnBackground,
        contentTextStyle: GoogleFonts.inter(color: _darkBackground),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _darkPrimary,
        foregroundColor: _darkOnPrimary,
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _darkPrimary,
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: Colors.grey[700],
        thickness: 1,
      ),
    );
  }

  /// Helper method to get text color based on theme brightness
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.black
        : Colors.white;
  }

  /// Helper method to get surface color based on theme brightness
  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : const Color(0xff1E1E1E);
  }

  /// Helper method to get primary color based on theme brightness
  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? const Color(0xff3067FE)
        : const Color(0xff3067FE);
  }
}
