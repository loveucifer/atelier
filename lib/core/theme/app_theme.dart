import 'package:flutter/material.dart';

class AppTheme {
  // New, deeper color palette
  static const Color primaryRed = Color(0xFFC62828); // A deeper, richer red
  static const Color pitchBlack = Color(0xFF000000); // True pitch black

  // --- DARK THEME ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: pitchBlack, // Use pitch black for the base
    primaryColor: primaryRed,
    colorScheme: const ColorScheme.dark(
      primary: primaryRed,
      secondary: primaryRed,
      background: pitchBlack,
      surface: Color(0xFF1A1A1A), // A very dark grey for card-like surfaces
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Colors.white,
      onSurface: Colors.white,
      error: Colors.redAccent,
    ),
     appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent, // Make AppBar transparent to see the gradient
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: pitchBlack.withOpacity(0.8), // Semi-transparent for a glass effect
      selectedItemColor: primaryRed,
      unselectedItemColor: Colors.grey[600],
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[900]?.withOpacity(0.7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: Colors.grey[600]),
    ),
  );

  // --- LIGHT THEME (can be adjusted later if needed) ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: primaryRed,
    colorScheme: const ColorScheme.light(
      primary: primaryRed,
      secondary: primaryRed,
      background: Colors.white,
    ),
  );
}