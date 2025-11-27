import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/expense.dart';

class ExpenseProvider with ChangeNotifier {
  final List<Transaction> _transactions = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  List<Transaction> get transactions => [..._transactions];
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  // CRUD: READ - Carregar dados do SharedPreferences
  Future<void> loadTransactions() async {
    if (_isInitialized) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? transactionsJson = prefs.getString('transactions');

      if (transactionsJson != null) {
        final List<dynamic> decoded = json.decode(transactionsJson);
        _transactions.clear();
        _transactions.addAll(
          decoded.map((item) => Transaction.fromMap(item)).toList(),
        );
      } else {
        // Dados de exemplo apenas na primeira vez
        _loadSampleData();
        await _saveTransactions();
      }
    } catch (e) {
      debugPrint('Erro ao carregar transações: $e');
    }

    _isLoading = false;
    _isInitialized = true;
    notifyListeners();
  }

  // Salvar no SharedPreferences
  Future<void> _saveTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(
        _transactions.map((t) => t.toMap()).toList(),
      );
      await prefs.setString('transactions', encoded);
    } catch (e) {
      debugPrint('Erro ao salvar transações: $e');
    }
  }

  void _loadSampleData() {
    _transactions.addAll([
      Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Salário',
        amount: 5000.0,
        type: TransactionType.income,
        category: 'outros',
        date: DateTime.now(),
        description: 'Salário do mês',
      ),
      Transaction(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        title: 'Freelance',
        amount: 1500.0,
        type: TransactionType.income,
        category: 'outros',
        date: DateTime.now().subtract(const Duration(days: 2)),
        description: 'Projeto freelance',
      ),
      Transaction(
        id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
        title: 'Supermercado',
        amount: 800.0,
        type: TransactionType.expense,
        category: 'alimentacao',
        date: DateTime.now().subtract(const Duration(days: 1)),
        description: 'Compras do mês',
      ),
      Transaction(
        id: (DateTime.now().millisecondsSinceEpoch + 3).toString(),
        title: 'Aluguel',
        amount: 1200.0,
        type: TransactionType.expense,
        category: 'moradia',
        date: DateTime.now().subtract(const Duration(days: 3)),
        description: 'Aluguel mensal',
      ),
      Transaction(
        id: (DateTime.now().millisecondsSinceEpoch + 4).toString(),
        title: 'Gasolina',
        amount: 300.0,
        type: TransactionType.expense,
        category: 'transporte',
        date: DateTime.now(),
        description: 'Combustível',
      ),
    ]);
  }

  // FR03: Cálculo de Receita Total
  double get totalIncome {
    return _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  // FR04: Cálculo de Despesa Total
  double get totalExpenses {
    return _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  // FR05: Cálculo de Lucro Líquido
  double get netProfit {
    return totalIncome - totalExpenses;
  }

  // FR06: Cálculo de Margem de Lucro
  double get profitMargin {
    if (totalIncome == 0) return 0.0;
    return (netProfit / totalIncome) * 100;
  }

  // FR02: Filtrar transações por mês
  List<Transaction> getTransactionsByMonth(DateTime month) {
    return _transactions.where((transaction) {
      return transaction.date.year == month.year &&
          transaction.date.month == month.month;
    }).toList();
  }

  double getIncomeByMonth(DateTime month) {
    return getTransactionsByMonth(month)
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getExpensesByMonth(DateTime month) {
    return getTransactionsByMonth(month)
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getNetProfitByMonth(DateTime month) {
    return getIncomeByMonth(month) - getExpensesByMonth(month);
  }

  double getProfitMarginByMonth(DateTime month) {
    final income = getIncomeByMonth(month);
    if (income == 0) return 0.0;
    return (getNetProfitByMonth(month) / income) * 100;
  }

  Map<String, double> getExpensesByCategory() {
    Map<String, double> categoryTotals = {};
    
    for (var transaction in _transactions.where((t) => t.type == TransactionType.expense)) {
      if (categoryTotals.containsKey(transaction.category)) {
        categoryTotals[transaction.category] = 
            categoryTotals[transaction.category]! + transaction.amount;
      } else {
        categoryTotals[transaction.category] = transaction.amount;
      }
    }
    
    return categoryTotals;
  }

  // CRUD: CREATE - Adicionar transação
  Future<void> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
    await _saveTransactions();
    notifyListeners();
  }

  // CRUD: UPDATE - Atualizar transação
  Future<void> updateTransaction(String id, Transaction newTransaction) async {
    final index = _transactions.indexWhere((transaction) => transaction.id == id);
    if (index != -1) {
      _transactions[index] = newTransaction;
      await _saveTransactions();
      notifyListeners();
    }
  }

  // CRUD: DELETE - Excluir transação
  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((transaction) => transaction.id == id);
    await _saveTransactions();
    notifyListeners();
  }

  // CRUD: READ - Buscar transação por ID
  Transaction? getTransactionById(String id) {
    try {
      return _transactions.firstWhere((transaction) => transaction.id == id);
    } catch (e) {
      return null;
    }
  }

  // Limpar todos os dados
  Future<void> clearAllData() async {
    _transactions.clear();
    await _saveTransactions();
    notifyListeners();
  }

  // Exportar dados como JSON
  String exportToJson() {
    return json.encode(_transactions.map((t) => t.toMap()).toList());
  }

  // Importar dados de JSON
  Future<void> importFromJson(String jsonData) async {
    try {
      final List<dynamic> decoded = json.decode(jsonData);
      _transactions.clear();
      _transactions.addAll(
        decoded.map((item) => Transaction.fromMap(item)).toList(),
      );
      await _saveTransactions();
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao importar dados: $e');
      rethrow;
    }
  }
}
