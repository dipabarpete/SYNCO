import 'package:flutter/material.dart';

/// Premium SYNCO Theme Color Palette
/// Soft, feminine, elegant, pastel, luxurious.
class AppColors {
  // Primary Pastel Tones
  static const Color blushPink = Color(0xFFF8A4B8);
  static const Color blushPinkLight = Color(0xFFFFD1DC);
  static const Color babyPink = Color(0xFFFFF0F5);
  static const Color babyPinkAccent = Color(0xFFFFB6C1);
  static const Color softLavender = Color(0xFFE8DFF5);
  static const Color lavenderAccent = Color(0xFFD8B4F8);
  static const Color creamWhite = Color(0xFFFAF8F5);
  static const Color pureWhite = Color(0xFFFFFFFF);
  
  // Rich Feminine Accents
  static const Color softPurple = Color(0xFF7B4397);
  static const Color softPurpleLight = Color(0xFF9D76C1);
  static const Color rosePink = Color(0xFFE892A2);
  static const Color deepRose = Color(0xFFC94A6E);
  static const Color peachCoral = Color(0xFFFFB085);
  static const Color mintGreen = Color(0xFFB5EAD7);
  static const Color skyBlue = Color(0xFFC7CEEA);
  
  // Neutrals & Surface Colors
  static const Color textDark = Color(0xFF2D2335);
  static const Color textMedium = Color(0xFF6E617A);
  static const Color textLight = Color(0xFF9E93A8);
  static const Color lightGrey = Color(0xFFF3F4F6);
  static const Color borderGrey = Color(0xFFE5E7EB);
  static const Color shadowColor = Color(0x0F7B4397); // 6% Soft Purple Shadow
  static const Color shadowColorDark = Color(0x40000000);

  // Dark Theme Palette
  static const Color darkBackground = Color(0xFF1A1625);
  static const Color darkSurfaceCard = Color(0xFF252033);
  static const Color darkSurfaceAccent = Color(0xFF322A42);
  static const Color darkTextPrimary = Color(0xFFF3EFE0);
  static const Color darkTextSecondary = Color(0xFFB9AEC8);

  // Health Data Indicator Colors
  static const Color weightColor = Color(0xFF9D76C1);
  static const Color sleepColor = Color(0xFF7B4397);
  static const Color waterColor = Color(0xFF6495ED);
  static const Color acneColor = Color(0xFFE892A2);
  static const Color stressColor = Color(0xFFFFB085);
  static const Color sugarColor = Color(0xFFFF9AA2);
  static const Color stepsColor = Color(0xFFB5EAD7);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFF8A4B8), Color(0xFFD8B4F8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient healthCardGradient = LinearGradient(
    colors: [Color(0xFFFAF8F5), Color(0xFFFFF0F5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cycleGradient = LinearGradient(
    colors: [Color(0xFFFFF0F5), Color(0xFFE8DFF5)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF252033), Color(0xFF2D273D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
