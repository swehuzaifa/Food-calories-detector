import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants.dart';
import '../services/food_detection_service.dart';
import '../services/nutrition_service.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  String _loadingMessage = '';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _setLoading(String message) {
    if (mounted) setState(() => _loadingMessage = message);
  }

  Future<void> _scanFood(ImageSource source) async {
    final picker = ImagePicker();

    try {
      final XFile? photo = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 95,
      );

      if (photo == null) return;

      setState(() {
        _isLoading = true;
        _loadingMessage = 'Preparing image...';
      });

      final imageFile = File(photo.path);

      // Step 1: Detect food
      _setLoading('🤖 Detecting food...\n(First scan may take ~30s)');
      final foodName = await FoodDetectionService.detectFood(imageFile)
          .timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw Exception(
            'Request timed out. The AI model may be loading — try again in a few seconds.'),
      );

      // Step 2: Fetch nutrition
      _setLoading('🔍 Fetching nutrition data...');
      final nutritionData = await NutritionService.fetchNutrition(foodName)
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () =>
            throw Exception('Nutrition lookup timed out. Try again.'),
      );

      if (!mounted) return;

      // Step 3: Navigate to result
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            imageFile: imageFile,
            nutritionData: nutritionData,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMessage = '';
        });
      }
    }
  }

  void _showSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Choose Image Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _sourceOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(ctx);
                      _scanFood(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _sourceOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(ctx);
                      _scanFood(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.softYellow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryYellow.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: AppColors.primaryYellow),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: AppColors.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background decoration
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryYellow.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              left: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.softYellow.withValues(alpha: 0.6),
                ),
              ),
            ),

            // Main content
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // App icon
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppColors.softYellow,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryYellow.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.restaurant_rounded,
                        size: 44,
                        color: AppColors.primaryYellow,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Title
                    const Text(
                      'AI Food',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkText,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      'Scan your meal instantly',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.greyText.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Camera button
                    ScaleTransition(
                      scale: _isLoading
                          ? const AlwaysStoppedAnimation(1.0)
                          : _pulseAnimation,
                      child: GestureDetector(
                        onTap: _isLoading ? null : _showSourcePicker,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFFC107),
                                Color(0xFFFFD54F),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryYellow
                                    .withValues(alpha: 0.45),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: _isLoading
                              ? const Center(
                                  child: SizedBox(
                                    width: 36,
                                    height: 36,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              AppColors.white),
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 48,
                                  color: AppColors.white,
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Loading message or scan label
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _isLoading
                          ? Text(
                              _loadingMessage,
                              key: ValueKey(_loadingMessage),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.greyText,
                              ),
                            )
                          : const Text(
                              'Tap to Scan',
                              key: ValueKey('tap'),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkText,
                              ),
                            ),
                    ),

                    const Spacer(flex: 3),

                    // Bottom hint
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: AppColors.greyText.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Use camera or upload from gallery',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.greyText.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
