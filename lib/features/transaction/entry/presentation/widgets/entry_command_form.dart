import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pocket_union/core/utils/categories_list_provider.dart';
import 'package:pocket_union/features/reference/domain/enums/category_host.dart';
import 'package:pocket_union/features/transaction/presentation/widgets/category_horizontal_list.dart';
import 'package:pocket_union/features/transaction/presentation/widgets/concurrency_input.dart';

class EntryCommandForm extends ConsumerStatefulWidget {
  const EntryCommandForm({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EntryCommandFormState();
}

class _EntryCommandFormState extends ConsumerState<EntryCommandForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  // List<String> _selectedCategoryIds = [];

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesByHostProvider(CategoryHost.income));
    return FormBuilder(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              'Nombre del gasto',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            FormBuilderTextField(
              name: 'name',
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(
                  errorText: 'El nombre del ingreso es requerido',
                ),
                FormBuilderValidators.maxLength(
                  50,
                  errorText:
                      'El nombre del ingreso no puede exceder 50 caracteres',
                ),
              ]),
              decoration: const InputDecoration(
                labelText: 'Nombre del ingreso',
                hintText: 'Ej: Salario, Freelance, Regalo',
                prefixIcon: Icon(TablerIcons.label),
              ),
            ),
            Text(
              'Monto del ingreso',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            ConcurrencyInput(
              name: 'amount',
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(
                  errorText: 'El monto es requerido',
                ),
                FormBuilderValidators.positiveNumber(
                  errorText: 'El monto debe ser un número válido',
                  checkNullOrEmpty: true,
                ),
              ]),
              onChanged: (value) => setState(() {
                // _formKey.currentState?.fields['amount']?.didChange(value);
              }),
              decoration: const InputDecoration(
                labelText: 'Monto del ingreso',
                hintText: 'Ej: 1000, 500.50, 2000',
                prefixIcon: Icon(TablerIcons.currency_dollar),
              ),
            ),

            Text(
              'Fecha del ingreso',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            FormBuilderDateTimePicker(
              name: 'date',
              validator: FormBuilderValidators.required(
                errorText: 'La fecha es requerida',
              ),
              initialValue: DateTime.now(),
            ),
            Text(
              'Fecha del ingreso',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            categories.isLoading
                ? const CircularProgressIndicator()
                : categories.hasError
                ? Text('Error: ${categories.error}')
                : CategoryHorizontalList(
                    categories: categories.value ?? [],
                    // selectedIds: _selectedCategoryIds,
                    onChanged: (ids) {
                      setState(() => ids);
                    },
                  ),

            Text(
              'A quien le llego',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            FormBuilderChoiceChips(
              name: 'recipent',

              options: [
                FormBuilderChipOption(value: 0, child: Text('Yo')),
                FormBuilderChipOption(value: 1, child: Text('Nosotros')),
                FormBuilderChipOption(value: 2, child: Text('Mi pareja')),
              ],
              alignment: WrapAlignment.spaceAround,
              initialValue: 0,
            ),
          ],
        ),
      ),
    );
  }
}
