import 'package:flutter/material.dart';
import 'package:pocket_union/ui/screens/auth/widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: LoginForm());
  }
}
