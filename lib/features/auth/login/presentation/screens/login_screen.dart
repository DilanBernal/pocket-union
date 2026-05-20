import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/features/auth/login/domain/entities/auth_result.dart';
import 'package:pocket_union/features/auth/login/presentation/controllers/login_controller.dart';
import 'package:pocket_union/features/auth/login/presentation/widgets/login_form.dart';
import 'package:pocket_union/ui/widgets/grid_background.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginControllerProvider);
    ref.listen<AsyncValue<AuthResult?>>(loginControllerProvider, (_, next) {
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
          child: LoginForm(
            colorFocusBorderInput: colorFocusBorderInput,
            colorEnabledBorderInput: colorEnabledBorderInput,
            isLoading: loginState.isLoading,
            onLogin: (email, password) {
              ref.read(loginControllerProvider.notifier).login(email, password);
            },
          ),
        ),
      ),
    );
  }
}
