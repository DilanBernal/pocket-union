import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_union/ui/router.dart';

/// Botón de entrada
class EnterButton extends StatelessWidget {
  const EnterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shadowColor: Colors.purple,
      borderRadius: BorderRadius.circular(30),
      elevation: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromRGBO(105, 25, 210, 1),
                  const Color.fromRGBO(235, 30, 99, 1)
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple,
                  blurRadius: 20,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                Navigator.pushReplacementNamed(context, AppRoutes.register);
              },
              borderRadius: BorderRadius.circular(30),
              enableFeedback: true,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(Icons.play_arrow_rounded),
                    Text(
                      'Empezar ahora',
                      style: GoogleFonts.honk().copyWith(
                        inherit: true,
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
