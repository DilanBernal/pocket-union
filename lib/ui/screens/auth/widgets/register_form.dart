import 'package:flutter/material.dart';
import 'package:pocket_union/ui/screens/auth/widgets/register_text_form_field.dart';
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
              textColor: Colors.white,
              gradientColors: [Colors.purple.shade600, Colors.pink.shade700],
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
              icon: Icons.person_outline,
              fieldLabel: "Nombres completos",
              colorEnabledBorderInput: colorEnabledBorderInput,
            ),
            RegisterTextFormField(
              colorFocusBorderInput: colorFocusBorderInput,
              colorEnabledBorderInput: colorEnabledBorderInput,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              fieldLabel: "Email",
            ),
            RegisterTextFormField(
              colorFocusBorderInput: colorFocusBorderInput,
              colorEnabledBorderInput: colorEnabledBorderInput,
              keyboardType: TextInputType.visiblePassword,
              icon: Icons.key,
              fieldLabel: "Contraseña",
            ),
            Material(
              color: Colors.transparent,
              child: Ink(
                child: InkWell(
                  onTap: () {},
                  child: Text("kasdfads"),
                ),
              ),
            )
          ]),
    );
  }
}
