import 'package:flutter/material.dart';

class CategoryIconTile extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final Color? _selectedColor;
  final Function()? onTap;

  final Color _neonColor = const Color(0xFFE91E63);
  final Color _iconSelectedColor = Colors.white;
  final Color _iconUnselectedColor = Colors.grey;

  Color get glowColor => _selectedColor ?? _neonColor;

  const CategoryIconTile({
    super.key,
    required this.icon,
    required this.isSelected,
    Color? selectedColor,
    this.onTap,
  }) : _selectedColor = selectedColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          builder: (context, t, child) {
            final size = 48 + 4 * t;
            final ct = t.clamp(0.0, 1.0);

            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Color.lerp(const Color(0xFF1B101E), glowColor, ct),
                borderRadius: BorderRadius.circular(12),

                border: Border.all(
                  color: Color.lerp(Colors.white.withAlpha(26), glowColor, ct)!,
                  width: 1 + 1.5 * ct,
                ),
                gradient: RadialGradient(
                  center: const Alignment(-0.6, -0.7),
                  radius: 0.8,
                  colors: [
                    Color.lerp(
                      const Color(0xFF1B101E),
                      Colors.white.withAlpha(128),
                      ct,
                    )!,
                    Color.lerp(
                      const Color(0xFF1B101E),
                      glowColor.withAlpha(75),
                      ct,
                    )!,
                    const Color(0xFF1B101E),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withAlpha((153 * ct).round()),
                    blurRadius: 18.0 * ct,
                    spreadRadius: 0.0,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: Color.lerp(
                    _iconUnselectedColor,
                    _iconSelectedColor,
                    ct,
                  ),
                  size: 28,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
