import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class FoodDetectionService {
  static int _retryCount = 0;
  static const int _maxRetries = 2;

  /// Detect the food in the given [imageFile] using Hugging Face inference API.
  static Future<String> detectFood(File imageFile) async {
    final apiKey = dotenv.env['HUGGINGFACE_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'your_huggingface_api_key_here') {
      throw Exception('Hugging Face API key not configured. Add it to your .env file.');
    }

    final bytes = await imageFile.readAsBytes();

    // Try primary model first, then fallback
    try {
      return await _callModel(ApiConstants.huggingFaceBaseUrl, bytes, apiKey);
    } catch (e) {
      debugPrint('[FoodDetection] Primary model failed: $e');
      debugPrint('[FoodDetection] Trying fallback model...');
      return await _callModel(ApiConstants.huggingFaceFallbackUrl, bytes, apiKey);
    }
  }

  static Future<String> _callModel(String url, List<int> bytes, String apiKey) async {
    _retryCount = 0;
    return _doRequest(url, bytes, apiKey);
  }

  static Future<String> _doRequest(String url, List<int> bytes, String apiKey) async {
    debugPrint('[FoodDetection] POST $url (${bytes.length} bytes)');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/octet-stream',
      },
      body: bytes,
    );

    debugPrint('[FoodDetection] Response status: ${response.statusCode}');
    debugPrint('[FoodDetection] Response body (first 500): ${response.body.substring(0, response.body.length < 500 ? response.body.length : 500)}');

    if (response.statusCode == 503) {
      _retryCount++;
      if (_retryCount > _maxRetries) {
        throw Exception('AI model is loading. Please wait a moment and try again.');
      }
      debugPrint('[FoodDetection] Model loading, retry $_retryCount/$_maxRetries...');
      await Future.delayed(const Duration(seconds: 5));
      return _doRequest(url, bytes, apiKey);
    }

    if (response.statusCode == 401) {
      throw Exception('Invalid API key. Please check your Hugging Face API key.');
    }

    if (response.statusCode != 200) {
      throw Exception('Model returned ${response.statusCode}.');
    }

    final decoded = jsonDecode(response.body);

    List<dynamic> results;
    if (decoded is List) {
      results = decoded;
    } else if (decoded is Map && decoded.containsKey('error')) {
      throw Exception('API error: ${decoded['error']}');
    } else {
      throw Exception('Unexpected API response.');
    }

    if (results.isEmpty) {
      throw Exception('Food not recognized. Try again.');
    }

    final topResult = results[0];
    final double confidence = (topResult['score'] as num).toDouble();
    final String label = topResult['label'] as String;

    debugPrint('[FoodDetection] Detected: "$label" (confidence: ${(confidence * 100).toStringAsFixed(1)}%)');

    if (confidence < 0.30) {
      throw Exception('Food not recognized. Try again with a clearer image.');
    }

    return _cleanFoodLabel(label);
  }

  static String _cleanFoodLabel(String label) {
    return label
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ')
        .trim();
  }
}
