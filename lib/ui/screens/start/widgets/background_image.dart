import 'package:flutter/material.dart';

class BackgroundImage extends StatelessWidget {
  const BackgroundImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Image.asset(
        'assets/img/horizontal_synth_wave_background.png',
        fit: BoxFit.cover,
      ),
    );
  }
}
