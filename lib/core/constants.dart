import 'package:flutter/material.dart';

// ─── Colors ─────────────────────────────────────────────
class AppColors {
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color softYellow = Color(0xFFFFF8E1);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF333333);

  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color greyText = Color(0xFF757575);
  
  static const Color errorRed = Color(0xFFE53935);
  static const Color successGreen = Color(0xFF43A047);
}

// ─── API ────────────────────────────────────────────────
class ApiConstants {
  static const String huggingFaceBaseUrl =
      'https://router.huggingface.co/hf-inference/models/nateraw/food';

  // Fallback if primary model is unavailable
  static const String huggingFaceFallbackUrl =
      'https://router.huggingface.co/hf-inference/models/Rajaram1996/FoodNet';

  static const String usdaBaseUrl =
      'https://api.nal.usda.gov/fdc/v1/foods/search';
}

// ─── Suggestion thresholds ──────────────────────────────
class SuggestionThresholds {
  static const double lowCalories = 200;
  static const double highCalories = 500;
  static const double highProtein = 20;
  static const double highFat = 25;
}
