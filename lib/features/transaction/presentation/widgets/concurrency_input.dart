import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class ConcurrencyInput extends StatefulWidget {
  const ConcurrencyInput({
    super.key,
    this.validator,
    this.decoration,
    required this.name,
    this.onChanged,
  });

  final FormFieldValidator<String>? validator;
  final InputDecoration? decoration;
  final String name;
  final ValueChanged<dynamic>? onChanged;

  @override
  State<ConcurrencyInput> createState() => _ConcurrencyInputState();
}

class _ConcurrencyInputState extends State<ConcurrencyInput> {
  final CurrencyTextInputFormatter _formatter =
      CurrencyTextInputFormatter.currency(
        // locale: 'es_COP',
        symbol: '\$',
        decimalDigits: 2,
      );
  @override
  Widget build(BuildContext context) {
    return FormBuilderField<num>(
      name: widget.name,
      initialValue: 0.0 as num,
      builder: (field) => TextFormField(
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (value) {
          final unformatted = _formatter.getUnformattedValue();
          widget.onChanged?.call(unformatted);
          field.didChange(unformatted);
        },
        validator: FormBuilderValidators.transform((_) {
          final unformatted = _formatter.getUnformattedValue();
          return unformatted.toString();
        }, widget.validator ?? FormBuilderValidators.compose([])),
        inputFormatters: <TextInputFormatter>[_formatter],
        decoration: widget.decoration,
      ),
    );
  }
}
