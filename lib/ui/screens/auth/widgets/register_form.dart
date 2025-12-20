import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_union/ui/widgets/form_title.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({
    super.key,
    required GlobalKey<FormState> formKey,
    required this.colorFocusBorderInput,
    required this.colorEnabledBorderInput,
  }) : _formKey = formKey;

  final GlobalKey<FormState> _formKey;
  final Color colorFocusBorderInput;
  final Color colorEnabledBorderInput;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUnfocus,
      child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 20,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FormTitle(
              title: "Crea tu cuenta",
              shadowColor: Colors.green,
              textColor: Colors.blue,
              gradientColors: [Colors.purple.shade300, Colors.pink.shade200],
            ),
            Text(
              "El futuro de vuestras finanzas comienza aqui.",
              style: Theme.of(context)
                  .textTheme
                  .labelLarge!
                  .copyWith(fontSize: 19),
            ),
            RegisterTextFormField(
                colorFocusBorderInput: colorFocusBorderInput,
                colorEnabledBorderInput: colorEnabledBorderInput),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                fillColor: const Color.fromRGBO(22, 17, 30, 1),
                filled: true,
                label: Text("Email"),
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(
                        color: colorFocusBorderInput,
                        width: 1.5,
                        strokeAlign: 20)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(
                        color: colorEnabledBorderInput,
                        width: 1.5,
                        strokeAlign: 20)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please add some text";
                }
                return null;
              },
            ),
            TextFormField(
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.key),
                fillColor: const Color.fromRGBO(22, 17, 30, 1),
                filled: true,
                label: Text("Contraseña"),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(
                        color: colorFocusBorderInput,
                        width: 1.5,
                        strokeAlign: 20)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(
                        color: colorEnabledBorderInput,
                        width: 1.5,
                        strokeAlign: 20)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please add some text";
                }
                return null;
              },
            ),
            TextButton(onPressed: () {}, child: Text("data"))

            // InputWithButton(
            //   onSend: (values) => {_createUser(values, userRepo)},
            //   fieldNames: ["nombre", "dinero"],
            //   keyboardTypes: [TextInputType.text, TextInputType.number],
            //   buttonName: "Registrar tu usuario",
            //   inputFormatters: [
            //     [],
            //     [FilteringTextInputFormatter.digitsOnly]
            //   ],
            // )
          ]),
    );
  }
}

class RegisterTextFormField extends StatelessWidget {
  const RegisterTextFormField({
    super.key,
    required this.colorFocusBorderInput,
    required this.colorEnabledBorderInput,
  });

  final Color colorFocusBorderInput;
  final Color colorEnabledBorderInput;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        fillColor: const Color.fromRGBO(22, 17, 30, 1),
        filled: true,
        label: Text("Nombres completos"),
        prefixIcon: Icon(Icons.person_outline),
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
