import 'package:flutter/material.dart';

class GridBackground extends StatelessWidget {
  final Widget child;
  final Color gridColor;
  final double gridSize;
  final double strokeWidth;

  const GridBackground({
    super.key,
    required this.child,
    this.gridColor = Colors.grey,
    this.gridSize = 40.0,
    this.strokeWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CustomPaint(
        painter: GridPainter(
          gridColor: gridColor,
          gridSize: gridSize,
          strokeWidth: strokeWidth,
        ),
        child: child,
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final Color gridColor;
  final double gridSize;
  final double strokeWidth;

  GridPainter({
    required this.gridColor,
    required this.gridSize,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Dibujar líneas verticales
    for (double i = 0; i < size.width; i += gridSize) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    // Dibujar líneas horizontales
    for (double i = 0; i < size.height; i += gridSize) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
