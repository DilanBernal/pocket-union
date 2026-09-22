import 'package:flutter/material.dart';
import 'package:pocket_union/features/auth/couple/presentation/screens/couple_setup_screen.dart';
import 'package:pocket_union/features/home/screens/home_screen.dart';
import 'package:pocket_union/features/reference/category/presentation/screens/category_command_screen.dart';
import 'package:pocket_union/features/reference/category/presentation/screens/category_list_screen.dart';
import '../features/auth/login/presentation/screens/login_screen.dart';
import '../features/auth/register/presentation/screens/register_screen.dart';
// import 'package:pocket_union/ui/screens/categories/categories_list_screen.dart';
// import 'package:pocket_union/ui/screens/categories/new_category_screen.dart';
// import 'package:pocket_union/ui/screens/couple/couple_setup_screen.dart';
// import 'package:pocket_union/ui/screens/transactions/exp/expense_detail_screen.dart';
// import 'package:pocket_union/ui/screens/transactions/exp/history_expenses_screen.dart';
// import 'package:pocket_union/ui/screens/transactions/in/history_income_screen.dart';
// import 'package:pocket_union/ui/screens/transactions/in/income_detail_screen.dart';
// import 'package:pocket_union/ui/screens/transactions/recurrent/exp/history_recurrent_expense_screen.dart';
// import 'package:pocket_union/ui/screens/transactions/recurrent/exp/new_recurrent_expense_screen.dart';
// import 'package:pocket_union/ui/screens/transactions/recurrent/in/history_recurrent_income_screen.dart';
// import 'package:pocket_union/ui/screens/transactions/recurrent/in/new_recurrent_income_screen.dart';
// import 'package:pocket_union/ui/screens/home/home_screen.dart';
// import 'package:pocket_union/ui/screens/missions_screen.dart';
// import 'package:pocket_union/ui/screens/settings_screen.dart';
// import 'package:pocket_union/ui/screens/start/start_screen.dart';

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
  static const String newCategory = '/new-category';
  static const String editCategory = '/edit-category/:id';
  static const String coupleSetup = '/couple-setup';
  static const String expenseDetail = '/expense-detail';
  static const String incomeDetail = '/income-detail';
  static const String newRecurrentExpense = '/new-recurrent-expense';
  static const String newRecurrentIncome = '/new-recurrent-income';
  static const String historyRecurrentExpense = '/history-recurrent-expense';
  static const String historyRecurrentIncome = '/history-recurrent-income';

  // static Map<String, WidgetBuilder> routes = {
  //   start: (context) => const StartScreen(),
  //   login: (context) => const LoginScreen(),
  //   register: (context) => const RegisterScreen(),
  //   home: (context) => const HomeScreen(),
  //   settings: (context) => const SettingsScreen(),
  //   historyExpenses: (context) => const HistoryExpensesScreen(),
  //   historyIncome: (context) => const HistoryIncomeScreen(),
  //   missions: (context) => const MissionsScreen(),
  //   categories: (context) => const CategoriesListScreen(),
  //   newCategory: (context) => const NewCategoryScreen(),
  //   coupleSetup: (context) => const CoupleSetupScreen(),
  //   newRecurrentExpense: (context) => const NewRecurrentExpenseScreen(),
  //   newRecurrentIncome: (context) => const NewRecurrentIncomeScreen(),
  //   historyRecurrentExpense: (context) => const HistoryRecurrentExpenseScreen(),
  //   historyRecurrentIncome: (context) => const HistoryRecurrentIncomeScreen(),
  //   expenseDetail: (context) {
  //     final expenseId = ModalRoute.of(context)!.settings.arguments as String;
  //     return ExpenseDetailScreen(expenseId: expenseId);
  //   },
  //   incomeDetail: (context) {
  //     final incomeId = ModalRoute.of(context)!.settings.arguments as String;
  //     return IncomeDetailScreen(incomeId: incomeId);
  //   },
  static Map<String, WidgetBuilder> routes = {
    start: (context) => const LoginScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const HomeScreen(),
    settings: (context) => const Placeholder(),
    historyExpenses: (context) => const Placeholder(),
    historyIncome: (context) => const Placeholder(),
    missions: (context) => const Placeholder(),
    categories: (context) => const CategoryListScreen(),
    newCategory: (context) => const CategoryCommandScreen(),
    editCategory: (context) {
      final categoryId = ModalRoute.of(context)!.settings.arguments as String;
      return CategoryCommandScreen(categoryId: categoryId);
    },
    coupleSetup: (context) => const CoupleSetupScreen(),
    newRecurrentExpense: (context) => const Placeholder(),
    newRecurrentIncome: (context) => const Placeholder(),
    historyRecurrentExpense: (context) => const Placeholder(),
    historyRecurrentIncome: (context) => const Placeholder(),
    expenseDetail: (context) {
      final expenseId = ModalRoute.of(context)!.settings.arguments as String;
      return Text(expenseId);
    },
    incomeDetail: (context) {
      final incomeId = ModalRoute.of(context)!.settings.arguments as String;
      return Text(incomeId);
    },
  };
}
