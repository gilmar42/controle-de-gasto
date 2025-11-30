import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../providers/expense_provider.dart';

class AddIncomeScreen extends StatefulWidget {
  final String? incomeId;

  const AddIncomeScreen({super.key, this.incomeId});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'salario';
  String? _selectedSubcategory; // Subopções quando categoria for "outros"
  DateTime _selectedDate = DateTime.now();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.incomeId != null) {
      _isEditing = true;
      _loadIncome();
    }
    // Listeners para atualizar UI quando texto muda
    _titleController.addListener(() => setState(() {}));
    _amountController.addListener(() => setState(() {}));
    _descriptionController.addListener(() => setState(() {}));
  }

  void _loadIncome() {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final transaction = provider.getTransactionById(widget.incomeId!);

    if (transaction != null && transaction.type == TransactionType.income) {
      _titleController.text = transaction.title;
      _amountController.text = transaction.amount.toString();
      _descriptionController.text = transaction.description ?? '';
      // Garantir que a categoria carregada exista na lista de receitas
      final validIncomeIds = Category.incomeCategories.map((c) => c.id).toSet();
      _selectedCategory = validIncomeIds.contains(transaction.category)
          ? transaction.category
          : 'salario';
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

      // Se a categoria for "outros", salvar a subcategoria escolhida
      final String categoryToSave =
          _selectedCategory == 'outros' && _selectedSubcategory != null
              ? _selectedSubcategory!
              : _selectedCategory;

      final transaction = Transaction(
        id: _isEditing ? widget.incomeId! : DateTime.now().toString(),
        title: _titleController.text,
        amount: double.parse(_amountController.text.replaceAll(',', '.')),
        type: TransactionType.income,
        category: categoryToSave,
        date: _selectedDate,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        userId: null,
      );

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        if (_isEditing) {
          await provider.updateTransaction(widget.incomeId!, transaction);
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Receita atualizada com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          await provider.addTransaction(transaction);
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Receita adicionada com sucesso!'),
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
          Navigator.of(context).pop();
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
        title: Text(_isEditing ? 'Editar Receita' : 'Adicionar Receita'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Confirmar exclusão'),
                    content:
                        const Text('Deseja realmente excluir esta receita?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          Provider.of<ExpenseProvider>(context, listen: false)
                              .deleteTransaction(widget.incomeId!);
                          Navigator.pop(ctx);
                          context.pop();
                        },
                        child: const Text('Excluir',
                            style: TextStyle(color: Colors.red)),
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
              // Badge indicando tipo de transação
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_upward, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'RECEITA',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
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
                            _titleController.clear();
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
                            _amountController.clear();
                          },
                        ),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
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
                // Somente categorias de receita
                items: Category.incomeCategories.map((category) {
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
                    // Ao trocar a categoria, resetar subcategoria
                    if (_selectedCategory != 'outros') {
                      _selectedSubcategory = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),

              // Subopções quando "outros" estiver selecionado
              if (_selectedCategory == 'outros') ...[
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Categoria (Outros)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.list),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        title: const Text('Salário'),
                        value: 'salario',
                        groupValue: _selectedSubcategory,
                        onChanged: (val) =>
                            setState(() => _selectedSubcategory = val),
                      ),
                      RadioListTile<String>(
                        title: const Text('Freelancer'),
                        value: 'freelancer',
                        groupValue: _selectedSubcategory,
                        onChanged: (val) =>
                            setState(() => _selectedSubcategory = val),
                      ),
                      RadioListTile<String>(
                        title: const Text('Outra Receita'),
                        value: 'outra_receita',
                        groupValue: _selectedSubcategory,
                        onChanged: (val) =>
                            setState(() => _selectedSubcategory = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

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
                            _descriptionController.clear();
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
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _isEditing ? 'Atualizar Receita' : 'Adicionar Receita',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
