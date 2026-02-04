import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/core/providers.dart';
import 'package:pocket_union/dto/login_dto.dart';
import 'package:pocket_union/ui/router.dart';
import 'package:pocket_union/ui/screens/auth/widgets/auth_text_form_field.dart';
import 'package:pocket_union/ui/widgets/form_title.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({
    super.key,
    required this.colorFocusBorderInput,
    required this.colorEnabledBorderInput,
  });

  final Color colorFocusBorderInput;
  final Color colorEnabledBorderInput;

  @override
  // ignore: no_logic_in_create_state
  ConsumerState<LoginForm> createState() => _LoginFormState(
      colorEnabledBorderInput: colorEnabledBorderInput,
      colorFocusBorderInput: colorFocusBorderInput);
}

class _LoginFormState extends ConsumerState<LoginForm> {
  _LoginFormState({
    required this.colorFocusBorderInput,
    required this.colorEnabledBorderInput,
  });

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Color colorFocusBorderInput;
  final Color colorEnabledBorderInput;
  bool _isLoading = false;

  late String _email;
  late String _password;

  Future<void> _handleSignin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    try {
      setState(() {
        _isLoading = true;
      });
      final authService = await ref.read(authServiceProvider.future);
      if (mounted) {
        var response = await authService.login(LoginDto(email: _email, password: _password));
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        // context.showSnackBar('Check your email for a login link!');
        debugPrint("Revisa email");
      }
    } on AuthException catch (error) {
      if (mounted) debugPrint(error.message);
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
                    title: "Inicia sesión",
                    shadowColor: Colors.green,
                    textColor: Colors.white,
                    gradientColors: [
                      Colors.purple.shade600,
                      Colors.pink.shade700
                    ],
                  ),
                  AuthTextFormField(
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
                  AuthTextFormField(
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
                      return null;
                    },
                  ),
                  Material(
                    borderOnForeground: false,
                    color: Colors.transparent,
                    type: MaterialType.button,
                    child: DecoratedBox(
                      position: DecorationPosition.background,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Color.fromARGB(255, 116, 11, 218),
                            Color.fromRGBO(251, 0, 204, 1)
                          ]),
                          borderRadius: BorderRadiusGeometry.circular(20)),
                      child: SizedBox(
                        width: 300,
                        height: 40,
                        child: Ink(
                          child: InkWell(
                            splashColor: Colors.blue,
                            onTap: _handleSignin,
                            child: Center(child: Text("ACCEDER")),
                          ),
                        ),
                      ),
                    ),
                  ),
                  RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushReplacementNamed(
                                  context, AppRoutes.login);
                            },
                          text: "¿Ya tienes una cuenta?\n",
                          style: TextStyle(),
                          children: [
                            TextSpan(
                              text: "¡Inicia sesión!",
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushReplacementNamed(
                                      context, AppRoutes.login);
                                },
                            )
                          ]))
                ]),
          );
  }

  @override
  void initState() {
    super.initState();
  }
}
