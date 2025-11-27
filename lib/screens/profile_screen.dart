import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _nameController.text = authProvider.currentUser?.name ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.updateProfile(_nameController.text);

    if (!mounted) return;

    if (success) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage ?? 'Erro ao atualizar'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _handleLogout() async {
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

    if (confirm == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          if (!_isEditing)
            IconButton(icon: const Icon(Icons.edit), onPressed: () => setState(() => _isEditing = true)),
          if (_isEditing)
            IconButton(icon: const Icon(Icons.close), onPressed: () {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              _nameController.text = authProvider.currentUser?.name ?? '';
              setState(() => _isEditing = false);
            }),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          if (user == null) {
            return const Center(child: Text('Usuário não autenticado'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(Icons.person, size: 60, color: Colors.blue.shade700),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            enabled: _isEditing,
                            decoration: const InputDecoration(
                              labelText: 'Nome',
                              prefixIcon: Icon(Icons.person_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return 'Nome é obrigatório';
                              if (value.trim().length < 3) return 'Nome deve ter no mínimo 3 caracteres';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: user.email,
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: DateFormat('dd/MM/yyyy').format(user.createdAt),
                            enabled: false,
                            decoration: const InputDecoration(
                              labelText: 'Membro desde',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                          ),
                          if (_isEditing) ...[
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _handleUpdate,
                              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                              child: const Text('Salvar Alterações'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _handleLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text('Sair da Conta'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
