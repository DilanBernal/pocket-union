import 'package:flutter/material.dart';
import 'package:pocket_union/Dao/sqlite/user_dao_sqlite.dart';
import 'package:pocket_union/domain/models/user.dart';
import 'package:pocket_union/ui/screens/start/widgets/gradient_overlay_background.dart';
import 'package:pocket_union/ui/widgets/grid_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/form_title.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<StatefulWidget> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
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

  @override
  Widget build(BuildContext context) {
    const colorFocusBorderInput = Color.fromRGBO(56, 49, 70, 1);
    const colorEnabledBorderInput = Color.fromRGBO(45, 41, 53, 1);
    // final userRepo = context.read<UserDaoSqlite>();
    return GridBackground(
      gridColor: const Color.fromRGBO(27, 7, 35, 1),
      strokeWidth: 2,
      child: DecoratedBox(
        decoration: BoxDecoration(
            gradient: RadialGradient(
                center: AlignmentGeometry.topRight,
                focal: AlignmentGeometry.bottomRight,
                focalRadius: 3,
                colors: [Colors.red.shade800, Colors.transparent])),
        child: SafeArea(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUnfocus,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 20,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FormTitle(title: "Registro"),
                  TextFormField(
                    decoration: InputDecoration(
                      fillColor: const Color.fromRGBO(22, 17, 30, 1),
                      filled: true,
                      label: Text("Nombres completos"),
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
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      fillColor: const Color.fromRGBO(22, 17, 30, 1),
                      filled: true,
                      label: Text("Email"),
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
                    decoration: InputDecoration(
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
                  )

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
          ),
        ),
      ),
    );
  }
}
