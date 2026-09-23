import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sub_tracker/core/theme/widgets/app_background.dart';

void main() {
  group('AppBackground Widget Tests', () {
    testWidgets('renders child content in Light theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const AppBackground(child: Text('Test Child Light')),
        ),
      );

      expect(find.text('Test Child Light'), findsOneWidget);
    });

    testWidgets('renders child content in Dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const AppBackground(child: Text('Test Child Dark')),
        ),
      );

      expect(find.text('Test Child Dark'), findsOneWidget);
    });
  });
}
