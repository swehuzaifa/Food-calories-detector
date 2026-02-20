// This is a basic Flutter widget test.
//
// To perform an interaction test, add the Flutter Tester library to
// your dependencies and run a test with `flutter test`.

import 'package:flutter_test/flutter_test.dart';
import 'package:food_calories_detector/main.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CalorieScannerApp());

    // Verify the app title is rendered
    expect(find.text('AI Calorie\nScanner'), findsOneWidget);
    expect(find.text('Tap to Scan'), findsOneWidget);
  });
}
