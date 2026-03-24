import 'package:flutter/material.dart';
import 'package:pocket_union/core/services/util/color_parser.dart';
import 'package:pocket_union/domain/models/category.dart';
import 'package:pocket_union/ui/widgets/category_item_widget.dart';

class CategoryHorizontalList extends StatelessWidget {
  final List<Category> categories;
  final List<String> selectedIds;
  final ValueChanged<List<String>> onChanged;

  const CategoryHorizontalList({
    super.key,
    required this.categories,
    required this.selectedIds,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('No hay categorías disponibles'),
      );
    }

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
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
            onChanged: onChanged,
          );
        },
      ),
    );
  }
}
