import 'package:flutter_test/flutter_test.dart';
import 'package:controle_gasto/providers/expense_provider.dart';
import 'package:controle_gasto/models/expense.dart';

void main() {
  group('ExpenseProvider Tests', () {
    late ExpenseProvider provider;

    setUp(() {
      provider = ExpenseProvider();
    });

    test('should start with empty transactions', () {
      expect(provider.transactions, isEmpty);
    });

    test('should calculate totalIncome correctly', () async {
      await provider.addTransaction(Transaction(
        id: '1',
        title: 'Salário',
        amount: 5000.0,
        type: TransactionType.income,
        category: 'salario',
        date: DateTime.now(),
      ));

      await provider.addTransaction(Transaction(
        id: '2',
        title: 'Freelance',
        amount: 1500.0,
        type: TransactionType.income,
        category: 'freelance',
        date: DateTime.now(),
      ));

      expect(provider.totalIncome, 6500.0);
    });

    test('should calculate totalExpenses correctly', () async {
      await provider.addTransaction(Transaction(
        id: '1',
        title: 'Aluguel',
        amount: 1200.0,
        type: TransactionType.expense,
        category: 'moradia',
        date: DateTime.now(),
      ));

      await provider.addTransaction(Transaction(
        id: '2',
        title: 'Mercado',
        amount: 500.0,
        type: TransactionType.expense,
        category: 'alimentacao',
        date: DateTime.now(),
      ));

      expect(provider.totalExpenses, 1700.0);
    });

    test('should calculate netProfit correctly', () async {
      await provider.addTransaction(Transaction(
        id: '1',
        title: 'Salário',
        amount: 5000.0,
        type: TransactionType.income,
        category: 'salario',
        date: DateTime.now(),
      ));

      await provider.addTransaction(Transaction(
        id: '2',
        title: 'Aluguel',
        amount: 1200.0,
        type: TransactionType.expense,
        category: 'moradia',
        date: DateTime.now(),
      ));

      expect(provider.netProfit, 3800.0);
    });

    test('should calculate profitMargin correctly', () async {
      await provider.addTransaction(Transaction(
        id: '1',
        title: 'Salário',
        amount: 5000.0,
        type: TransactionType.income,
        category: 'salario',
        date: DateTime.now(),
      ));

      await provider.addTransaction(Transaction(
        id: '2',
        title: 'Despesas',
        amount: 2000.0,
        type: TransactionType.expense,
        category: 'outros',
        date: DateTime.now(),
      ));

      // Margem = (netProfit / totalIncome) * 100
      // Margem = (3000 / 5000) * 100 = 60%
      expect(provider.profitMargin, 60.0);
    });

    test('profitMargin should be 0 when no income', () async {
      await provider.addTransaction(Transaction(
        id: '1',
        title: 'Despesa',
        amount: 100.0,
        type: TransactionType.expense,
        category: 'outros',
        date: DateTime.now(),
      ));

      expect(provider.profitMargin, 0.0);
    });

    test('should add transaction', () async {
      final transaction = Transaction(
        id: '1',
        title: 'Teste',
        amount: 100.0,
        type: TransactionType.expense,
        category: 'outros',
        date: DateTime.now(),
      );

      await provider.addTransaction(transaction);

      expect(provider.transactions.length, 1);
      expect(provider.transactions.first.title, 'Teste');
    });

    test('should update transaction', () async {
      final transaction = Transaction(
        id: '1',
        title: 'Original',
        amount: 100.0,
        type: TransactionType.expense,
        category: 'outros',
        date: DateTime.now(),
      );

      await provider.addTransaction(transaction);

      final updated = transaction.copyWith(title: 'Atualizado', amount: 200.0);
      await provider.updateTransaction('1', updated);

      expect(provider.transactions.first.title, 'Atualizado');
      expect(provider.transactions.first.amount, 200.0);
    });

    test('should delete transaction', () async {
      await provider.addTransaction(Transaction(
        id: '1',
        title: 'Teste',
        amount: 100.0,
        type: TransactionType.expense,
        category: 'outros',
        date: DateTime.now(),
      ));

      expect(provider.transactions.length, 1);

      await provider.deleteTransaction('1');

      expect(provider.transactions.length, 0);
    });

    test('should get transaction by ID', () async {
      final transaction = Transaction(
        id: 'test_id',
        title: 'Teste',
        amount: 100.0,
        type: TransactionType.expense,
        category: 'outros',
        date: DateTime.now(),
      );

      await provider.addTransaction(transaction);

      final found = provider.getTransactionById('test_id');

      expect(found, isNotNull);
      expect(found?.title, 'Teste');
    });

    test('should return null for non-existent transaction ID', () {
      final found = provider.getTransactionById('non_existent');
      expect(found, isNull);
    });

    test('should filter transactions by month', () async {
      final january = DateTime(2024, 1, 15);
      final february = DateTime(2024, 2, 15);

      await provider.addTransaction(Transaction(
        id: '1',
        title: 'Janeiro',
        amount: 100.0,
        type: TransactionType.expense,
        category: 'outros',
        date: january,
      ));

      await provider.addTransaction(Transaction(
        id: '2',
        title: 'Fevereiro',
        amount: 200.0,
        type: TransactionType.expense,
        category: 'outros',
        date: february,
      ));

      final januaryTransactions = provider.getTransactionsByMonth(january);

      expect(januaryTransactions.length, 1);
      expect(januaryTransactions.first.title, 'Janeiro');
    });

    test('should clear all data', () async {
      await provider.addTransaction(Transaction(
        id: '1',
        title: 'Teste',
        amount: 100.0,
        type: TransactionType.expense,
        category: 'outros',
        date: DateTime.now(),
      ));

      expect(provider.transactions.length, 1);

      await provider.clearAllData();

      expect(provider.transactions.length, 0);
    });
  });
}
