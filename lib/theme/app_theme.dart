import 'package:flutter/material.dart';

class AppTheme {
  // Main colors
  static const Color primaryColor = Color(0xFF006282);
  static const Color highlightColor = Color(0xFF822000);
  static const Color accentColor = Color(0xFFFFC300);
  static const Color statDisplayColor = Color(0xCCCCCC);

  // Common border styles
  static BoxDecoration defaultBorder = BoxDecoration(
    border: Border.all(color: primaryColor, width: 2),
    borderRadius: BorderRadius.circular(8),
  );

  static BoxDecoration selectedBorder = BoxDecoration(
    border: Border.all(color: accentColor, width: 2),
    color: highlightColor,
    borderRadius: BorderRadius.circular(8),
  );

  // Common button styles
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static ButtonStyle selectedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: highlightColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: accentColor, width: 2),
    ),
  );

  // Common text styles
  static const TextStyle titleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: primaryColor,
  );

  // Common input decoration
  static InputDecoration inputDecoration = InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: primaryColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: highlightColor, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: primaryColor),
    ),
  );

  // Complete theme data
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: highlightColor,
        tertiary: accentColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: titleStyle,
        iconTheme: IconThemeData(color: primaryColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: primaryButtonStyle,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: highlightColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor),
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: titleStyle,
        titleMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
        bodyLarge: bodyStyle,
        bodyMedium: TextStyle(
          fontSize: 14,
          color: primaryColor,
        ),
      ),
    );
  }

  // Common widget styles
  static BoxDecoration get cardDecoration => defaultBorder;
  
  static BoxDecoration get selectedCardDecoration => selectedBorder;
  
  static BoxDecoration get circularDecoration => BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(color: primaryColor, width: 2),
  );
} 