import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pocket_union/ui/router.dart';
import 'package:pocket_union/ui/screens/auth/widgets/register_text_form_field.dart';
import 'package:pocket_union/ui/widgets/form_title.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    required this.colorFocusBorderInput,
    required this.colorEnabledBorderInput,
  });

  final Color colorFocusBorderInput;
  final Color colorEnabledBorderInput;
  @override
  State<LoginForm> createState() => _LoginFormState(
      colorEnabledBorderInput: colorEnabledBorderInput,
      colorFocusBorderInput: colorFocusBorderInput);
}

class _LoginFormState extends State<LoginForm> {
  _LoginFormState({
    required this.colorFocusBorderInput,
    required this.colorEnabledBorderInput,
  });

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Color colorFocusBorderInput;
  final Color colorEnabledBorderInput;
  bool _isLoading = false;

  final supabase = Supabase.instance.client;

  late String _email;
  late String _password;

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    _isLoading = true;

    try {
      setState(() {
        _isLoading = true;
      });
      await supabase.auth
          .signInWithPassword(email: _email, password: _password);
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        // context.showSnackBar('Check your email for a login link!');
        print("Revisa email");
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
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? CircularProgressIndicator()
        : Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUnfocus,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 20,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FormTitle(
                    title: "Inicia sesión en tu cuenta",
                    shadowColor: Colors.green,
                    textColor: Colors.white,
                    gradientColors: [
                      Colors.purple.shade600,
                      Colors.pink.shade700
                    ],
                  ),
                  Text(
                    "El futuro de vuestras finanzas comienza aqui.",
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(fontSize: 19),
                  ),
                  RegisterTextFormField(
                    colorFocusBorderInput: colorFocusBorderInput,
                    colorEnabledBorderInput: colorEnabledBorderInput,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    fieldLabel: "Email",
                    onSaved: (newEmail) {
                      _email = newEmail ?? '';
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Por favor, ingresa tu email.";
                      }
                      if (!value.contains('@')) {
                        return 'Por favor, ingresa un email válido.';
                      }
                      return null;
                    },
                  ),
                  RegisterTextFormField(
                    colorFocusBorderInput: colorFocusBorderInput,
                    colorEnabledBorderInput: colorEnabledBorderInput,
                    keyboardType: TextInputType.visiblePassword,
                    icon: Icons.key,
                    fieldLabel: "Contraseña",
                    onSaved: (newPassword) {
                      _password = newPassword ?? '';
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Por favor, ingresa tu email.";
                      }
                      // Opcional: Validar formato de email
                      // if (!value.contains('@')) {
                      //   return 'Por favor, ingresa un email válido.';
                      // }
                      return null;
                    },
                  ),
                  Material(
                    color: Colors.transparent,
                    child: Ink(
                      child: InkWell(
                        onTap: _signIn,
                        child: Text("Logearse"),
                      ),
                    ),
                  )
                ]),
          );
  }

  @override
  void initState() {
    super.initState();
  }
}
