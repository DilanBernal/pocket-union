import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pocket_union/Dao/sqlite/user_dao_sqlite.dart';
import 'package:pocket_union/domain/models/user.dart';
import 'package:pocket_union/ui/router.dart';
import 'package:pocket_union/ui/screens/auth/widgets/auth_text_form_field.dart';
import 'package:pocket_union/ui/widgets/form_title.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({
    super.key,
    required GlobalKey<FormState> formKey,
    required this.colorFocusBorderInput,
    required this.colorEnabledBorderInput,
  }) : _formKey = formKey;

  Future<void> _createUser(
      Map<String, String> values, UserDaoSqlite userRepo) async {
    final prefs = await SharedPreferences.getInstance();
    final bool isFirst = prefs.getBool('isFirstLaunch') ?? true;
    try {
      final name = values['nombre']!;
      final balance = double.tryParse(values['dinero']!) ?? 0.0;
      if (name.trim() != '' && isFirst == true) {
        final user = User(id: '', name: name, balance: balance, inCloud: false);
        int idGenerated = await userRepo.insertUser(user);
        await prefs.setInt('userId', idGenerated);
        await prefs.setBool('isFirstLaunch', false);
      }
      await userRepo.getAllUsers();
    } catch (e) {
      throw Exception(e);
    }
  }

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
            AuthTextFormField(
              colorFocusBorderInput: colorFocusBorderInput,
              icon: Icons.person_outline,
              fieldLabel: "Nombres completos",
              colorEnabledBorderInput: colorEnabledBorderInput,
            ),
            AuthTextFormField(
              colorFocusBorderInput: colorFocusBorderInput,
              colorEnabledBorderInput: colorEnabledBorderInput,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              fieldLabel: "Email",
            ),
            AuthTextFormField(
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
            ),
            RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pushReplacementNamed(
                            context, AppRoutes.login);
                      },
                    text: "¿Ya tienes una cuenta?\n",
                    style: TextStyle(),
                    children: [
                      TextSpan(
                        text: "¡Inicia sesión!",
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushReplacementNamed(
                                context, AppRoutes.login);
                          },
                      )
                    ]))
          ]),
    );
  }
}
