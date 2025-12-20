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
              Text(
                "Finanzas sin ",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: _fontSizeBase,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                "Drama",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontSize: _fontSizeBase,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    color: Colors.pink.shade400,
                    shadows: [
                      Shadow(color: Colors.black, offset: Offset(2.5, 2.5))
                    ]),
              ),
            ],
          ),
          Text(
            "Sin complicaciones, Solo tú, tu pareja, y vuestras metas. Transparencia total y cero estres",
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(color: Colors.white70, fontSize: _fontSizeBase / 1.3),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
