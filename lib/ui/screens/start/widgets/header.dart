import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_union/ui/screens/start/widgets/colored_title.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  static const _shadows = [
    Shadow(blurRadius: 50, offset: Offset(-5, 0), color: Colors.lightBlue),
    Shadow(blurRadius: 20, color: Color.fromARGB(255, 0, 213, 255)),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredTitleWidget(
      gradientColors: const [
        Colors.white60,
        Colors.purple,
        Colors.pink,
      ],
      textWidget: Text(
        'Pocket Union',
        style: GoogleFonts.sixtyfour().copyWith(
          fontSize: 30,
          shadows: _shadows,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
