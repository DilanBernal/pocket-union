import 'package:flutter/material.dart';

class ColoredTitleWidget extends StatelessWidget {
  final List<Color> gradientColors;
  final Text textWidget;
  final double horizontalPadding;

  const ColoredTitleWidget(
      {super.key,
      required this.gradientColors,
      required this.textWidget,
      this.horizontalPadding = 0});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: gradientColors,
      ).createShader(bounds),
      child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: horizontalPadding),
          child: textWidget),
    );
  }
}
