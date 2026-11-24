import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pocket_union/ui/router.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../../ui/widgets/auth_text_form_field.dart';
import '../../../ui/widgets/form_title.dart';

class LoginForm extends StatefulWidget {
  final Color colorFocusBorderInput;
  final Color colorEnabledBorderInput;
  final bool isLoading;
  final void Function(String email, String password) onLogin;

  const LoginForm({
    super.key,
    required this.colorFocusBorderInput,
    required this.colorEnabledBorderInput,
    required this.isLoading,
    required this.onLogin,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  late final TapGestureRecognizer _registerRecognizer;

  @override
  void initState() {
    super.initState();
    _registerRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.pushReplacementNamed(context, AppRoutes.register);
      };
  }

  @override
  void dispose() {
    _registerRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        FormBuilder(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUnfocus,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 20,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FormTitle(
                title: 'Inicia sesión',
                shadowColor: Colors.green,
                textColor: Colors.white,
                gradientColors: [
                  Colors.purple.shade600,
                  Colors.pink.shade700,
                ],
              ),
              AuthTextFormField(
                colorFocusBorderInput: widget.colorFocusBorderInput,
                colorEnabledBorderInput: widget.colorEnabledBorderInput,
                icon: Icons.email_outlined,
                formKey: _formKey,
                keyboardType: TextInputType.emailAddress,
                fieldLabel: 'Email',
                inputName: 'email',
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    checkNullOrEmpty: true,
                    errorText: 'El email no puede estar vacío',
                  ),
                  FormBuilderValidators.email(
                    errorText: 'El email no esta en un formato valido',
                  ),
                  FormBuilderValidators.maxLength(
                    100,
                    errorText: 'El email no puede tener mas de 100 caracteres',
                  ),
                ]),
              ),
              AuthTextFormField(
                colorFocusBorderInput: widget.colorFocusBorderInput,
                colorEnabledBorderInput: widget.colorEnabledBorderInput,
                keyboardType: TextInputType.visiblePassword,
                icon: Icons.key,
                fieldLabel: 'Contraseña',
                formKey: _formKey,
                inputName: 'password',
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    checkNullOrEmpty: true,
                    errorText: 'La contraseña no puede estar vacía',
                  ),
                  FormBuilderValidators.password(
                    errorText: 'La contraseña no esta en el formato correcto',
                    minLength: 6,
                    maxLength: 15,
                    minLowercaseCount: 1,
                    minUppercaseCount: 1,
                    minNumberCount: 1,
                    minSpecialCharCount: 0,
                  ),
                ]),
              ),
              Material(
                borderOnForeground: false,
                color: Colors.transparent,
                type: MaterialType.button,
                borderRadius: BorderRadiusGeometry.circular(20),
                child: DecoratedBox(
                  position: DecorationPosition.background,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 116, 11, 218),
                        const Color.fromRGBO(251, 0, 204, 1),
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
                        onTap: () {
                          _formKey.currentState?.saveAndValidate();
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            final emailValue =
                                _formKey.currentState!.fields['email']!.value;
                            final passwordValue =
                                _formKey.currentState!.fields['password']!.value;
                            widget.onLogin(emailValue, passwordValue);
                          }
                        },
                        child: const Center(child: Text('ACCEDER')),
                      ),
                    ),
                  ),
                ),
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  recognizer: _registerRecognizer,
                  text: '¿Aun no tienes una cuenta?\n',
                  style: const TextStyle(),
                  children: [
                    TextSpan(
                      text: '¡Registrate!',
                      recognizer: _registerRecognizer,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (widget.isLoading)
          Positioned.fill(
            child: Center(
              child: CircularProgressIndicator(
                constraints: const BoxConstraints(
                  maxWidth: 50,
                  maxHeight: 50,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
