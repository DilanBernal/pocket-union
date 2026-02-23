import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/core/providers.dart';
import 'package:pocket_union/domain/models/category.dart';
import 'package:pocket_union/dto/new_income_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewEntryForm extends ConsumerStatefulWidget {
  final List<Category> categories;

  const NewEntryForm({super.key, required this.categories});

  @override
  ConsumerState<NewEntryForm> createState() => _NewEntryFormState();
}

class _NewEntryFormState extends ConsumerState<NewEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isReceived = true;
  Category? _selectedCategory;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una categoría')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('idUser') ?? '';

      final dto = NewIncomeDto(
        name: _nameController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        importanceLevel: 3,
        categoryId: _selectedCategory!.id,
        isRecurring: false,
        isReceived: _isReceived,
        userRecipientId: userId,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
      );

      final incomeService = await ref.read(incomeServiceProvider.future);
      await incomeService.createIncome(dto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entrada registrada correctamente')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUnfocus,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Amount field (required)
          TextFormField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            decoration: const InputDecoration(
              labelText: '¿Cuánto entró? *',
              prefixText: '\$ ',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El monto es obligatorio';
              }
              final amount = double.tryParse(value.trim());
              if (amount == null || amount <= 0) {
                return 'Ingresa un monto válido mayor a cero';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Name field (required)
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre de la entrada *',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El nombre es obligatorio';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Received by switch (required)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('¿Solo yo lo recibí?'),
              Switch(
                value: _isReceived,
                onChanged: (value) => setState(() => _isReceived = value),
              ),
            ],
          ),
          Text(
            _isReceived ? 'Solo yo lo recibí' : 'Ambos lo recibimos',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),

          // Category dropdown (required)
          DropdownButtonFormField<Category>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Categoría *',
            ),
            items: widget.categories
                .map(
                  (cat) => DropdownMenuItem<Category>(
                    value: cat,
                    child: Text(cat.name),
                  ),
                )
                .toList(),
            onChanged: (cat) => setState(() => _selectedCategory = cat),
            validator: (value) =>
                value == null ? 'Selecciona una categoría' : null,
          ),
          const SizedBox(height: 16),

          // Description field (optional)
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Descripción (opcional)',
            ),
          ),
          const SizedBox(height: 24),

          // Submit button
          ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Agregar entrada'),
          ),
        ],
      ),
    );
  }
}
