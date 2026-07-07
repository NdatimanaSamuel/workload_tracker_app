import 'package:flutter/material.dart';

// This class just holds color values as constants, so every screen
// uses the SAME colors instead of you retyping hex codes everywhere.
// If you ever want to change your app's look, you only edit this ONE file.
class AppColors {
  // Deep charcoal background — modern, easy on the eyes, works well
  // for both web and mobile without feeling too "dark mode harsh"
  static const Color background = Color(0xFF1C1C1E);

  // A calm teal-green as your main accent color — feels academic/institutional
  // without being the exact ULK green (so it reads as its own product)
  static const Color primary = Color(0xFF0F6E56);
  static const Color primaryLight = Color(0xFF1D9E75);

  // Card surfaces sit slightly lighter than the background so they "lift" visually
  static const Color surface = Color(0xFF2C2C2E);

  // Text colors — white isn't pure white (too harsh), it's a soft off-white
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFA0A0A0);
}