import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/core/providers/data_cloud_providers.dart';
import 'package:pocket_union/dto/register_dto.dart';
import 'package:pocket_union/ui/router.dart';
import 'package:pocket_union/ui/screens/auth/widgets/auth_text_form_field.dart';
import 'package:pocket_union/ui/widgets/form_title.dart';

class RegisterForm extends ConsumerStatefulWidget {
  const RegisterForm({
    super.key,
    required GlobalKey<FormState> formKey,
    required this.colorFocusBorderInput,
    required this.colorEnabledBorderInput,
  }) : _formKey = formKey;

  final GlobalKey<FormState> _formKey;
  final Color colorFocusBorderInput;
  final Color colorEnabledBorderInput;

  @override
  ConsumerState<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<RegisterForm> {
  late String _email;
  late String _fullName;
  late String _password;

  Future<void> _handleCreateUser() async {
    if (!widget._formKey.currentState!.validate()) {
      return;
    }
    widget._formKey.currentState!.save();
    try {
      final authService = await ref.read(authServiceProvider.future);
      var res = await authService.register(
        RegisterDto(email: _email, fullName: _fullName, password: _password),
      );

      if (!mounted) return;
      if (res == null) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("¡Ocurrio un error al registrarse!"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    const Text(
                      "Se ha enviado un correo de confirmación a tu dirección de email.",
                    ),
                  ],
                ),
              ),
            );
          },
        );
        return;
      }

      // Mostrar diálogo de confirmación de email
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("¡Cuenta creada exitosamente!"),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  const Text(
                    "Se ha enviado un correo de confirmación a tu dirección de email.",
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Por favor confirma tu correo ($_email) para poder iniciar sesión.",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Después de confirmar tu correo, inicia sesión para "
                    "sincronizar con tu pareja. Este paso requiere internet.",
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
                child: const Text("Ir a inicio de sesión"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (mounted) {
        // Mostrar diálogo de error
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error al registrarse"),
              content: Text(e.toString().replaceAll('Exception: ', '')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cerrar"),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget._formKey,
      autovalidateMode: AutovalidateMode.onUnfocus,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 20,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FormTitle(
            title: "Crea tu cuenta",
            shadowColor: Colors.green,
            textColor: Colors.white,
            gradientColors: [Colors.purple.shade600, Colors.pink.shade700],
          ),
          Text(
            "El futuro de vuestras finanzas comienza aqui.",
            style: Theme.of(
              context,
            ).textTheme.labelLarge!.copyWith(fontSize: 19),
          ),
          AuthTextFormField(
            colorFocusBorderInput: widget.colorFocusBorderInput,
            icon: Icons.person_outline,
            fieldLabel: "Nombres completos",
            colorEnabledBorderInput: widget.colorEnabledBorderInput,
            onSaved: (text) {
              _fullName = text ?? '';
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Por favor, ingresa tu email.";
              }
              // if (!value.contains('@')) {
              //   return 'Por favor, ingresa un email válido.';
              // }
              return null;
            },
          ),
          AuthTextFormField(
            colorFocusBorderInput: widget.colorFocusBorderInput,
            colorEnabledBorderInput: widget.colorEnabledBorderInput,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            fieldLabel: "Email",
            onSaved: (text) {
              _email = text ?? '';
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
            colorFocusBorderInput: widget.colorFocusBorderInput,
            colorEnabledBorderInput: widget.colorEnabledBorderInput,
            keyboardType: TextInputType.visiblePassword,
            icon: Icons.key,
            fieldLabel: "Contraseña",
            onSaved: (value) {
              _password = value ?? '';
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Por favor, ingresa tu email.";
              }
              // if (!value.contains('@')) {
              //   return 'Por favor, ingresa un email válido.';
              // }
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
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  width: 300,
                  child: Ink(
                    child: InkWell(
                      splashColor: Colors.blue,
                      onTap: _handleCreateUser,
                      child: Center(
                        child: Text(
                          "Crear cuenta",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize:
                                (Theme.of(
                                      context,
                                    ).textTheme.titleLarge!.fontSize ??
                                    40) *
                                1.3,
                          ),
                        ),
                      ),
                    ),
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
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
              text: "¿Ya tienes una cuenta?\n",
              style: TextStyle(),
              children: [
                TextSpan(
                  text: "¡Inicia sesión!",
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
