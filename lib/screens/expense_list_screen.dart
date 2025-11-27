import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../providers/expense_provider.dart';
import '../models/category.dart';
import '../models/expense.dart';
import '../routes/app_routes.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  String _filterCategory = 'todos';
  String _filterType = 'todos'; // Filtro por tipo: todos, receita, despesa
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
        appBar: AppBar(title: const Text('Lista de Transações')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Transações'),
        actions: [
          // Filtro por tipo
          PopupMenuButton<String>(
            icon: const Icon(Icons.swap_vert),
            onSelected: (value) {
              setState(() {
                _filterType = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'todos',
                child: Row(
                  children: [
                    Icon(Icons.list),
                    SizedBox(width: 8),
                    Text('Todos'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'receita',
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Receitas'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'despesa',
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Despesas'),
                  ],
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterCategory = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'todos',
                child: Text('Todos'),
              ),
              ...Category.defaultCategories.map((category) {
                return PopupMenuItem(
                  value: category.id,
                  child: Row(
                    children: [
                      Icon(category.icon, color: category.color, size: 20),
                      const SizedBox(width: 8),
                      Text(category.name),
                    ],
                  ),
                );
              }),
            ],
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          var transactions = expenseProvider.transactions;
          
          // Filtrar por tipo
          if (_filterType == 'receita') {
            transactions = transactions
                .where((t) => t.type == TransactionType.income)
                .toList();
          } else if (_filterType == 'despesa') {
            transactions = transactions
                .where((t) => t.type == TransactionType.expense)
                .toList();
          }
          
          // Filtrar por categoria
          if (_filterCategory != 'todos') {
            transactions = transactions
                .where((t) => t.category == _filterCategory)
                .toList();
          }

          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 100,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma transação encontrada',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          // FR07: Agrupar por data
          final groupedTransactions = <String, List<Transaction>>{};
          for (var transaction in transactions) {
            final dateKey = DateFormat('yyyy-MM-dd').format(transaction.date);
            if (!groupedTransactions.containsKey(dateKey)) {
              groupedTransactions[dateKey] = [];
            }
            groupedTransactions[dateKey]!.add(transaction);
          }

          final sortedDates = groupedTransactions.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final dateKey = sortedDates[index];
              final dayTransactions = groupedTransactions[dateKey]!;
              final date = DateTime.parse(dateKey);
              final total = dayTransactions.fold<double>(
                0,
                (sum, t) => sum + (t.type == TransactionType.income ? t.amount : -t.amount),
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('dd MMMM yyyy', 'pt_BR').format(date),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          NumberFormat.currency(
                            locale: 'pt_BR',
                            symbol: 'R\$',
                          ).format(total),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: total >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...dayTransactions.map((transaction) {
                    final category = Category.defaultCategories.firstWhere(
                      (cat) => cat.id == transaction.category,
                      orElse: () => Category.defaultCategories.last,
                    );
                    final isIncome = transaction.type == TransactionType.income;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Dismissible(
                        key: Key(transaction.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmar exclusão'),
                              content: Text(
                                'Deseja realmente excluir "${transaction.title}"?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text(
                                    'Excluir',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) async {
                          final provider = Provider.of<ExpenseProvider>(
                            context,
                            listen: false,
                          );
                          
                          try {
                            await provider.deleteTransaction(transaction.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${transaction.title} excluído!'),
                                  backgroundColor: Colors.green,
                                  action: SnackBarAction(
                                    label: 'OK',
                                    textColor: Colors.white,
                                    onPressed: () {},
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erro ao excluir: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          color: Colors.red,
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isIncome 
                                ? Colors.green.shade100 
                                : Colors.red.shade100,
                            child: Icon(
                              isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                              color: isIncome ? Colors.green.shade700 : Colors.red.shade700,
                            ),
                          ),
                          title: Text(
                            transaction.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Row(
                            children: [
                              Icon(category.icon, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(category.name),
                              if (transaction.description != null) ...[
                                const Text(' • '),
                                Expanded(
                                  child: Text(
                                    transaction.description!,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: Text(
                            NumberFormat.currency(
                              locale: 'pt_BR',
                              symbol: 'R\$',
                            ).format(transaction.amount),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isIncome ? Colors.green : Colors.red,
                            ),
                          ),
                          onTap: () {
                            context.push(
                              '${AppRoutes.editExpense}/${transaction.id}',
                            );
                          },
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addExpense),
        child: const Icon(Icons.add),
      ),
    );
  }
}
