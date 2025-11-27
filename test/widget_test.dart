import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:controle_gasto/main.dart';

void main() {
  testWidgets('App should start and show loading', (WidgetTester tester) async {
    // Build app and trigger frame
    await tester.pumpWidget(const MyApp());
    
    // Should show loading initially
    expect(find.text('Carregando dados...'), findsOneWidget);
  });

  testWidgets('App basic smoke test', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const MyApp());
    
    // Verify app starts without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
