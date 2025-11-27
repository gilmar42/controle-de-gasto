import 'package:flutter_test/flutter_test.dart';
import 'package:controle_gasto/models/expense.dart';

void main() {
  group('Transaction Model Tests', () {
    test('Transaction should be created with all properties', () {
      final transaction = Transaction(
        id: '1',
        title: 'Salário',
        amount: 5000.0,
        type: TransactionType.income,
        category: 'salario',
        date: DateTime(2024, 1, 15),
        description: 'Salário mensal',
      );

      expect(transaction.id, '1');
      expect(transaction.title, 'Salário');
      expect(transaction.amount, 5000.0);
      expect(transaction.type, TransactionType.income);
      expect(transaction.category, 'salario');
      expect(transaction.date, DateTime(2024, 1, 15));
      expect(transaction.description, 'Salário mensal');
    });

    test('Transaction should serialize to Map correctly', () {
      final transaction = Transaction(
        id: '1',
        title: 'Conta de Luz',
        amount: 150.0,
        type: TransactionType.expense,
        category: 'contas',
        date: DateTime(2024, 1, 16),
      );

      final map = transaction.toMap();

      expect(map['id'], '1');
      expect(map['title'], 'Conta de Luz');
      expect(map['amount'], 150.0);
      expect(map['type'], 'expense');
      expect(map['category'], 'contas');
      expect(map['date'], DateTime(2024, 1, 16).toIso8601String());
      expect(map['description'], null);
    });

    test('Transaction should deserialize from Map correctly', () {
      final map = {
        'id': '2',
        'title': 'Freelance',
        'amount': 1500.0,
        'type': 'income',
        'category': 'freelance',
        'date': DateTime(2024, 1, 20).toIso8601String(),
        'description': 'Projeto web',
      };

      final transaction = Transaction.fromMap(map);

      expect(transaction.id, '2');
      expect(transaction.title, 'Freelance');
      expect(transaction.amount, 1500.0);
      expect(transaction.type, TransactionType.income);
      expect(transaction.category, 'freelance');
      expect(transaction.description, 'Projeto web');
    });

    test('Transaction copyWith should update only specified fields', () {
      final original = Transaction(
        id: '1',
        title: 'Original',
        amount: 100.0,
        type: TransactionType.expense,
        category: 'alimentacao',
        date: DateTime(2024, 1, 1),
      );

      final updated = original.copyWith(
        title: 'Atualizado',
        amount: 200.0,
      );

      expect(updated.id, '1');
      expect(updated.title, 'Atualizado');
      expect(updated.amount, 200.0);
      expect(updated.type, TransactionType.expense);
      expect(updated.category, 'alimentacao');
    });

    test('TransactionType should have correct values', () {
      expect(TransactionType.income.toString(), 'TransactionType.income');
      expect(TransactionType.expense.toString(), 'TransactionType.expense');
    });
  });
}
