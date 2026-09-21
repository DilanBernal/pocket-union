import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pocket_union/core/utils/color_parser.dart';
import 'package:pocket_union/features/reference/domain/entities/category_entity.dart';
import 'package:pocket_union/features/transaction/presentation/widgets/category_item_widget.dart';

class CategoryHorizontalList extends StatefulWidget {
  final List<CategoryEntity> categories;
  final ValueChanged<List<String>> onChanged;
  final FormFieldValidator<List<String>>? validator;
  final ValueChanged<String?> onPrimaryCategoryChanged;

  const CategoryHorizontalList({
    super.key,
    required this.categories,
    required this.onChanged,
    this.validator,
    required this.onPrimaryCategoryChanged,
  });

  @override
  State<CategoryHorizontalList> createState() => _CategoryHorizontalListState();
}

class _CategoryHorizontalListState extends State<CategoryHorizontalList> {
  CategoryEntity? primaryCategory;

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<List<String>>(
      name: 'categories',
      onChanged: (value) {
        widget.onChanged(value ?? []);
        widget.onPrimaryCategoryChanged(primaryCategory?.id);
      },
      validator: widget.validator,
      builder: (field) {
        if (widget.categories.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('No hay categorías disponibles'),
          );
        }

        return SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            addRepaintBoundaries: true,
            itemCount: widget.categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final category = widget.categories[index];
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
                onChanged: field.didChange,
                onLongPress: () {
                  if (!selectedIds.contains(category.id)) return;
                  setState(() {
                    primaryCategory = category;
                  });
                },
                isPrimary: isPrimaryCategory(category, selectedIds),
              );
            },
          ),
        );
      },
    );
  }

  bool isPrimaryCategory(CategoryEntity category, List<String> selectedIds) {
    if (!selectedIds.contains(category.id)) return false;
    if (primaryCategory == null) return selectedIds.first == category.id;

    return primaryCategory?.id == category.id;
  }
}
