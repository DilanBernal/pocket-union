import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pocket_union/core/utils/categories_list_provider.dart';
import 'package:pocket_union/features/reference/domain/enums/category_host.dart';
import 'package:pocket_union/features/transaction/entry/presentation/controllers/entry_command_form.dart';
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

  @override
  Widget build(BuildContext context) {
    // final controller = ref.watch(EntryCommandFormProvider.notifier);
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
              formKey: _formKey,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(
                  errorText: 'El monto es requerido',
                ),
                FormBuilderValidators.positiveNumber(
                  errorText: 'El monto debe ser un número válido',
                ),
              ]),
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
            Consumer(
              builder: (context, ref, _) {
                final categories = ref.watch(
                  categoriesByHostProvider(CategoryHost.income),
                );

                return Column(
                  children: [
                    Text(
                      'Categorías del ingreso',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    categories.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, _) =>
                          Text('No se pudieron cargar las categorías: $error'),
                      data: (items) => CategoryHorizontalList(
                        categories: items,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.minLength(1),
                          FormBuilderValidators.required(
                            errorText: 'Seleccione al menos una categoría',
                          ),
                          FormBuilderValidators.maxLength(
                            5,
                            errorText: 'Seleccione un máximo de 5 categorías',
                          ),
                        ]),
                        onChanged: (_) {},
                      ),
                    ),
                  ],
                );
              },
            ),
            Text(
              'A quien le llego',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            FormBuilderChoiceChips(
              name: 'recipient',
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(
                  errorText: 'Seleccione a quien le llego el ingreso',
                ),
                FormBuilderValidators.range(
                  0,
                  2,
                  errorText: 'Seleccione una opción válida',
                ),
              ]),
              options: [
                FormBuilderChipOption(value: 0, child: Text('Yo')),
                FormBuilderChipOption(value: 1, child: Text('Nosotros')),
                FormBuilderChipOption(value: 2, child: Text('Mi pareja')),
              ],
              alignment: WrapAlignment.spaceAround,
              initialValue: 0,
            ),

            RepaintBoundary(
              child: TextButton(
                child: Text('Guardar'),
                onPressed: () {
                  _formKey.currentState?.saveAndValidate();
                  // _formKey.su();
                  final value = _formKey.currentState?.fields['amount']?.value;
                  print('Amount value: $value');
                  _formKey.currentState?.saveAndValidate();
                  // controller.submit(_formKey.currentState!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
