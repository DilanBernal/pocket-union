import 'package:flutter/cupertino.dart';

class FormTitle extends StatelessWidget {
  final String title;
  const FormTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 30,
            color: Color.fromRGBO(182, 182, 255, 1.0),
            decoration: TextDecoration.none),
      ),
    );
  }
}
