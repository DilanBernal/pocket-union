import 'package:flutter/material.dart';
import 'package:pocket_union/ui/screens/auth/login_screen.dart';
import 'package:pocket_union/ui/screens/auth/register_screen.dart';
import 'package:pocket_union/ui/screens/categories_screen.dart';
import 'package:pocket_union/ui/screens/history_expenses_screen.dart';
import 'package:pocket_union/ui/screens/history_income_screen.dart';
import 'package:pocket_union/ui/screens/home_screen.dart';
import 'package:pocket_union/ui/screens/missions_screen.dart';
import 'package:pocket_union/ui/screens/settings_screen.dart';
import 'package:pocket_union/ui/screens/start/start_screen.dart';

class AppRoutes {
  static const String start = '/';
  static const String home = '/home';
  static const String register = '/register';
  static const String login = '/login';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String historyExpenses = '/history-expenses';
  static const String historyIncome = '/history-income';
  static const String missions = '/missions';
  static const String categories = '/categories';

  static Map<String, WidgetBuilder> routes = {
    start: (context) => const StartScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const HomeScreen(),
    settings: (context) => const SettingsScreen(),
    historyExpenses: (context) => const HistoryExpensesScreen(),
    historyIncome: (context) => const HistoryIncomeScreen(),
    missions: (context) => const MissionsScreen(),
    categories: (context) => const CategoriesScreen(),
  };
}
