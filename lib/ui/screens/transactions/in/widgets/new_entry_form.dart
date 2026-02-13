import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewEntryForm extends ConsumerStatefulWidget {
  const NewEntryForm({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewEntryFormState();
}

class _NewEntryFormState extends ConsumerState<NewEntryForm> {
  @override
  Widget build(BuildContext context) {
    return Form(
        child: Column(
      children: [
        Text("Nombre de el ingreso"),
        TextFormField(),
        Text("¿Cuanto entro?"),
        TextFormField(),
        Switch(
            value: false,
            onChanged: (value) {
              debugPrint(value.toString());
              value = !value;
            }),
        CupertinoSwitch(value: true, onChanged: (_) {})
      ],
    ));
  }
}
