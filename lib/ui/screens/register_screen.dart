import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:pocket_union/Dao/sqlite/user_dao_sqlite.dart';
import 'package:pocket_union/domain/models/user.dart';
import 'package:pocket_union/ui/widgets/input_with_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/form_title.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userRepo = context.read<UserDaoSqlite>();
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FormTitle(title: "Registro"),
        InputWithButton(
          onSend: (values) => {_createUser(values, userRepo)},
          fieldNames: ["nombre", "dinero"],
          keyboardTypes: [TextInputType.text, TextInputType.number],
          buttonName: "Registrar tu usuario",
          inputFormatters: [
            [],
            [FilteringTextInputFormatter.digitsOnly]
          ],
        )
      ]
    );
  }

  Future<void> _createUser(Map<String, String> values, UserDaoSqlite userRepo) async {
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
}

