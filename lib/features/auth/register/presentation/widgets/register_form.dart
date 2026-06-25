import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pocket_union/ui/router.dart';

import '../../../ui/widgets/auth_text_form_field.dart';
import '../../../ui/widgets/form_title.dart';
import '../../dtos/register_dto.dart';

class RegisterForm extends StatelessWidget {
  final Color colorFocusBorderInput;
  final Color colorEnabledBorderInput;
  final formKey = GlobalKey<FormBuilderState>();
  final void Function(RegisterDto request) onRegister;
  final bool isLoading;

  RegisterForm({
    super.key,
    required this.colorFocusBorderInput,
    required this.colorEnabledBorderInput,
    required this.onRegister,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: formKey,
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
            gradientColors: [Colors.purple.shade600, Colors.pink.shade700],
          ),
          Text(
            'El futuro de vuestras finanzas comienza aquí.',
            style: Theme.of(
              context,
            ).textTheme.labelLarge!.copyWith(fontSize: 19),
          ),
          AuthTextFormField(
            inputName: 'full_name',
            colorFocusBorderInput: colorFocusBorderInput,
            icon: Icons.person_outline,
            fieldLabel: 'Nombres completos',
            colorEnabledBorderInput: colorEnabledBorderInput,
            formKey: formKey,
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
            colorFocusBorderInput: colorFocusBorderInput,
            colorEnabledBorderInput: colorEnabledBorderInput,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            fieldLabel: 'Email',
            inputName: 'email',
            formKey: formKey,
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
            colorFocusBorderInput: colorFocusBorderInput,
            colorEnabledBorderInput: colorEnabledBorderInput,
            keyboardType: TextInputType.visiblePassword,
            icon: Icons.key,
            fieldLabel: 'Contraseña',
            inputName: 'password',
            formKey: formKey,
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
            colorFocusBorderInput: colorFocusBorderInput,
            colorEnabledBorderInput: colorEnabledBorderInput,
            keyboardType: TextInputType.visiblePassword,
            icon: Icons.key,
            fieldLabel: 'Confirmar contraseña',
            inputName: 'password_confirm',
            formKey: formKey,
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
              // FormBuilderValidators.equal(
              //   formKey.currentState?.fields['password']?.value,
              //   errorText: 'Las contraseñas no coinciden',
              // ),
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
                      onTap: () {
                        if (isLoading) return;
                        formKey.currentState?.saveAndValidate();
                        if (!formKey.currentState!.validate()) return;

                        if (formKey.currentState!.fields['password']!.value !=
                            formKey
                                .currentState!
                                .fields['password_confirm']!
                                .value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Las contraseñas no coinciden'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        final request = RegisterDto(
                          email: formKey.currentState!.fields['email']!.value,
                          fullName:
                              formKey.currentState!.fields['full_name']!.value,
                          password:
                              formKey.currentState!.fields['password']!.value,
                        );
                        onRegister(request);
                      },
                      child: Center(
                        child: Text(
                          'Crear cuenta',
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
              text: '¿Ya tienes una cuenta?\n',
              style: TextStyle(),
              children: [
                TextSpan(
                  text: '¡Inicia sesión!',
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
