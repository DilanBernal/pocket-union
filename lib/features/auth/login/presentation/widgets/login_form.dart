import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pocket_union/ui/router.dart';
import 'package:pocket_union/ui/screens/auth/widgets/auth_text_form_field.dart';
import 'package:pocket_union/ui/widgets/form_title.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class LoginForm extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (isLoading) {
      return CircularProgressIndicator(
        constraints: BoxConstraints(maxWidth: 50, maxHeight: 50),
      );
    }

    final formKey = GlobalKey<FormBuilderState>();

    return FormBuilder(
      key: formKey,
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
            gradientColors: [Colors.purple.shade600, Colors.pink.shade700],
          ),
          AuthTextFormField(
            colorFocusBorderInput: colorFocusBorderInput,
            colorEnabledBorderInput: colorEnabledBorderInput,
            icon: Icons.email_outlined,
            formKey: formKey,
            keyboardType: TextInputType.emailAddress,
            fieldLabel: 'Email',
            inputName: 'Email',
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
            keyboardType: TextInputType.text,
            icon: Icons.key,
            fieldLabel: 'Contraseña',
            formKey: formKey,
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
                    onTap: () {
                      formKey.currentState?.saveAndValidate();
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        final emailValue = formKey.currentState!.fields['email']!.value;
                        final passwordValue = formKey.currentState!.fields['password']!.value;
                        onLogin(emailValue, passwordValue);
                      }
                    },
                    child: Center(child: Text('ACCEDER')),
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
              text: '¿Aun no tienes una cuenta?\n',
              style: TextStyle(),
              children: [
                TextSpan(
                  text: '¡Registrate!',
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
}
