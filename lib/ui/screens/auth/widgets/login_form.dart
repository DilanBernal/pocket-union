import 'dart:async';
import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _isLoading = false;
  bool _redirecting = false;
  late final TextEditingController _emailController = TextEditingController();
  late final StreamSubscription<AuthState> _authStateSubscription;

  final supabase = Supabase.instance.client;

  Future<void> _signIn() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await supabase.auth.signInWithOtp(
        email: _emailController.text.trim(),
        emailRedirectTo:
            kIsWeb ? null : 'io.supabase.flutterquickstart://login-callback/',
      );
      if (mounted) {
        // context.showSnackBar('Check your email for a login link!');
        print("Revisa email");
        _emailController.clear();
      }
    } on AuthException catch (error) {
      if (mounted) print(error.message);
    } catch (error) {
      if (mounted) {
        // context.showSnackBar('Unexpected error occurred', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _redirecting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_redirecting) {
      return Text("Cargado");
    }
    return _isLoading ? Placeholder() : Text("Cargado");
  }
}
