import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/expense_provider.dart';
import 'providers/auth_provider.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ExpenseProvider _expenseProvider;
  late final AuthProvider _authProvider;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _expenseProvider = ExpenseProvider();
    _authProvider = AuthProvider();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _authProvider.initialize();
    await _expenseProvider.loadTransactions();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tela de carregamento inicial
    if (!_isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                Text(
                  'Carregando dados...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // App principal após carregamento
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _expenseProvider),
      ],
      child: MaterialApp.router(
        title: 'Controle de Gastos',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
          ),
        ),
        routerConfig: AppRoutes.createRouter(_authProvider),
      ),
    );
  }
}
