import 'package:flutter/material.dart';

class Subtitle extends StatelessWidget {
  const Subtitle({super.key});
  static const double _fontSizeBase = 30;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 5,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Finanzas sin ",
                style: TextStyle(
                  fontSize: _fontSizeBase,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "Drama",
                style: TextStyle(
                  fontSize: _fontSizeBase,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Colors.pink.shade400,
                ),
              ),
            ],
          ),
          const Text(
            "Sin complicaciones, Solo tú, tu pareja, y vuestras metas. Transparencia total y cero estres",
            style:
                TextStyle(color: Colors.white70, fontSize: _fontSizeBase / 1.3),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
