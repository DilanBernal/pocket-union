import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:pocket_union/features/reference/category/presentation/widgets/transaction_button.dart';

class TransactionTypeSelector extends StatelessWidget {
  final String name;
  final int initialValue;
  final FormFieldValidator<int>? validator;

  const TransactionTypeSelector({
    super.key,
    required this.name,
    this.initialValue = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<int>(
      name: name,
      initialValue: initialValue,
      validator: validator,
      builder: (FormFieldState<int> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TransactionButton(
                    label: 'INGRESO',
                    icon: TablerIcons.plus,
                    isSelected: field.value == 0,
                    activeColor: const Color(0xFF00E676),
                    onTap: () => field.didChange(0),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TransactionButton(
                    label: 'GASTO',
                    icon: TablerIcons.minus,
                    isSelected: field.value == 1,
                    activeColor: const Color(0xFFE91E63),
                    onTap: () => field.didChange(1),
                  ),
                ),
              ],
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  field.errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}
