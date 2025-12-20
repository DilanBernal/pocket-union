import 'package:flutter/material.dart';
import 'package:pocket_union/ui/screens/start/widgets/colored_title.dart';

class CentralCard extends StatelessWidget {
  const CentralCard({super.key});

  static const _shadows = [
    Shadow(blurRadius: 50, offset: Offset(-5, 0), color: Colors.lightBlue),
    Shadow(blurRadius: 20, color: Color.fromARGB(255, 0, 213, 255)),
    Shadow(color: Colors.black, offset: Offset(4, 4)),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(140, 13, 72, 161),
              spreadRadius: 10,
              blurRadius: 13.3,
            ),
          ],
          borderRadius: BorderRadius.circular(220),
          gradient: const RadialGradient(
            radius: 1,
            stops: [0.001, 1],
            colors: [
              Color.fromARGB(98, 255, 82, 82),
              Color.fromARGB(36, 13, 72, 161),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Juntos es",
              style: TextStyle(
                color: Colors.white,
                shadows: _shadows,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            ColoredTitleWidget(
              gradientColors: const [
                Color.fromARGB(255, 175, 35, 200),
                Color.fromARGB(255, 115, 25, 210),
              ],
              textWidget: const Text(
                "MEJOR",
                style: TextStyle(
                  color: Colors.white,
                  shadows: _shadows,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
