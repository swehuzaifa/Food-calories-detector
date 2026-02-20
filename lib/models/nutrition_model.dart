class NutritionData {
  final String foodName;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;

  const NutritionData({
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  /// Generate a friendly diet suggestion based on nutrient values.
  String get suggestion {
    final buffer = StringBuffer();

    // Calorie-based suggestion
    if (calories < 200) {
      buffer.writeln('🥗 Light meal. Good for weight control.');
    } else if (calories <= 500) {
      buffer.writeln('🍽️ Balanced meal. Moderate energy intake.');
    } else {
      buffer.writeln('🔥 High calorie meal. Consider portion control.');
    }

    // Protein bonus
    if (protein > 20) {
      buffer.writeln('💪 Great protein source!');
    }

    // Fat warning
    if (fat > 25) {
      buffer.writeln('⚠️ High fat content. Eat in moderation.');
    }

    return buffer.toString().trim();
  }
}
