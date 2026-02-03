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

  Future<void> _handleCreateUser() async {}

  Future<void> _createUser(
      Map<String, String> values, UserDaoSqlite userRepo) async {
    final prefs = await SharedPreferences.getInstance();
    final bool isFirst = prefs.getBool('isFirstLaunch') ?? true;
    try {
      final name = values['nombre']!;
      final balance = double.tryParse(values['dinero']!) ?? 0.0;
      if (name.trim() != '' && isFirst == true) {
        final user =
            DomainUser(id: '', fullName: name, balance: balance, inCloud: false);
        var idGenerated = await userRepo.upsertUser(user);
        await prefs.setBool('userId', idGenerated);
        await prefs.setBool('isFirstLaunch', false);
      }
      // await userRepo.getAllUsers();
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
              borderOnForeground: false,
              color: Colors.transparent,
              type: MaterialType.button,
              child: DecoratedBox(
                position: DecorationPosition.background,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Color.fromARGB(255, 116, 11, 218),
                      Color.fromRGBO(251, 0, 204, 1)
                    ]),
                    borderRadius: BorderRadiusGeometry.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SizedBox(
                    width: 300,
                    child: Ink(
                      child: InkWell(
                        splashColor: Colors.blue,
                        onTap: _handleCreateUser,
                        child: Center(
                            child: Text("Crear cuenta",
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: (Theme.of(context)
                                            .textTheme
                                            .titleLarge!
                                            .fontSize ?? 40) *
                                        1.3))),
                      ),
                    ),
                  ),
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
