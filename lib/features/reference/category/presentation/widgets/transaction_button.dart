import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const TransactionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          // Fondo tinturado si está seleccionado, o gris oscuro si no
          color: isSelected
              ? activeColor.withOpacity(0.15)
              : const Color(0xFF241F2D),
          borderRadius: BorderRadius.circular(16),
          // Borde de color
          border: Border.all(
            color: isSelected
                ? activeColor
                : const Color(0xFF6A6482).withOpacity(0.5),
            width: 2.5,
          ),
          // El secreto para el brillo exterior (neón)
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.6),
                    blurRadius: 20.0,
                    spreadRadius: 0,
                    offset: const Offset(0, 0),
                    blurStyle: BlurStyle.outer, // ¡Esto crea el efecto neon!
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.bungee(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
