import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  // Keys para SharedPreferences
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyCurrentUser = 'current_user';
  static const String _keyUsers = 'users';
  static const String _keyPasswords = 'passwords';

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Inicializa o provider e restaura sessão se existir
  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;

      if (isLoggedIn) {
        final userJson = prefs.getString(_keyCurrentUser);
        if (userJson != null) {
          _currentUser = User.fromJson(jsonDecode(userJson));
        }
      }
    } catch (e) {
      _errorMessage = 'Erro ao restaurar sessão: $e';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      // Validações básicas
      if (name.trim().isEmpty) {
        _errorMessage = 'Nome é obrigatório';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (email.trim().isEmpty || !_isValidEmail(email)) {
        _errorMessage = 'Email inválido';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (password.length < 6) {
        _errorMessage = 'Senha deve ter no mínimo 6 caracteres';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final prefs = await SharedPreferences.getInstance();

      // Verifica se email já existe
      final usersJson = prefs.getString(_keyUsers);
      final Map<String, dynamic> users = usersJson != null 
          ? Map<String, dynamic>.from(jsonDecode(usersJson))
          : {};

      if (users.containsKey(email)) {
        _errorMessage = 'Email já cadastrado';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Cria novo usuário
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.trim(),
        email: email.trim().toLowerCase(),
        createdAt: DateTime.now(),
      );

      // Salva usuário e senha (em produção, use hash!)
      users[email] = newUser.toJson();
      await prefs.setString(_keyUsers, jsonEncode(users));

      final passwordsJson = prefs.getString(_keyPasswords);
      final Map<String, dynamic> passwords = passwordsJson != null
          ? Map<String, dynamic>.from(jsonDecode(passwordsJson))
          : {};
      passwords[email] = password; // Em produção: hash(password)
      await prefs.setString(_keyPasswords, jsonEncode(passwords));

      // Faz login automático
      _currentUser = newUser;
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyCurrentUser, jsonEncode(newUser.toJson()));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao registrar: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      if (email.trim().isEmpty || password.isEmpty) {
        _errorMessage = 'Email e senha são obrigatórios';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final prefs = await SharedPreferences.getInstance();

      // Busca usuário
      final usersJson = prefs.getString(_keyUsers);
      if (usersJson == null) {
        _errorMessage = 'Usuário não encontrado';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final Map<String, dynamic> users = 
          Map<String, dynamic>.from(jsonDecode(usersJson));
      final emailKey = email.trim().toLowerCase();

      if (!users.containsKey(emailKey)) {
        _errorMessage = 'Usuário não encontrado';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Verifica senha
      final passwordsJson = prefs.getString(_keyPasswords);
      final Map<String, dynamic> passwords = 
          Map<String, dynamic>.from(jsonDecode(passwordsJson!));

      if (passwords[emailKey] != password) {
        _errorMessage = 'Senha incorreta';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Login bem-sucedido
      _currentUser = User.fromJson(users[emailKey]);
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyCurrentUser, jsonEncode(_currentUser!.toJson()));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao fazer login: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, false);
      await prefs.remove(_keyCurrentUser);
      
      _currentUser = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao fazer logout: $e';
      debugPrint(_errorMessage);
      notifyListeners();
    }
  }

  Future<bool> updateProfile(String name) async {
    try {
      if (_currentUser == null) return false;

      if (name.trim().isEmpty) {
        _errorMessage = 'Nome é obrigatório';
        notifyListeners();
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final updatedUser = _currentUser!.copyWith(name: name.trim());

      // Atualiza na lista de usuários
      final usersJson = prefs.getString(_keyUsers);
      final Map<String, dynamic> users = 
          Map<String, dynamic>.from(jsonDecode(usersJson!));
      users[updatedUser.email] = updatedUser.toJson();
      await prefs.setString(_keyUsers, jsonEncode(users));

      // Atualiza usuário atual
      _currentUser = updatedUser;
      await prefs.setString(_keyCurrentUser, jsonEncode(updatedUser.toJson()));

      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao atualizar perfil: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyCurrentUser);
    await prefs.remove(_keyUsers);
    await prefs.remove(_keyPasswords);
    
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }
}
