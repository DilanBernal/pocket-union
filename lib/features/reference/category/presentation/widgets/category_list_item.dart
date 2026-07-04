import 'package:flutter/material.dart';

class CategoryListItem extends StatelessWidget {
  final Color _selectedColor;
  final IconData? _selectedIcon;
  final String categoryName;
  const CategoryListItem({
    super.key,
    Color? selectedColor,
    IconData? selectedIcon,
    required this.categoryName,
  }) : _selectedColor = selectedColor ?? const Color(0xFF2B162F),
       _selectedIcon = selectedIcon;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Container(
            width: constraints.maxWidth * 0.8,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              // color: Color.fromARGB(255, 255, 255, 255),
              color: Color(0xFF2B162F),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _selectedColor.withAlpha(150)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _selectedColor.withAlpha(20),
                    shape: BoxShape.circle,
                    border: Border.all(color: _selectedColor.withAlpha(200)),
                  ),
                  child: Icon(_selectedIcon, color: _selectedColor),
                ),
                const SizedBox(width: 12),
                Text(
                  categoryName,
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
      },
    );
  }
}
