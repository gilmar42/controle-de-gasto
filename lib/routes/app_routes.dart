import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/add_expense_screen.dart';
import '../screens/expense_list_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/profile_screen.dart';
import '../providers/auth_provider.dart';

class AppRoutes {
  static const String home = '/';
  static const String addExpense = '/add-expense';
  static const String expenseList = '/expense-list';
  static const String reports = '/reports';
  static const String editExpense = '/edit-expense';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';

  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: home,
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isAuthRoute = state.uri.path == login || state.uri.path == register;

        if (!isAuthenticated && !isAuthRoute) {
          return login;
        }

        if (isAuthenticated && isAuthRoute) {
          return home;
        }

        return null;
      },
      refreshListenable: authProvider,
      routes: [
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: addExpense,
        name: 'addExpense',
        builder: (context, state) => const AddExpenseScreen(),
      ),
      GoRoute(
        path: expenseList,
        name: 'expenseList',
        builder: (context, state) => const ExpenseListScreen(),
      ),
      GoRoute(
        path: reports,
        name: 'reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '$editExpense/:id',
        name: 'editExpense',
        builder: (context, state) {
          final expenseId = state.pathParameters['id']!;
          return AddExpenseScreen(expenseId: expenseId);
        },
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Página não encontrada: ${state.uri}'),
      ),
    ),
    );
  }
}
