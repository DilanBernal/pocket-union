import 'package:flutter/material.dart';

class ColoredTitleWidget extends StatelessWidget {
  final List<Color> gradientColors;
  final Text textWidget;

  const ColoredTitleWidget(
      {super.key, required this.gradientColors, required this.textWidget});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: gradientColors,
      ).createShader(bounds),
      child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 50),
          child: textWidget),
    );
  }
}
