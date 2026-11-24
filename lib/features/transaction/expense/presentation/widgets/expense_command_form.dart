import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pocket_union/core/utils/categories_list_provider.dart';
import 'package:pocket_union/features/reference/domain/enums/category_host.dart';
import 'package:pocket_union/features/transaction/expense/presentation/controllers/expense_command_form.controller.dart';
import 'package:pocket_union/features/transaction/presentation/widgets/category_horizontal_list.dart';
import 'package:pocket_union/features/transaction/presentation/widgets/concurrency_input.dart';

class ExpenseCommandForm extends ConsumerStatefulWidget {
  const ExpenseCommandForm({super.key});

  @override
  ConsumerState<ExpenseCommandForm> createState() => _ExpenseCommandFormState();
}

class _ExpenseCommandFormState extends ConsumerState<ExpenseCommandForm> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(expenseCommandFormControllerProvider.notifier);
    final primaryCategoryId = controller.primaryCategoryId;
    ref.listen<AsyncValue>(expenseCommandFormControllerProvider, (prev, next) {
      next.whenOrNull(
        data: (value) {
          if (value == null) return;
          _formKey.currentState?.reset();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Gasto creado')));
          Navigator.pop(context);
        },
        error: (error, _) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $error')));
        },
      );
    });
    final isLoading = ref.watch(expenseCommandFormControllerProvider).isLoading;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          colors: [Color(0xFF1F0D32), Color(0x0f1A1032), Color(0x0f181F32)],
          center: AlignmentGeometry.xy(0, 0),
          radius: 3,
        ),
      ),
      child: FormBuilder(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUnfocus,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Nombre del gasto',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(9)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withAlpha(80),
                        blurRadius: 4,
                        spreadRadius: 6,
                        offset: const Offset(-2, 0),
                      ),
                      BoxShadow(
                        color: Colors.red.withAlpha(100),
                        blurRadius: 4,
                        spreadRadius: 5,
                        offset: const Offset(2, 0),
                      ),
                      BoxShadow(
                        color: Colors.white.withAlpha(80),
                        blurRadius: 1,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: FormBuilderTextField(
                    name: 'name',
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                        errorText: 'El nombre del gasto es requerido',
                      ),
                      FormBuilderValidators.maxLength(
                        50,
                        errorText:
                            'El nombre del gasto no puede exceder 50 caracteres',
                      ),
                    ]),
                    errorBuilder: (_, _) => SizedBox(height: 0),
                    decoration: InputDecoration(
                      labelText: 'Nombre del gasto',
                      fillColor: Color(0xFF0D0614),
                      filled: true,
                      hintText: 'Ej: Supermercado, Renta, Electricidad',
                      prefixIcon: Icon(TablerIcons.label),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(9)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(9)),
                        borderSide: BorderSide(
                          color: Colors.purple.shade700.withAlpha(130),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                'Monto del gasto',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(9)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withAlpha(80),
                        blurRadius: 4,
                        spreadRadius: 6,
                        offset: const Offset(-2, 0),
                      ),
                      BoxShadow(
                        color: Colors.red.withAlpha(100),
                        blurRadius: 4,
                        spreadRadius: 5,
                        offset: const Offset(2, 0),
                      ),
                      BoxShadow(
                        color: Colors.white.withAlpha(80),
                        blurRadius: 1,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ConcurrencyInput(
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
                    decoration: InputDecoration(
                      labelText: 'Monto del gasto',
                      hintText: 'Ej: 1000, 500.50, 2000',
                      prefixIcon: Icon(TablerIcons.currency_dollar),
                      fillColor: Color(0xFF0D0614),
                      filled: true,
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(9)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(9)),
                        borderSide: BorderSide(
                          color: Colors.purple.shade700.withAlpha(130),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                'Fecha del gasto',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(9)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withAlpha(80),
                        blurRadius: 4,
                        spreadRadius: 6,
                        offset: const Offset(-2, 0),
                      ),
                      BoxShadow(
                        color: Colors.red.withAlpha(100),
                        blurRadius: 4,
                        spreadRadius: 5,
                        offset: const Offset(2, 0),
                      ),
                      BoxShadow(
                        color: Colors.white.withAlpha(80),
                        blurRadius: 1,
                        spreadRadius: 1,
                      ),
                    ],
                  ),

                  child: FormBuilderDateTimePicker(
                    name: 'date',
                    validator: FormBuilderValidators.required(
                      errorText: 'La fecha es requerida',
                    ),

                    errorBuilder: (_, _) => SizedBox(height: 0),
                    decoration: InputDecoration(
                      labelText: 'Fecha del gasto',
                      fillColor: Color(0xFF0D0614),
                      filled: true,
                      hintText: 'Ej: Supermercado, Renta, Electricidad',
                      prefixIcon: Icon(TablerIcons.label),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(9)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(9)),
                        borderSide: BorderSide(
                          color: Colors.purple.shade700.withAlpha(130),
                        ),
                      ),
                    ),
                    initialValue: DateTime.now(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Consumer(
                  builder: (context, ref, _) {
                    final categories = ref.watch(
                      categoriesByHostProvider(CategoryHost.expense),
                    );

                    return Column(
                      children: [
                        Text(
                          'Categorías del gasto',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        categories.when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (error, _) => Text(
                            'No se pudieron cargar las categorías: $error',
                          ),
                          data: (items) => CategoryHorizontalList(
                            categories: items,
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(
                                errorText: 'Seleccione al menos una categoría',
                              ),
                              FormBuilderValidators.maxLength(
                                5,
                                errorText:
                                    'Seleccione un máximo de 5 categorías',
                              ),
                            ]),
                            onChanged: (_) {},
                            primaryCategoryId: primaryCategoryId,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Text(
                'Nivel de importancia',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FormBuilderChoiceChips(
                  name: 'importance_level',
                  validator: FormBuilderValidators.required(
                    errorText: 'Seleccione el nivel de importancia',
                  ),
                  options: const [
                    FormBuilderChipOption(value: 1, child: Text('Bajo')),
                    FormBuilderChipOption(value: 2, child: Text('Medio')),
                    FormBuilderChipOption(value: 3, child: Text('Alto')),
                  ],
                  alignment: WrapAlignment.spaceEvenly,
                  initialValue: 1,
                  decoration: InputDecoration(
                    fillColor: Color(0xFF0D0614),
                    filled: true,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(9)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(9)),
                      borderSide: BorderSide(
                        color: Colors.purple.shade700.withAlpha(130),
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                'Descripción',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(9)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withAlpha(80),
                        blurRadius: 4,
                        spreadRadius: 6,
                        offset: const Offset(-2, 0),
                      ),
                      BoxShadow(
                        color: Colors.red.withAlpha(100),
                        blurRadius: 4,
                        spreadRadius: 5,
                        offset: const Offset(2, 0),
                      ),
                      BoxShadow(
                        color: Colors.white.withAlpha(80),
                        blurRadius: 1,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: FormBuilderTextField(
                    name: 'description',
                    validator: FormBuilderValidators.maxLength(
                      200,
                      checkNullOrEmpty: false,
                      errorText:
                          'La descripción no puede exceder 200 caracteres',
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      fillColor: Color(0xFF0D0614),
                      filled: true,
                      hintText: 'Ej: Compra mensual, mantenimiento, etc.',
                      prefixIcon: Icon(TablerIcons.notes),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(9)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(9)),
                        borderSide: BorderSide(color: Color(0x827B1FA2)),
                      ),
                    ),
                    maxLines: 3,
                  ),
                ),
              ),
              Text(
                'Estado del pago',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(9)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withAlpha(80),
                        blurRadius: 4,
                        spreadRadius: 6,
                        offset: const Offset(-2, 0),
                      ),
                      BoxShadow(
                        color: Colors.red.withAlpha(100),
                        blurRadius: 4,
                        spreadRadius: 5,
                        offset: const Offset(2, 0),
                      ),
                      BoxShadow(
                        color: Colors.white.withAlpha(80),
                        blurRadius: 1,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: FormBuilderSwitch(
                    name: 'is_paid',
                    initialValue: true,
                    title: const Text('¿Ya se pagó el gasto?'),
                    decoration: const InputDecoration(
                      hintText: 'Indica si el gasto ya fue pagado',
                      prefixIcon: Icon(TablerIcons.check),
                      fillColor: Color(0xFF0D0614),
                      filled: true,
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(9)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(9)),
                        borderSide: BorderSide(color: Color(0x827B1FA2)),
                      ),
                    ),
                  ),
                ),
              ),
              RepaintBoundary(
                child: ElevatedButton(
                  statesController: isLoading
                      ? WidgetStatesController({WidgetState.disabled})
                      : null,
                  onPressed: () => controller.submit(_formKey.currentState!),
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
