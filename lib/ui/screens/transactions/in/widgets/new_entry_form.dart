import 'package:flutter/material.dart';
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
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategoryId;
  bool _isReceived = true; // YO por defecto
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final coupleId = prefs.getString('coupleId');
      final userId = prefs.getString('idUser');

      final dto = NewIncomeDto(
        name: _nameController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        categoryId: _selectedCategoryId ?? '',
        isRecurring: false,
        isReceived: _isReceived,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        coupleId: coupleId,
        // YO = userId, NOSOTROS = null
        userId: _isReceived ? userId : null,
      );

      // Offline-first: intenta el service, fallback al DAO
      try {
        final service = await ref.read(incomeServiceProvider.future);
        await service.createIncome(dto);
      } catch (_) {
        final dao = ref.read(revenueDaoProvider);
        await dao.createIncome(dto);
      }

      ref.invalidate(allIncomesProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingreso creado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Limpiar formulario
      _nameController.clear();
      _amountController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedCategoryId = null;
        _isReceived = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear ingreso: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUnfocus,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Nombre ---
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del ingreso',
                hintText: 'Ej: Salario, Freelance, Regalo',
                prefixIcon: Icon(Icons.label),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // --- Monto ---
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Monto',
                hintText: '0.00',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El monto es requerido';
                }
                final parsed = double.tryParse(value.trim());
                if (parsed == null || parsed <= 0) {
                  return 'Ingresa un monto válido mayor a 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // --- Categoría ---
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                prefixIcon: Icon(Icons.category),
              ),
              items: widget.categories.map((cat) {
                return DropdownMenuItem<String>(
                  value: cat.id,
                  child: Text(cat.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategoryId = value);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Selecciona una categoría';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // --- ¿Quién recibe? ---
            Text(
              '¿Quién recibe el ingreso?',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  label: Text('YO'),
                  icon: Icon(Icons.person),
                ),
                ButtonSegment(
                  value: false,
                  label: Text('NOSOTROS'),
                  icon: Icon(Icons.people),
                ),
              ],
              selected: {_isReceived},
              onSelectionChanged: (selection) {
                setState(() => _isReceived = selection.first);
              },
            ),
            const SizedBox(height: 16),

            // --- Descripción ---
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // --- Submit ---
            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSubmitting ? 'Guardando...' : 'Registrar ingreso'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
