import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FormTitle extends StatelessWidget {
  final String title;
  final List<Color> gradientColors;
  final Color textColor;
  final Color shadowColor;
  const FormTitle(
      {super.key,
      required this.title,
      this.gradientColors = const [],
      this.textColor = CupertinoColors.white,
      this.shadowColor = CupertinoColors.white});

  @override
  Widget build(BuildContext context) {
    Text textWidget = Text(title,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontSize: 30,
            fontWeight: FontWeight.w200,
            shadows: [Shadow(color: shadowColor, blurRadius: 20)],
            color: textColor));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 20),
      child: gradientColors.length <= 1
          ? textWidget
          : ShaderMask(
              shaderCallback: (bounds) =>
                  LinearGradient(colors: gradientColors).createShader(bounds),
              child: textWidget,
            ),
    );
  }
}
