import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/expense_provider.dart';
import '../models/category.dart';
import '../models/expense.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  // FR02: Seleção de Período (mês e ano)
  DateTime _selectedMonth = DateTime.now();
  bool _localeInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('pt_BR', null);
    setState(() {
      _localeInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_localeInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Relatórios')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedMonth,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDatePickerMode: DatePickerMode.year,
              );
              if (picked != null) {
                setState(() {
                  _selectedMonth = picked;
                });
              }
            },
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          // FR02, FR03, FR04, FR05, FR06: Métricas do mês selecionado
          final monthTransactions = expenseProvider.getTransactionsByMonth(_selectedMonth);
          final totalIncome = expenseProvider.getIncomeByMonth(_selectedMonth);
          final totalExpenses = expenseProvider.getExpensesByMonth(_selectedMonth);
          final netProfit = expenseProvider.getNetProfitByMonth(_selectedMonth);
          final profitMargin = expenseProvider.getProfitMarginByMonth(_selectedMonth);
          
          final categoryTotals = <String, double>{};
          
          for (var transaction in monthTransactions.where((t) => t.type == TransactionType.expense)) {
            categoryTotals[transaction.category] = 
                (categoryTotals[transaction.category] ?? 0) + transaction.amount;
          }

          if (monthTransactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 100,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sem dados para este período',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FR02: Período selecionado
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('MMMM yyyy', 'pt_BR').format(_selectedMonth),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 24),
                        // FR03 e FR04: Receitas e Despesas
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  const Icon(Icons.arrow_upward, color: Colors.green),
                                  const Text('Receitas', style: TextStyle(fontSize: 12)),
                                  Text(
                                    NumberFormat.currency(
                                      locale: 'pt_BR',
                                      symbol: 'R\$',
                                    ).format(totalIncome),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(width: 1, height: 40, color: Colors.grey.shade300),
                            Expanded(
                              child: Column(
                                children: [
                                  const Icon(Icons.arrow_downward, color: Colors.red),
                                  const Text('Despesas', style: TextStyle(fontSize: 12)),
                                  Text(
                                    NumberFormat.currency(
                                      locale: 'pt_BR',
                                      symbol: 'R\$',
                                    ).format(totalExpenses),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        // FR05: Lucro Líquido (US04: cor baseada no saldo)
                        Text(
                          'Lucro Líquido',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          NumberFormat.currency(
                            locale: 'pt_BR',
                            symbol: 'R\$',
                          ).format(netProfit),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: netProfit > 0
                                ? Colors.green
                                : netProfit < 0
                                    ? Colors.red
                                    : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // FR06: Margem de Lucro
                        Text(
                          'Margem: ${profitMargin.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Gráfico de Pizza - Despesas por Categoria
                if (categoryTotals.isNotEmpty) ...[
                  const Text(
                    'Despesas por Categoria',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sections: categoryTotals.entries.map((entry) {
                          final category = Category.defaultCategories.firstWhere(
                            (cat) => cat.id == entry.key,
                            orElse: () => Category.defaultCategories.last,
                          );
                          final percentage = (entry.value / totalExpenses) * 100;

                        return PieChartSectionData(
                          value: entry.value,
                          title: '${percentage.toStringAsFixed(1)}%',
                          color: category.color,
                          radius: 100,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                  // Lista de categorias
                  const Text(
                    'Detalhamento por Categoria',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  ...categoryTotals.entries.map((entry) {
                    final category = Category.defaultCategories.firstWhere(
                      (cat) => cat.id == entry.key,
                      orElse: () => Category.defaultCategories.last,
                    );
                    final percentage = (entry.value / totalExpenses) * 100;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: category.color.withValues(alpha: 0.2),
                        child: Icon(category.icon, color: category.color),
                      ),
                      title: Text(category.name),
                      subtitle: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(category.color),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            NumberFormat.currency(
                              locale: 'pt_BR',
                              symbol: 'R\$',
                            ).format(entry.value),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                  }),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
