import 'package:flutter/material.dart';

class GradientOverlay extends StatelessWidget {
  const GradientOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              const Color.fromARGB(135, 0, 0, 0),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
