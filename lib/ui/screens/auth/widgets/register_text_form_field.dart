import 'package:flutter/material.dart';

class RegisterTextFormField extends StatelessWidget {
  const RegisterTextFormField(
      {super.key,
      required this.colorFocusBorderInput,
      required this.colorEnabledBorderInput,
      required this.icon,
      required this.fieldLabel,
      this.keyboardType = TextInputType.text});

  final Color colorFocusBorderInput;
  final IconData icon;
  final String fieldLabel;
  final Color colorEnabledBorderInput;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        fillColor: const Color.fromRGBO(22, 17, 30, 1),
        filled: true,
        label: Text(fieldLabel),
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(
                color: colorFocusBorderInput, width: 1.5, strokeAlign: 20)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(
                color: colorEnabledBorderInput, width: 1.5, strokeAlign: 20)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please add some text";
        }
        return null;
      },
    );
  }
}
