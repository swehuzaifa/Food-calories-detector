import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/nutrition_model.dart';

class NutritionService {
  /// Fetch nutrition data for the given [foodName] from USDA FoodData Central.
  /// Returns a [NutritionData] object.
  /// Throws [Exception] if no results are found.
  static Future<NutritionData> fetchNutrition(String foodName) async {
    final apiKey = dotenv.env['USDA_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'your_usda_api_key_here') {
      throw Exception('USDA API key not configured. Add it to your .env file.');
    }

    final uri = Uri.parse(ApiConstants.usdaBaseUrl).replace(
      queryParameters: {
        'query': foodName,
        'pageSize': '1',
        'api_key': apiKey,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch nutrition data. Try again.');
    }

    final data = jsonDecode(response.body);
    final foods = data['foods'] as List<dynamic>?;

    if (foods == null || foods.isEmpty) {
      throw Exception('Nutrition data not found for "$foodName".');
    }

    final food = foods[0];
    final nutrients = food['foodNutrients'] as List<dynamic>? ?? [];

    double calories = 0;
    double protein = 0;
    double fat = 0;
    double carbs = 0;

    for (final nutrient in nutrients) {
      final name = (nutrient['nutrientName'] as String? ?? '').toLowerCase();
      final value = (nutrient['value'] as num?)?.toDouble() ?? 0;

      if (name.contains('energy')) {
        calories = value;
      } else if (name.contains('protein')) {
        protein = value;
      } else if (name.contains('total lipid') || name.contains('fat')) {
        fat = value;
      } else if (name.contains('carbohydrate')) {
        carbs = value;
      }
    }

    return NutritionData(
      foodName: foodName,
      calories: calories,
      protein: protein,
      fat: fat,
      carbs: carbs,
    );
  }
}
