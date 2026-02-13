import 'package:flutter/material.dart';

class StartHeroWidget extends StatelessWidget {
  final String name1;
  final String name2;
  const StartHeroWidget({
    super.key,
    required this.name1,
    required this.name2,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text("Foto1"), Text("Foto2")],
        ),
        Text("Hola $name1 y $name2"),
      ],
    );
  }
}
