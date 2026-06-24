import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/features/auth/register/presentation/controllers/register_controller.dart';
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
            Navigator.pushReplacementNamed(context, '/home');
          }
        },
      );
    });

    const colorFocusBorderInput = Color.fromRGBO(56, 49, 70, 1);
    const colorEnabledBorderInput = Color.fromRGBO(45, 41, 53, 1);
    return GridBackground(
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
        child: SafeArea(
          child: RegisterForm(
            isLoading: registerState.isLoading,
            colorFocusBorderInput: colorFocusBorderInput,
            colorEnabledBorderInput: colorEnabledBorderInput,
            onRegister: (RegisterDto request) async{
              await ref
                  .read(registerControllerProvider.notifier)
                  .register(request);
            },
          ),
        ),
      ),
    );
  }
}
