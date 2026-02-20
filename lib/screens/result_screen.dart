import 'dart:io';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/nutrition_model.dart';
import '../widgets/nutrition_card.dart';
import '../widgets/primary_button.dart';

class ResultScreen extends StatelessWidget {
  final File imageFile;
  final NutritionData nutritionData;

  const ResultScreen({
    super.key,
    required this.imageFile,
    required this.nutritionData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Scan Result',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ─── Food Image ───────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(
                  imageFile,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 20),

              // ─── Food Name ────────────────────────────
              Text(
                nutritionData.foodName,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // ─── Calorie Badge ────────────────────────
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFC107), Color(0xFFFFD54F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryYellow.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Calories',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${nutritionData.calories.toStringAsFixed(0)} kcal',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── Macronutrient Cards ──────────────────
              NutritionCard(
                label: 'Protein',
                value: '${nutritionData.protein.toStringAsFixed(1)} g',
                icon: Icons.fitness_center_rounded,
                iconColor: const Color(0xFF43A047),
              ),
              const SizedBox(height: 12),
              NutritionCard(
                label: 'Carbohydrates',
                value: '${nutritionData.carbs.toStringAsFixed(1)} g',
                icon: Icons.grain_rounded,
                iconColor: const Color(0xFFFF9800),
              ),
              const SizedBox(height: 12),
              NutritionCard(
                label: 'Fat',
                value: '${nutritionData.fat.toStringAsFixed(1)} g',
                icon: Icons.water_drop_rounded,
                iconColor: const Color(0xFFE53935),
              ),

              const SizedBox(height: 24),

              // ─── Suggestion Card ──────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.softYellow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryYellow.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb_rounded,
                            color: AppColors.primaryYellow, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Health Insight',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      nutritionData.suggestion,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ─── Scan Again Button ────────────────────
              PrimaryButton(
                label: 'Scan Again',
                icon: Icons.camera_alt_rounded,
                width: double.infinity,
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
