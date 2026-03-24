import 'package:flutter/material.dart';
import 'package:pocket_union/ui/router.dart';
import 'package:pocket_union/ui/screens/transactions/recurrent/in/widgets/new_recurrent_income_form.dart';
import 'package:pocket_union/ui/widgets/form_title.dart';

class NewRecurrentIncomeScreen extends StatelessWidget {
  const NewRecurrentIncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Programar ingreso'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
              return;
            }
            Navigator.of(context).pushReplacementNamed(AppRoutes.home);
          },
        ),
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            FormTitle(title: 'Programar ingreso recurrente'),
            NewRecurrentIncomeForm(),
          ],
        ),
      ),
    );
  }
}
