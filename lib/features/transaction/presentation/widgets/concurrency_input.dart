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
    this.formKey,
  });

  final FormFieldValidator<String>? validator;
  final InputDecoration? decoration;
  final String name;
  final ValueChanged<dynamic>? onChanged;
  final GlobalKey<FormBuilderState>? formKey;

  @override
  State<ConcurrencyInput> createState() => _ConcurrencyInputState();
}

class _ConcurrencyInputState extends State<ConcurrencyInput> {
  late final CurrencyTextInputFormatter _formatter;

  @override
  void initState() {
    super.initState();
    _formatter = CurrencyTextInputFormatter.currency(
      symbol: '\$',
      decimalDigits: 2,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: widget.name,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      initialValue: _formatter.formatString('0'),
      inputFormatters: <TextInputFormatter>[_formatter],
      decoration: widget.decoration!,
      validator: FormBuilderValidators.transform((_) {
        return _formatter.getUnformattedValue().toString();
      }, widget.validator!),
      valueTransformer: (value) {
        if (value == null || value.isEmpty) {
          return 0.0;
        }
        final unformatted = _formatter.getUnformattedValue();
        return unformatted;
      },
      onChanged: (value) {
        final unformatted = _formatter.getUnformattedValue();
        widget.formKey?.currentState?.fields[widget.name]?.didChange(
          unformatted.toString(),
        );
        widget.onChanged?.call(unformatted);
      },
    );
  }
}
