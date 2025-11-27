import 'package:flutter_test/flutter_test.dart';
import 'package:controle_gasto/models/category.dart';
import 'package:flutter/material.dart';

void main() {
  group('Category Model Tests', () {
    test('Category should be created with all properties', () {
      final category = Category(
        id: 'test_id',
        name: 'Teste',
        icon: Icons.star,
        color: Colors.blue,
      );

      expect(category.id, 'test_id');
      expect(category.name, 'Teste');
      expect(category.icon, Icons.star);
      expect(category.color, Colors.blue);
    });

    test('defaultCategories should have at least 7 categories', () {
      expect(Category.defaultCategories.length, greaterThanOrEqualTo(7));
    });

    test('defaultCategories should have unique IDs', () {
      final ids = Category.defaultCategories.map((c) => c.id).toList();
      final uniqueIds = ids.toSet();
      expect(ids.length, uniqueIds.length);
    });

    test('defaultCategories should include alimentacao', () {
      final alimentacao = Category.defaultCategories
          .firstWhere((c) => c.id == 'alimentacao');
      expect(alimentacao.name, 'Alimentação');
      expect(alimentacao.icon, Icons.restaurant);
    });

    test('defaultCategories should include outros', () {
      final outros = Category.defaultCategories
          .firstWhere((c) => c.id == 'outros');
      expect(outros.name, 'Outros');
      expect(outros.icon, Icons.more_horiz);
    });

    test('all categories should have non-empty names', () {
      for (final category in Category.defaultCategories) {
        expect(category.name.isNotEmpty, true);
        expect(category.id.isNotEmpty, true);
      }
    });
  });
}
