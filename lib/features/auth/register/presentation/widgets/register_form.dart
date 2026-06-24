import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pocket_union/ui/router.dart';

import '../../../application/services/auth_service.dart';
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
                        formKey.currentState?.saveAndValidate();
                        if (formKey.currentState!.validate()) {
                          final request = RegisterDto(
                            email: formKey.currentState!.fields['email']!.value,
                            fullName:
                                formKey.currentState!.fields['full_name']!.value,
                            password:
                                formKey.currentState!.fields['password']!.value,
                          );
                          onRegister(request);
                        }
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

// Future<void> _handleCreateUser() async {
//   if (!formKey.currentState!.validate()) {
//     return;
//   }
//   formKey.currentState!.save();
//   try {
//     final authService = await ref.read(authServiceProvider.future);
//     var res = await authService.register(
//       RegisterDto(email: _email, fullName: _fullName, password: _password),
//     );
//
//     if (!mounted) return;
//     if (res == null) {
//       showDialog(
//         context: context,
//         barrierDismissible: true,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text('¡Ocurrio un error al registrarse!'),
//             content: SingleChildScrollView(
//               child: ListBody(
//                 children: [
//                   const Text(
//                     'Se ha enviado un correo de confirmación a tu dirección de email.',
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       );
//       return;
//     }
//
//     // Mostrar diálogo de confirmación de email
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('¡Cuenta creada exitosamente!'),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: [
//                 const Text(
//                   'Se ha enviado un correo de confirmación a tu dirección de email.',
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Por favor confirma tu correo ($_email) para poder iniciar sesión.',
//                   style: const TextStyle(fontSize: 14),
//                 ),
//                 const SizedBox(height: 16),
//                 const Text(
//                   'Después de confirmar tu correo, inicia sesión para '
//                   'sincronizar con tu pareja. Este paso requiere internet.',
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontStyle: FontStyle.italic,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 Navigator.pushReplacementNamed(context, AppRoutes.login);
//               },
//               child: const Text('Ir a inicio de sesión'),
//             ),
//           ],
//         );
//       },
//     );
//   } catch (e) {
//     if (mounted) {
//       // Mostrar diálogo de error
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text('Error al registrarse'),
//             content: Text(e.toString().replaceAll('Exception: ', '')),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Cerrar'),
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }
// }
