import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/core/providers/auth_service_provider.dart';
import 'package:pocket_union/domain/enum/couple_usable_state.dart';
import 'package:pocket_union/dto/login_dto.dart';
import 'package:pocket_union/ui/router.dart';
import 'package:pocket_union/ui/screens/auth/widgets/auth_text_form_field.dart';
import 'package:pocket_union/ui/widgets/form_title.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    colorFocusBorderInput: colorFocusBorderInput,
  );
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
        var response = await authService.login(
          LoginDto(email: _email, password: _password),
        );

        // Mostrar notificación de bienvenida
        if (mounted && response.session != null) {
          // Check couple status to decide where to navigate
          final prefs = await SharedPreferences.getInstance();
          final coupleId = prefs.getString('coupleId');

          String targetRoute;
          String welcomeMessage;

          if (coupleId != null && coupleId.isNotEmpty) {
            // Has couple — check if it's READY
            try {
              final coupleService = await ref.read(
                coupleServiceProvider.future,
              );
              final couple = await coupleService.getCoupleByUserId(
                response.user!.id,
              );

              if (couple != null &&
                  couple.isUsable == CoupleUsableState.ready) {
                targetRoute = AppRoutes.home;
                welcomeMessage =
                    '¡Bienvenido de vuelta! Ya puedes usar la aplicación.';
              } else {
                targetRoute = AppRoutes.coupleSetup;
                welcomeMessage =
                    'Aún falta que tu pareja se una. Completa la configuración.';
              }
            } catch (_) {
              // If we can't check, go to couple setup to verify
              targetRoute = AppRoutes.coupleSetup;
              welcomeMessage = 'Verifica la conexión con tu pareja.';
            }
          } else {
            // No couple yet — must set up
            targetRoute = AppRoutes.coupleSetup;
            welcomeMessage =
                '¡Bienvenido! Ahora sincroniza con tu pareja para comenzar.';
          }

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(welcomeMessage),
              backgroundColor: Colors.green.shade600,
              duration: const Duration(seconds: 3),
            ),
          );
          Navigator.pushReplacementNamed(context, targetRoute);
        }
      }
    } on AuthException catch (error) {
      if (mounted) {
        debugPrint(error.message);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${error.message}"),
            backgroundColor: Colors.red.shade600,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        debugPrint("Error durante el login: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Ocurrió un error inesperado. Por favor intenta nuevamente.",
            ),
            backgroundColor: Colors.red.shade600,
            duration: const Duration(seconds: 3),
          ),
        );
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
        ? CircularProgressIndicator(
            constraints: BoxConstraints(maxWidth: 50, maxHeight: 50),
          )
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
                    Colors.pink.shade700,
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
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 116, 11, 218),
                          Color.fromRGBO(251, 0, 204, 1),
                        ],
                      ),
                      borderRadius: BorderRadiusGeometry.circular(20),
                    ),
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
                          context,
                          AppRoutes.login,
                        );
                      },
                    text: "¿Aun no tienes una cuenta?\n",
                    style: TextStyle(),
                    children: [
                      TextSpan(
                        text: "¡Registrate!",
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.register,
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  @override
  void initState() {
    super.initState();
  }
}
