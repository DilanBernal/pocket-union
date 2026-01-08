import 'package:flutter/material.dart';
import 'package:pocket_union/ui/screens/auth/login_screen.dart';
import 'package:pocket_union/ui/screens/auth/register_screen.dart';
import 'package:pocket_union/ui/screens/home_screen.dart';
import 'package:pocket_union/ui/screens/start/start_screen.dart';

class AppRoutes {
  static const String start = '/';
  static const String home = '/home';
  static const String register = '/register';
  static const String login = '/login';
  static const String profile = '/profile';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> routes = {
    start: (context) => const StartScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const HomeScreen(),
  };
}
