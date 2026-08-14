import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_union/core/utils/color_parser.dart';
import 'package:pocket_union/features/reference/domain/entities/category_entity.dart';
import 'package:pocket_union/features/transaction/presentation/widgets/category_item_widget.dart';

class CategoryHorizontalList extends ConsumerWidget {
  final List<CategoryEntity> categories;
  final ValueChanged<List<String>> onChanged;
  final FormFieldValidator<List<String>>? validator;

  const CategoryHorizontalList({
    super.key,
    required this.categories,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('No hay categorías disponibles'),
      );
    }

    return FormBuilderField<List<String>>(
      name: 'categories',
      onChanged: (value) {
        onChanged(value ?? []);
      },
      validator: validator,
      builder: (field) => SizedBox(
        height: 42,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final category = categories[index];
            final List<String> selectedIds = field.value ?? [];
            final isSelected = selectedIds.contains(category.id);
            final chipColor = parseColorFromHex(
              category.color,
              fallback: Theme.of(context).colorScheme.primary,
            );

            final iconCodePoint = int.tryParse(category.icon ?? '');
            final categoryIcon = iconCodePoint != null
                ? IconData(iconCodePoint, fontFamily: 'MaterialIcons')
                : null;

            return CategoryItemWidget(
              isSelected: isSelected,
              chipColor: chipColor,
              category: category,
              categoryIcon: categoryIcon,
              selectedIds: selectedIds,
              onChanged: (value) {
                return field.didChange(value);
              },
            );
          },
        ),
      ),
    );
  }
}
