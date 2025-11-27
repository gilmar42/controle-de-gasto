import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../providers/expense_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  final String? expenseId;

  const AddExpenseScreen({super.key, this.expenseId});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // FR01: Tipo de transação (Receita ou Despesa)
  TransactionType _selectedType = TransactionType.expense;
  String _selectedCategory = 'alimentacao';
  DateTime _selectedDate = DateTime.now();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.expenseId != null) {
      _isEditing = true;
      _loadExpense();
    }
  }

  void _loadExpense() {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final transaction = provider.getTransactionById(widget.expenseId!);
    
    if (transaction != null) {
      _titleController.text = transaction.title;
      _amountController.text = transaction.amount.toString();
      _descriptionController.text = transaction.description ?? '';
      _selectedType = transaction.type;
      _selectedCategory = transaction.category;
      _selectedDate = transaction.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      
      final transaction = Transaction(
        id: _isEditing ? widget.expenseId! : DateTime.now().toString(),
        title: _titleController.text,
        amount: double.parse(_amountController.text.replaceAll(',', '.')),
        type: _selectedType,
        category: _selectedCategory,
        date: _selectedDate,
        description: _descriptionController.text.isEmpty 
            ? null 
            : _descriptionController.text,
      );

      // Mostrar indicador de carregamento
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        if (_isEditing) {
          await provider.updateTransaction(widget.expenseId!, transaction);
          if (mounted) {
            Navigator.of(context).pop(); // Fechar diálogo
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Transação atualizada com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          await provider.addTransaction(transaction);
          if (mounted) {
            Navigator.of(context).pop(); // Fechar diálogo
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Transação adicionada com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }

        if (mounted) {
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // Fechar diálogo
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Transação' : 'Adicionar Transação'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Confirmar exclusão'),
                    content: const Text('Deseja realmente excluir esta transação?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          Provider.of<ExpenseProvider>(context, listen: false)
                              .deleteTransaction(widget.expenseId!);
                          Navigator.pop(ctx);
                          context.pop();
                        },
                        child: const Text('Excluir'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // FR01: Seletor de Tipo de Transação
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Receita'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Despesa'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<TransactionType> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Título',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.title),
                  suffixIcon: _titleController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Limpar',
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() => _titleController.clear());
                          },
                        ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Valor',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.attach_money),
                  prefixText: 'R\$ ',
                  suffixIcon: _amountController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Limpar',
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() => _amountController.clear());
                          },
                        ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um valor';
                  }
                  if (double.tryParse(value.replaceAll(',', '.')) == null) {
                    return 'Insira um valor válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: Category.defaultCategories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Row(
                      children: [
                        Icon(category.icon, color: category.color, size: 20),
                        const SizedBox(width: 12),
                        Text(category.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(_selectedDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descrição (opcional)',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description),
                  suffixIcon: _descriptionController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Limpar',
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() => _descriptionController.clear());
                          },
                        ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _isEditing ? 'Atualizar Transação' : 'Adicionar Transação',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
