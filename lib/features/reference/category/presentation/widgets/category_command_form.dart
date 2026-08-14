import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pocket_union/core/enums/sync_status.dart';
import 'package:pocket_union/core/utils/logger_provider.dart';
import 'package:pocket_union/features/reference/category/dtos/category_ins_dto.dart';
import 'package:pocket_union/features/reference/category/dtos/category_upd_dto.dart';
import 'package:pocket_union/features/reference/category/presentation/controller/category_command_controller.dart';
import 'package:pocket_union/features/reference/category/presentation/widgets/category_icon_tile.dart';
import 'package:pocket_union/features/reference/category/presentation/widgets/category_list_item.dart';
import 'package:pocket_union/features/reference/category/presentation/widgets/transaction_type_selector.dart';
import 'package:pocket_union/features/reference/domain/enums/category_host.dart';

class CategoryCommandForm extends ConsumerStatefulWidget {
  final String? categoryId;
  const CategoryCommandForm({super.key, this.categoryId});

  @override
  ConsumerState<CategoryCommandForm> createState() =>
      _CategoryCommandFormState();
}

class _CategoryCommandFormState extends ConsumerState<CategoryCommandForm> {
  IconData? _selectedIcon;
  Color? _selectedColor;

  final _formKey = GlobalKey<FormBuilderState>();

  static final Set<IconData> _availableIcons = {
    TablerIcons.briefcase_filled,
    TablerIcons.gift_card_filled,
    TablerIcons.tag_filled,
    TablerIcons.star_filled,
    TablerIcons.currency_dollar,
    TablerIcons.building_bank,
    TablerIcons.pig_money,
    TablerIcons.trending_up,
    TablerIcons.shopping_cart,
    TablerIcons.tools_kitchen_2,
    TablerIcons.gas_station,
    TablerIcons.home,
    TablerIcons.car,
    TablerIcons.plane_tilt,
    TablerIcons.school,
    TablerIcons.clipboard_heart,
    TablerIcons.device_gamepad,
    TablerIcons.paw,
    TablerIcons.hanger,
    TablerIcons.device_mobile,
    TablerIcons.vinyl,
    TablerIcons.ambulance,
    TablerIcons.beer_filled,
    TablerIcons.glass,
    TablerIcons.flask,
    TablerIcons.pencil,
    TablerIcons.notebook,
    TablerIcons.shoe,
    TablerIcons.chess_knight,
    TablerIcons.building_store,
    TablerIcons.backpack,
    TablerIcons.shovel_pitchforks,
    TablerIcons.camera,
    TablerIcons.bike,
  };

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

  Future<void> handleSubmit() async {
    if (!mounted) return;
    _formKey.currentState?.saveAndValidate();
    if (widget.categoryId != null) {
      await onEdit();
      return;
    }
    await onCreate();
  }

  Future<void> onCreate() async {
    if (!(_formKey.currentState?.isValid ?? false)) {
      return;
    }
    try {
      final command = CategoryInsDto(
        name: _formKey.currentState?.fields['category_name']!.value,
        host: _formKey.currentState?.fields['transaction_type']!.value == 1
            ? CategoryHost.expense
            : CategoryHost.income,
        icon:
            _selectedIcon?.codePoint.toString() ??
            TablerIcons.currency_dollar.codePoint.toString(),
        color: _colorToHex(_selectedColor ?? Colors.blue),
        syncStatuss: SyncStatus.pendingCreate,
      );
      final controller = ref.read(categoryCommandControllerProvider.notifier);
      await controller.createCategory(command);
    } catch (e) {
      final logger = ref.read(loggerProvider);
      logger.error('Error creating category', error: e);
    }
  }

  Future<void> onEdit() async {
    if (!(_formKey.currentState?.isValid ?? false)) {
      return;
    }
    try {
      final command = CategoryUpdDto(
        id: widget.categoryId!,
        name: _formKey.currentState?.fields['category_name']!.value,
        host: _formKey.currentState?.fields['transaction_type']!.value == 1
            ? CategoryHost.expense
            : CategoryHost.income,
        icon:
            _selectedIcon?.codePoint.toString() ??
            TablerIcons.currency_dollar.codePoint.toString(),
        color: _colorToHex(_selectedColor ?? Colors.blue),
      );
      final controller = ref.read(categoryCommandControllerProvider.notifier);
      await controller.updateCategory(command);
    } catch (e) {
      final logger = ref.read(loggerProvider);
      logger.error('Error updating category', error: e);
    }
  }

  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  @override
  void initState() {
    _selectedIcon = _availableIcons.first;
    _selectedColor = _availableColors.first;
    super.initState();
    if (widget.categoryId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final controller = ref.read(categoryCommandControllerProvider.notifier);
        controller.getCategoryById(widget.categoryId!).then((category) {
          if (category != null) {
            setState(() {
              _selectedIcon = category.icon != null
                  ? IconData(
                      int.parse(category.icon!),
                      fontFamily: 'TablerIcons',
                    )
                  : _availableIcons.first;
              _selectedColor = category.color != null
                  ? Color(
                      int.parse(category.color!.substring(1), radix: 16) +
                          0xFF000000,
                    )
                  : _availableColors.first;
              _formKey.currentState?.fields['category_name']?.didChange(
                category.name,
              );
              _formKey.currentState?.fields['transaction_type']?.didChange(
                category.categoryHost == CategoryHost.expense ? 1 : 2,
              );
            });
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoryCommandControllerProvider);
    ref.listen(categoryCommandControllerProvider, (_, next) {
      next.whenOrNull(
        data: (result) {
          if (result != null) {
            Navigator.pop(context);
          }
        },
      );
    });
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FormBuilder(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: _formKey,
        child: Column(
          children: [
            Text(
              'Nombre de la categoría',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            FormBuilderTextField(
              name: 'category_name',
              decoration: const InputDecoration(
                hintText: 'Ej: Alimentos, Entretenimiento, Salud',
                border: OutlineInputBorder(
                  gapPadding: 2,
                  borderRadius: BorderRadius.all(Radius.circular(80)),
                ),
                filled: true,
                fillColor: Color.fromARGB(255, 42, 22, 46),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(
                  errorText: 'El nombre de la categoría es obligatorio',
                ),
                FormBuilderValidators.maxLength(
                  50,
                  errorText:
                      'El nombre de la categoría no puede exceder 50 caracteres',
                ),
              ]),
            ),

            // icon
            Text('Icono', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  childAspectRatio: 1,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: _availableIcons.length,
                itemBuilder: (context, index) {
                  final icon = _availableIcons.elementAt(index);
                  final isSelected = _selectedIcon == icon;
                  return CategoryIconTile(
                    icon: icon,
                    isSelected: isSelected,
                    selectedColor: _selectedColor,
                    onTap: () => setState(() => _selectedIcon = icon),
                  );
                },
              ),
            ),
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
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
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
                        ? const Icon(
                            TablerIcons.check,
                            color: Colors.white,
                            size: 20,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
            (_formKey.currentState?.fields['category_name']?.isValid ??
                        false) &&
                    _selectedColor != null &&
                    _selectedIcon != null
                ? Wrap(
                    children: [
                      Text(
                        'Vista previa',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Hero(
                        tag: 'category_item_${widget.categoryId ?? 'new'}',
                        child: CategoryListItem(
                          categoryName:
                              _formKey
                                  .currentState
                                  ?.fields['category_name']
                                  ?.value ??
                              'Nombre de la categoría',
                          selectedColor: _selectedColor,
                          selectedIcon: _selectedIcon,
                        ),
                      ),
                    ],
                  )
                : Container(),
            const SizedBox(height: 24),
            Text(
              'Tipo de transacción',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 42.2,
              ),
              child: TransactionTypeSelector(
                name: 'transaction_type',
                initialValue: 1,
              ),
            ),
            TextButton(
              onPressed: handleSubmit,
              child: widget.categoryId != null
                  ? const Text('Actualizar categoría')
                  : const Text('Crear categoría'),
            ),
          ],
        ),
      ),
    );
  }
}
