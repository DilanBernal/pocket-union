import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class AuthTextFormField extends StatelessWidget {
  AuthTextFormField({
    super.key,
    required this.colorFocusBorderInput,
    required this.colorEnabledBorderInput,
    required this.icon,
    required this.fieldLabel,
    required this.formKey,
    /// Este dato va a ser el nombre del input por el cual se va a acceder mas adelante, se hará una transformación con .toLower
    required this.inputName,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  final String inputName;
  final Color colorFocusBorderInput;
  final IconData icon;
  final String fieldLabel;
  final Color colorEnabledBorderInput;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;
  final GlobalKey<FormBuilderState> formKey;
  final _fieldKey = GlobalKey<FormBuilderFieldState>();


  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      keyboardType: keyboardType,
      key: _fieldKey,
      name: inputName.toLowerCase(),
      autofillHints: [inputName],
      decoration: InputDecoration(
        labelText: fieldLabel ?? '',
        fillColor: const Color.fromRGBO(22, 17, 30, 1),
        filled: true,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(22)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: colorFocusBorderInput,
            width: 1.5,
            strokeAlign: 20,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: colorEnabledBorderInput,
            width: 1.5,
            strokeAlign: 20,
          ),
        ),
      ),
      validator: validator,
    );
  }
}
