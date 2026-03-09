import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/core/providers/data_local_providers.dart';
import 'package:pocket_union/domain/enum/category_host.dart';
import 'package:pocket_union/dto/new_category_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewCategoryForm extends ConsumerStatefulWidget {
  const NewCategoryForm({super.key});

  @override
  ConsumerState<NewCategoryForm> createState() => _NewCategoryFormState();
}

class _NewCategoryFormState extends ConsumerState<NewCategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  CategoryHost _selectedHost = CategoryHost.income;
  IconData? _selectedIcon;
  Color? _selectedColor;
  bool _isSubmitting = false;

  static const List<IconData> _availableIcons = [
    Icons.work,
    Icons.card_giftcard,
    Icons.sell,
    Icons.star,
    Icons.attach_money,
    Icons.account_balance,
    Icons.savings,
    Icons.trending_up,
    Icons.shopping_cart,
    Icons.restaurant,
    Icons.local_gas_station,
    Icons.home,
    Icons.directions_car,
    Icons.flight,
    Icons.school,
    Icons.health_and_safety,
    Icons.sports_esports,
    Icons.pets,
    Icons.checkroom,
    Icons.phone_android,
  ];

  static const List<Color> _availableColors = [
    Color(0xFFF44336),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFF673AB7),
    Color(0xFF3F51B5),
    Color(0xFF2196F3),
    Color(0xFF009688),
    Color(0xFF4CAF50),
    Color(0xFF8BC34A),
    Color(0xFFFF9800),
    Color(0xFFFF5722),
    Color(0xFF795548),
  ];

  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedIcon == null) {
      _showSnackBar('Selecciona un icono para la categoría');
      return;
    }
    if (_selectedColor == null) {
      _showSnackBar('Selecciona un color para la categoría');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final coupleId = prefs.getString('coupleId');

      final dto = NewCategoryDto(
        name: _nameController.text.trim(),
        host: _selectedHost,
        coupleId: coupleId,
        icon: _selectedIcon!.codePoint.toString(),
        color: _colorToHex(_selectedColor!),
        shortDescription: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      try {
        final service = await ref.read(categoryServiceProvider.future);
        await service.createCategory(dto);
      } catch (_) {
        final dao = ref.read(categoryDaoProvider);
        await dao.createCategory(dto);
      }

      ref.invalidate(incomeCategoriesProvider);
      ref.invalidate(allCategoriesProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Categoría creada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error al crear la categoría: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
            if (_selectedIcon != null && _selectedColor != null)
              _buildPreview(),
            const SizedBox(height: 16),

            // --- Nombre ---
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la categoría',
                hintText: 'Ej: Salario, Comida, Transporte',
                prefixIcon: Icon(Icons.label),
              ),
              maxLength: 50,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es requerido';
                }
                if (value.trim().length < 2) {
                  return 'Mínimo 2 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // --- Tipo ---
            Text(
              'Tipo de categoría',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<CategoryHost>(
              segments: const [
                ButtonSegment(
                  value: CategoryHost.income,
                  label: Text('Ingreso'),
                  icon: Icon(Icons.arrow_downward, color: Colors.green),
                ),
                ButtonSegment(
                  value: CategoryHost.expense,
                  label: Text('Gasto'),
                  icon: Icon(Icons.arrow_upward, color: Colors.red),
                ),
              ],
              selected: {_selectedHost},
              onSelectionChanged: (s) =>
                  setState(() => _selectedHost = s.first),
            ),
            const SizedBox(height: 24),

            // --- Icono ---
            Text('Icono', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableIcons.map((icon) {
                final isSelected = _selectedIcon == icon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (_selectedColor ?? Theme.of(context).primaryColor)
                                .withAlpha(50)
                          : Colors.grey.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(
                              color:
                                  _selectedColor ??
                                  Theme.of(context).primaryColor,
                              width: 2,
                            )
                          : null,
                    ),
                    child: Icon(
                      icon,
                      color: isSelected
                          ? (_selectedColor ?? Theme.of(context).primaryColor)
                          : Colors.grey,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // --- Color ---
            Text('Color', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _availableColors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withAlpha(150),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // --- Descripción ---
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                hintText: 'Breve descripción de la categoría',
                prefixIcon: Icon(Icons.notes),
              ),
              maxLength: 120,
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
              label: Text(_isSubmitting ? 'Guardando...' : 'Crear categoría'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: _selectedColor!.withAlpha(30),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _selectedColor!.withAlpha(100)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_selectedIcon, color: _selectedColor, size: 32),
            const SizedBox(width: 12),
            Text(
              _nameController.text.isEmpty
                  ? 'Vista previa'
                  : _nameController.text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _selectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
