import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../routes/app_routes.dart';

class IncomeListScreen extends StatelessWidget {
  const IncomeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receitas'),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          final incomes = provider.incomeTransactions;
          if (incomes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 100, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('Nenhuma receita registrada', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                ],
              ),
            );
          }

          // Agrupar por data
          final grouped = <String, List<Transaction>>{};
          for (var t in incomes) {
            final key = DateFormat('yyyy-MM-dd').format(t.date);
            grouped.putIfAbsent(key, () => []).add(t);
          }
          final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final dateKey = dates[index];
              final dayItems = grouped[dateKey]!;
              final date = DateTime.parse(dateKey);
              final total = dayItems.fold<double>(0, (sum, t) => sum + t.amount);

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
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        Text(
                          NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(total),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  ...dayItems.map((t) {
                    final category = Category.defaultCategories.firstWhere(
                      (c) => c.id == t.category,
                      orElse: () => Category.defaultCategories.last,
                    );
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Dismissible(
                        key: Key(t.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Confirmar exclusão'),
                              content: Text('Deseja realmente excluir "${t.title}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) async {
                          try {
                            await provider.deleteTransaction(t.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${t.title} excluído!'),
                                  backgroundColor: Colors.green,
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
                          child: const Icon(Icons.delete, color: Colors.white, size: 30),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.shade100,
                            child: Icon(Icons.arrow_upward, color: Colors.green.shade700),
                          ),
                          title: Text(t.title),
                          subtitle: Row(
                            children: [
                              Icon(category.icon, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(category.name),
                              if (t.description != null) ...[
                                const Text(' • '),
                                Expanded(
                                  child: Text(
                                    t.description!,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: Text(
                            NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(t.amount),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                          onTap: () {
                            // Navigate to edit screen
                            context.push('${AppRoutes.editExpense}/${t.id}');
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
        onPressed: () => context.push(AppRoutes.addIncome),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
