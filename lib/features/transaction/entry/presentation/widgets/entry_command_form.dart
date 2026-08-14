import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pocket_union/core/utils/categories_list_provider.dart';
import 'package:pocket_union/core/utils/color_parser.dart';
import 'package:pocket_union/features/reference/domain/enums/category_host.dart';
import 'package:pocket_union/features/transaction/entry/presentation/controllers/entry_command_form.dart';
import 'package:pocket_union/features/transaction/presentation/widgets/category_horizontal_list.dart';
import 'package:pocket_union/features/transaction/presentation/widgets/category_item_widget.dart';
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
    final categories = ref.watch(categoriesByHostProvider(CategoryHost.income));
    final controller = ref.watch(entryCommandFormProvider.notifier);
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
                ),
              ]),
              // onChanged: (value) => setState(() {}),
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

            // RepaintBoundary(
            //   child: categories.isLoading
            //       ? const CircularProgressIndicator()
            //       : categories.hasError
            //       ? Text('Error: ${categories.error}')
            //       : CategoryHorizontalList(
            //           validator: FormBuilderValidators.compose([
            //             FormBuilderValidators.minLength(1),
            //             FormBuilderValidators.required(
            //               errorText: 'Seleccione al menos una categoría',
            //             ),
            //             FormBuilderValidators.maxLength(
            //               5,
            //               errorText: 'Seleccione un máximo de 5 categorías',
            //             ),
            //           ]),
            //           categories: categories.value ?? [],
            //           onChanged: (ids) {},
            //         ),
            // ),
            // CategoryHorizontalList(
            //   validator: FormBuilderValidators.compose([
            //     FormBuilderValidators.minLength(1),
            //     FormBuilderValidators.required(
            //       errorText: 'Seleccione al menos una categoría',
            //     ),
            //     FormBuilderValidators.maxLength(
            //       5,
            //       errorText: 'Seleccione un máximo de 5 categorías',
            //     ),
            //   ]),
            //   categories: categories.value ?? [],
            //   onChanged: (ids) {},
            // ),
            // FormBuilderField<List<String>>(
            //   name: 'categories',

            //   validator: FormBuilderValidators.compose([
            //     FormBuilderValidators.minLength(1),
            //     FormBuilderValidators.required(
            //       errorText: 'Seleccione al menos una categoría',
            //     ),
            //     FormBuilderValidators.maxLength(
            //       5,
            //       errorText: 'Seleccione un máximo de 5 categorías',
            //     ),
            //   ]),
            //   builder: (field) => Text('sdfsdf'),
            // ),
            // FormBuilderField<List<String>>(
            //   name: 'categories',
            //   validator: FormBuilderValidators.compose([
            //     FormBuilderValidators.minLength(1),
            //     FormBuilderValidators.required(
            //       errorText: 'Seleccione al menos una categoría',
            //     ),
            //     FormBuilderValidators.maxLength(
            //       5,
            //       errorText: 'Seleccione un máximo de 5 categorías',
            //     ),
            //   ]),
            //   builder: (field) => SizedBox(
            //     height: 42,
            //     child: Text(''),
            //     // child: ListView.separated(
            //     //   scrollDirection: Axis.horizontal,
            //     //   itemCount: categories.value?.length ?? 0,
            //     //   separatorBuilder: (_, _) => const SizedBox(width: 8),
            //     //   itemBuilder: (context, index) {
            //     //     final category = categories.value![index];
            //     //     final List<String> selectedIds = field.value ?? [];
            //     //     final isSelected = selectedIds.contains(category.id);
            //     //     final chipColor = parseColorFromHex(
            //     //       category.color,
            //     //       fallback: Theme.of(context).colorScheme.primary,
            //     //     );

            //     //     final iconCodePoint = int.tryParse(category.icon ?? '');
            //     //     final categoryIcon = iconCodePoint != null
            //     //         ? IconData(iconCodePoint, fontFamily: 'MaterialIcons')
            //     //         : null;

            //     //     return Text('CategoryItemWidget is commented out for now');
            //     //     // return CategoryItemWidget(
            //     //     //   isSelected: isSelected,
            //     //     //   chipColor: chipColor,
            //     //     //   category: category,
            //     //     //   categoryIcon: categoryIcon,
            //     //     //   selectedIds: selectedIds,
            //     //     //   onChanged: (value) {
            //     //     //     return field.didChange(value);
            //     //     //   },
            //     //     // );
            //     //   },
            //     // ),
            //   ),
            // ),
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

            // FormBuilderSwitch(
            //   name: 'is_received',
            //   initialValue: true,
            //   title: Text(
            //     'Ya se recibio?',
            //     style: Theme.of(context).textTheme.titleSmall,
            //   ),
            // ),

            // Text('Descripción', style: Theme.of(context).textTheme.titleSmall),
            // FormBuilderTextField(name: 'description'),
            // FormBuilderSwitch(
            //   name: 'fixed',
            //   initialValue: false,
            //   title: Text(
            //     'Es fijo?',
            //     style: Theme.of(context).textTheme.titleSmall,
            //   ),
            // ),
            // FormBuilderSwitch(
            //   name: 'planned',
            //   initialValue: false,
            //   title: Text(
            //     'Es planeado?',
            //     style: Theme.of(context).textTheme.titleSmall,
            //   ),
            // ),
            // RepaintBoundary(
            //   child: TextButton(
            //     child: Text('Guardar'),
            //     onPressed: () {
            //       _formKey.currentState?.saveAndValidate();
            //       controller.submit(_formKey.currentState!);
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
