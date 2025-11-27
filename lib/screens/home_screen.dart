import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';
import '../models/expense.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Financeiro Pessoal'),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(
                user?.name.substring(0, 1).toUpperCase() ?? 'U',
                style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold),
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'header',
                enabled: false,
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.name ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(user?.email ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'profile',
                child: const Row(
                  children: [Icon(Icons.account_circle), SizedBox(width: 8), Text('Perfil')],
                ),
                onTap: () => Future.delayed(Duration.zero, () => context.push(AppRoutes.profile)),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: const Row(
                  children: [Icon(Icons.logout, color: Colors.red), SizedBox(width: 8), Text('Sair', style: TextStyle(color: Colors.red))],
                ),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Sair'),
                      content: const Text('Deseja realmente sair?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Sair', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    await authProvider.logout();
                    if (context.mounted) context.go(AppRoutes.login);
                  }
                },
              ),
            ],
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          // FR03, FR04, FR05, FR06: Métricas financeiras
          final totalIncome = expenseProvider.totalIncome;
          final totalExpenses = expenseProvider.totalExpenses;
          final netProfit = expenseProvider.netProfit;
          final profitMargin = expenseProvider.profitMargin;
          final recentTransactions = expenseProvider.transactions
              .take(5)
              .toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FR05: Card de Lucro Líquido (US04: cor baseada no saldo)
                InkWell(
                  onTap: () => context.push(AppRoutes.expenseList),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: netProfit > 0
                            ? [Colors.green.shade400, Colors.green.shade700]
                            : netProfit < 0
                                ? [Colors.red.shade400, Colors.red.shade700]
                                : [Colors.grey.shade400, Colors.grey.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (netProfit > 0 ? Colors.green : Colors.red)
                              .withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Lucro Líquido',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            Icon(
                              Icons.touch_app,
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          NumberFormat.currency(
                            locale: 'pt_BR',
                            symbol: 'R\$',
                          ).format(netProfit),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // FR06: Margem de Lucro
                        Text(
                          'Margem: ${profitMargin.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Toque para ver detalhes',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // FR03 e FR04: Cards de Receita e Despesa
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Card(
                          color: Colors.green.shade50,
                          child: InkWell(
                            onTap: () => context.push(AppRoutes.addIncome),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.arrow_upward,
                                              color: Colors.green.shade700),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Receitas',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.green.shade700,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    NumberFormat.currency(
                                      locale: 'pt_BR',
                                      symbol: 'R\$',
                                    ).format(totalIncome),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Toque para adicionar receita',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.green.shade600.withValues(alpha: 0.7),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Card(
                          color: Colors.red.shade50,
                          child: InkWell(
                            onTap: () => context.push(AppRoutes.addExpense),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.arrow_downward,
                                              color: Colors.red.shade700),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Despesas',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.red.shade700,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    NumberFormat.currency(
                                      locale: 'pt_BR',
                                      symbol: 'R\$',
                                    ).format(totalExpenses),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Toque para adicionar despesa',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.red.shade600.withValues(alpha: 0.7),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Menu de Ações
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _MenuCard(
                          icon: Icons.add_circle_outline,
                          title: 'Adicionar',
                          color: Colors.green,
                          onTap: () => context.push(AppRoutes.addExpense),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MenuCard(
                          icon: Icons.list_alt,
                          title: 'Listar',
                          color: Colors.orange,
                          onTap: () => context.push(AppRoutes.expenseList),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MenuCard(
                          icon: Icons.bar_chart,
                          title: 'Relatórios',
                          color: Colors.purple,
                          onTap: () => context.push(AppRoutes.reports),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MenuCard(
                          icon: Icons.arrow_upward,
                          title: 'Receitas',
                          color: Colors.green.shade700,
                          onTap: () => context.push(AppRoutes.incomeList),
                        ),
                      ),
                    ],
                  ),
                ),

                // FR07: Transações Recentes
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Transações Recentes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                if (recentTransactions.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'Nenhuma transação registrada ainda',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: recentTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = recentTransactions[index];
                      final isIncome = transaction.type == TransactionType.income;
                      return Dismissible(
                        key: Key(transaction.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Excluir transação'),
                              content: Text('Deseja excluir "${transaction.title}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
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
                          try {
                            await Provider.of<ExpenseProvider>(context, listen: false)
                                .deleteTransaction(transaction.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('"${transaction.title}" excluída'),
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
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            onTap: () => context.push(
                              '${AppRoutes.editExpense}/${transaction.id}',
                            ),
                            leading: CircleAvatar(
                              backgroundColor: isIncome
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                              child: Icon(
                                isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                                color: isIncome
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                            ),
                            title: Text(transaction.title),
                            subtitle: Text(
                              DateFormat('dd/MM/yyyy').format(transaction.date),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  NumberFormat.currency(
                                    locale: 'pt_BR',
                                    symbol: 'R\$',
                                  ).format(transaction.amount),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isIncome ? Colors.green : Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: Colors.grey.shade600,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
