import 'package:flutter/material.dart';

/// Botón de entrada
class EnterButton extends StatelessWidget {
  const EnterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Entrar"),
      ],
    );
  }
}
