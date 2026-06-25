import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class AuthTextFormField extends StatefulWidget {
  const AuthTextFormField({
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

  @override
  State<AuthTextFormField> createState() => _AuthTextFormFieldState();
}

class _AuthTextFormFieldState extends State<AuthTextFormField> {
  bool showPassword = true;
  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      keyboardType: widget.keyboardType,
      // key: _fieldKey,
      obscureText:
          showPassword && widget.keyboardType == TextInputType.visiblePassword,
      name: widget.inputName.toLowerCase(),
      autofillHints: [widget.inputName],
      decoration: InputDecoration(
        labelText: widget.fieldLabel,
        fillColor: const Color.fromRGBO(22, 17, 30, 1),
        filled: true,
        prefixIcon: Icon(widget.icon),
        suffixIcon: widget.keyboardType == TextInputType.visiblePassword
            ? IconButton(
                icon: Icon(
                  showPassword ? TablerIcons.eye : TablerIcons.eye_closed,
                ),
                onPressed: () {
                  setState(() {
                    showPassword = !showPassword;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(22)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: widget.colorFocusBorderInput,
            width: 1.5,
            strokeAlign: 20,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: widget.colorEnabledBorderInput,
            width: 1.5,
            strokeAlign: 20,
          ),
        ),
      ),

      validator: widget.validator,
    );
  }
}
