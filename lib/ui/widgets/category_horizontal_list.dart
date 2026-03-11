import 'package:flutter/material.dart';
import 'package:pocket_union/domain/models/category.dart';

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
          final chipColor = category.color != null
              ? Color(int.parse(category.color!, radix: 16) + 0xFF000000)
              : Theme.of(context).colorScheme.primary;

          return FilterChip(
            label: Text(category.name),
            selected: isSelected,
            selectedColor: chipColor.withValues(alpha: 0.25),
            checkmarkColor: chipColor,
            avatar: category.icon != null
                ? Text(category.icon!, style: const TextStyle(fontSize: 16))
                : null,
            onSelected: (selected) {
              final updated = List<String>.from(selectedIds);
              if (selected) {
                updated.add(category.id);
              } else {
                updated.remove(category.id);
              }
              onChanged(updated);
            },
          );
        },
      ),
    );
  }
}
