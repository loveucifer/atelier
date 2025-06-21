import 'package:flutter/material.dart';

class AppTheme {
  // Using a standard, clean font like Poppins.
  static const String _fontFamily = 'Poppins'; 

  // --- New Color Palette for Light Theme ---
  static const Color primaryColor = Color(0xFF000000);       // Black for main text, buttons, icons
  static const Color scaffoldBackgroundColor = Color(0xFFFFFFFF); // Pure white for backgrounds
  static const Color secondaryTextColor = Color(0xFF6B6B6B); // Grey for subtitles and hints
  static const Color textFieldFillColor = Color(0xFFF3F3F3);   // Light grey for input backgrounds
  static const Color borderColor = Color(0xFFEAEAEA);         // Subtle border color

  // --- Main Light Theme Definition ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: _fontFamily,
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: primaryColor,
      background: scaffoldBackgroundColor,
      surface: Colors.white,
      onPrimary: Colors.white,   // Text on top of primary color (e.g., inside black buttons)
      onSecondary: Colors.black,
      onBackground: Colors.black,
      onSurface: Colors.black,
      error: Colors.redAccent,
    ),
    
    // --- AppBar Theme ---
    appBarTheme: const AppBarTheme(
      backgroundColor: scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0, // Prevents color change on scroll
      iconTheme: IconThemeData(color: primaryColor),
      titleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        color: primaryColor,
        fontSize: 18,
        fontWeight: FontWeight.w600, // Semi-bold for a modern feel
      ),
    ),

    // --- ElevatedButton Theme ---
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 16
        ),
      ),
    ),

    // --- OutlinedButton Theme ---
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: borderColor),
         shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
         padding: const EdgeInsets.symmetric(vertical: 16),
         textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.bold,
          fontSize: 16
        ),
      )
    ),

    // --- InputDecoration Theme for TextFields ---
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white, // White fill for a cleaner look
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      labelStyle: const TextStyle(color: secondaryTextColor),
      hintStyle: const TextStyle(fontFamily: _fontFamily, color: secondaryTextColor),
    ),

    // --- BottomNavigationBar Theme ---
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: secondaryTextColor,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );

  // You can define a dark theme here as well if needed in the future
  static final ThemeData darkTheme = ThemeData.dark();
}