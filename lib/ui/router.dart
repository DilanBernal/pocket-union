import 'package:flutter/material.dart';
import 'package:pocket_union/ui/screens/auth/form_test.dart';
import 'package:pocket_union/ui/screens/auth/register_screen.dart';
import 'package:pocket_union/ui/screens/start/start_screen.dart';

class AppRoutes {
  static const String start = '/';
  static const String home = '/home';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> routes = {
    start: (context) => const StartScreen(),
    register: (context) => const RegisterScreen()
  };
}
