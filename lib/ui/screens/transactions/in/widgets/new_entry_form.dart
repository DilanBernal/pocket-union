import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/core/providers.dart';
import 'package:pocket_union/domain/models/category.dart';
import 'package:pocket_union/dto/new_income_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewEntryForm extends ConsumerStatefulWidget {
  const NewEntryForm({super.key, required this.categories});

  final List<Category> categories;

  @override
  ConsumerState<NewEntryForm> createState() => _NewEntryFormState();
}

class _NewEntryFormState extends ConsumerState<NewEntryForm> {
  static const int _maxNameLength = 99;

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isReceivedByMe = true;
  String? _selectedCategoryId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('idUser') ?? '';

    if (userId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No se encontró el usuario. Inicia sesión.')),
        );
      }
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final incomeService =
          await ref.read(incomeServiceProvider.future);

      final dto = NewIncomeDto(
        name: _nameController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        categoryId: _selectedCategoryId!,
        isReceived: _isReceivedByMe,
        userId: userId,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      await incomeService.createIncome(dto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entrada registrada correctamente.')),
        );
        _formKey.currentState!.reset();
        _amountController.clear();
        _nameController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedCategoryId = null;
          _isReceivedByMe = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar la entrada: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Amount field (required)
            TextFormField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              decoration: const InputDecoration(
                labelText: '¿Cuánto dinero entró? *',
                prefixText: '\$ ',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El monto es obligatorio';
                }
                final amount = double.tryParse(value.trim());
                if (amount == null || amount <= 0) {
                  return 'Ingresa un monto válido mayor a 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Name field (required)
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nombre de la entrada *',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es obligatorio';
                }
                if (value.trim().length > _maxNameLength) {
                  return 'El nombre no puede superar los $_maxNameLength caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Received by switch (required)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isReceivedByMe ? 'Solo yo lo recibí' : 'Lo recibimos ambos',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Switch(
                  value: _isReceivedByMe,
                  onChanged: (value) =>
                      setState(() => _isReceivedByMe = value),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Category dropdown (required)
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Categoría *',
              ),
              items: widget.categories
                  .map(
                    (cat) => DropdownMenuItem<String>(
                      value: cat.id,
                      child: Text(cat.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _selectedCategoryId = value),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Selecciona una categoría';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description field (optional)
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
              ),
            ),
            const SizedBox(height: 24),

            // Submit button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Registrar entrada'),
            ),
          ],
        ),
      ),
    );
  }
}
