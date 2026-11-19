import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/features/auth/register/presentation/controllers/register_controller.dart';
import 'package:pocket_union/ui/router.dart';
import 'package:pocket_union/ui/widgets/grid_background.dart';

import '../../dtos/register_dto.dart';
import '../widgets/register_form.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerState = ref.watch(registerControllerProvider);
    ref.listen(registerControllerProvider, (_, next) {
      next.whenOrNull(
        data: (authResult) async {
          if (authResult != null) {
            Navigator.pushReplacementNamed(context, AppRoutes.coupleSetup);
          }
        },
        // error: (e, st) {
        //   showDialog(
        //     context: context,
        //     barrierDismissible: true,
        //     builder: (BuildContext context) {
        //       return AlertDialog(
        //         title: const Text('¡Ocurrio un error al registrarse!'),
        //         content: SingleChildScrollView(
        //           child: ListBody(
        //             children: [
        //               const Text(
        //                 'Se ha enviado un correo de confirmación a tu dirección de email.',
        //               ),
        //             ],
        //           ),
        //         ),
        //       );
        //     },
        //   );
        // },
      );
    });

    const colorFocusBorderInput = Color.fromRGBO(56, 49, 70, 1);
    const colorEnabledBorderInput = Color.fromRGBO(45, 41, 53, 1);
    return Stack(
      alignment: Alignment.center,
      children: [
        RepaintBoundary(
          child: GridBackground(
            gridColor: const Color.fromRGBO(27, 7, 35, 1),
            strokeWidth: 2,
            gridSize: 40,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: AlignmentGeometry.topRight,
                  focal: AlignmentGeometry.bottomRight,
                  focalRadius: 3,
                  colors: [Colors.red.shade800, Colors.transparent],
                ),
              ),
              child: Container(),
            ),
          ),
        ),
        RepaintBoundary(
          child: SafeArea(
            child: RegisterForm(
              isLoading: registerState.isLoading,
              colorFocusBorderInput: colorFocusBorderInput,
              colorEnabledBorderInput: colorEnabledBorderInput,
              onRegister: (RegisterDto request) {
                ref
                    .read(registerControllerProvider.notifier)
                    .register(request);
              },
            ),
          ),
        ),
      ],
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
