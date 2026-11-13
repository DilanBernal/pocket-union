import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pocket_union/ui/router.dart';

import '../../../ui/widgets/auth_text_form_field.dart';
import '../../../ui/widgets/form_title.dart';
import '../../dtos/register_dto.dart';

class RegisterForm extends StatefulWidget {
  final Color colorFocusBorderInput;
  final Color colorEnabledBorderInput;
  final void Function(RegisterDto request) onRegister;
  final bool isLoading;

  const RegisterForm({
    super.key,
    required this.colorFocusBorderInput,
    required this.colorEnabledBorderInput,
    required this.onRegister,
    required this.isLoading,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  late final TapGestureRecognizer _loginRecognizer;

  @override
  void initState() {
    super.initState();
    _loginRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      };
  }

  @override
  void dispose() {
    _loginRecognizer.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (widget.isLoading) return;

    _formKey.currentState?.saveAndValidate();
    if (!_formKey.currentState!.validate()) return;

    if (_formKey.currentState!.fields['password']!.value !=
        _formKey.currentState!.fields['password_confirm']!.value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Las contraseñas no coinciden'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final request = RegisterDto(
      email: _formKey.currentState!.fields['email']!.value,
      fullName: _formKey.currentState!.fields['full_name']!.value,
      password: _formKey.currentState!.fields['password']!.value,
    );
    widget.onRegister(request);
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
                title: 'Crea tu cuenta',
                shadowColor: Colors.green,
                textColor: Colors.white,
                gradientColors: [
                  Colors.purple.shade600,
                  Colors.pink.shade700,
                ],
              ),
              Text(
                'El futuro de vuestras finanzas comienza aquí.',
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  fontSize: 19,
                ),
              ),
              AuthTextFormField(
                inputName: 'full_name',
                colorFocusBorderInput: widget.colorFocusBorderInput,
                icon: Icons.person_outline,
                fieldLabel: 'Nombres completos',
                colorEnabledBorderInput: widget.colorEnabledBorderInput,
                formKey: _formKey,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    checkNullOrEmpty: true,
                    errorText: 'El email no puede estar vacío',
                  ),
                  FormBuilderValidators.maxLength(
                    300,
                    errorText: 'El email no puede tener mas de 100 caracteres',
                  ),
                ]),
              ),
              AuthTextFormField(
                colorFocusBorderInput: widget.colorFocusBorderInput,
                colorEnabledBorderInput: widget.colorEnabledBorderInput,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                fieldLabel: 'Email',
                inputName: 'email',
                formKey: _formKey,
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
                inputName: 'password',
                formKey: _formKey,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.password(
                    errorText: 'La contraseña no esta en el formato correcto',
                    minLength: 6,
                    maxLength: 15,
                    minLowercaseCount: 1,
                    minUppercaseCount: 1,
                    minNumberCount: 1,
                    minSpecialCharCount: 0,
                  ),
                  FormBuilderValidators.required(),
                ]),
              ),
              AuthTextFormField(
                colorFocusBorderInput: widget.colorFocusBorderInput,
                colorEnabledBorderInput: widget.colorEnabledBorderInput,
                keyboardType: TextInputType.visiblePassword,
                icon: Icons.key,
                fieldLabel: 'Confirmar contraseña',
                inputName: 'password_confirm',
                formKey: _formKey,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.password(
                    errorText: 'La contraseña no esta en el formato correcto',
                    minLength: 6,
                    maxLength: 15,
                    minLowercaseCount: 1,
                    minUppercaseCount: 1,
                    minNumberCount: 1,
                    minSpecialCharCount: 0,
                  ),
                  FormBuilderValidators.required(),
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SizedBox(
                      width: 300,
                      child: Ink(
                        child: InkWell(
                          splashColor: Colors.blue,
                          onTap: _handleSubmit,
                          child: const Center(
                            child: Text('Crear cuenta'),
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
                  recognizer: _loginRecognizer,
                  text: '¿Ya tienes una cuenta?\n',
                  style: const TextStyle(),
                  children: [
                    TextSpan(
                      text: '¡Inicia sesión!',
                      recognizer: _loginRecognizer,
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
