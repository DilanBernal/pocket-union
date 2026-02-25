import 'package:flutter/material.dart';
import 'package:pocket_union/ui/screens/couple/widgets/couple_setup_body.dart';
import 'package:pocket_union/ui/widgets/grid_background.dart';

class CoupleSetupScreen extends StatelessWidget {
  const CoupleSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GridBackground(
      gridColor: const Color.fromRGBO(27, 7, 35, 1),
      strokeWidth: 2,
      gridSize: 40,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            focal: Alignment.bottomRight,
            focalRadius: 3,
            colors: [Colors.deepPurple.shade800, Colors.transparent],
          ),
        ),
        child: const SafeArea(
          child: CoupleSetupBody(),
        ),
      ),
    );
  }
}
