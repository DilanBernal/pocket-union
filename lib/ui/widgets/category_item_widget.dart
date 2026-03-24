import 'package:flutter/material.dart';
import 'package:pocket_union/domain/models/category.dart';

class CategoryItemWidget extends StatelessWidget {
  const CategoryItemWidget({
    super.key,
    required this.isSelected,
    required this.chipColor,
    required this.category,
    required this.categoryIcon,
    required this.selectedIds,
    required this.onChanged,
  });

  final bool isSelected;
  final Color chipColor;
  final Category category;
  final IconData? categoryIcon;
  final List<String> selectedIds;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isSelected ? 1.06 : 1,
      curve: Curves.easeInExpo,
      duration: const Duration(milliseconds: 160),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: chipColor.withValues(alpha: 0.15),
                    blurRadius: 14,
                    spreadRadius: 1,
                    offset: const Offset(9, 4),
                    blurStyle: BlurStyle.inner,
                  ),
                ]
              : null,
        ),
        child: FilterChip(
          label: Text(category.name),
          selected: isSelected,
          showCheckmark: false,
          selectedColor: chipColor.withValues(alpha: 0.22),
          backgroundColor: chipColor.withValues(alpha: 0),
          side: BorderSide(
            color: isSelected
                ? chipColor.withValues(alpha: 0.9)
                : chipColor.withValues(alpha: 0.45),
          ),
          avatar: categoryIcon != null
              ? Icon(categoryIcon, size: 17, color: chipColor)
              : null,
          labelStyle: TextStyle(
            color: isSelected
                ? chipColor
                : Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
          onSelected: (selected) {
            final updated = List<String>.from(selectedIds);
            if (selected) {
              updated.add(category.id);
            } else {
              updated.remove(category.id);
            }
            onChanged(updated);
          },
        ),
      ),
    );
  }
}
