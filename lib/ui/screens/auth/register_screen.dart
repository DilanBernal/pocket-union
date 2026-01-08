import 'package:flutter/material.dart';
import 'package:pocket_union/ui/screens/auth/widgets/register_form.dart';
import 'package:pocket_union/ui/widgets/grid_background.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<StatefulWidget> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    const colorFocusBorderInput = Color.fromRGBO(56, 49, 70, 1);
    const colorEnabledBorderInput = Color.fromRGBO(45, 41, 53, 1);
    // final userRepo = context.read<UserDaoSqlite>();
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
                colors: [Colors.red.shade800, Colors.transparent])),
        child: SafeArea(
          child: RegisterForm(
              formKey: _formKey,
              colorFocusBorderInput: colorFocusBorderInput,
              colorEnabledBorderInput: colorEnabledBorderInput),
        ),
      ),
    );
  }
}
