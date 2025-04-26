import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'shield_icon.dart';

class ShieldToggleButton extends StatelessWidget {
  final bool isSelected;
  final bool isDead;
  final VoidCallback onPressed;
  final double size;

  const ShieldToggleButton({
    super.key,
    required this.isSelected,
    required this.isDead,
    required this.onPressed,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDead 
        ? Colors.grey.withOpacity(0.3)
        : (isSelected ? AppTheme.highlightColor : Colors.transparent);
    final borderColor = isDead 
        ? Colors.grey 
        : (isSelected ? AppTheme.accentColor : AppTheme.primaryColor);

    return IconButton(
      icon: Stack(
        alignment: Alignment.center,
        children: [
          // Hexagon background
          CustomPaint(
            size: Size(size, size),
            painter: HexagonPainter(
              color: backgroundColor,
              borderColor: borderColor,
              borderWidth: 2,
            ),
          ),
          // Shield icon
          Opacity(
            opacity: isDead ? 0.5 : 1.0,
            child: ShieldIcon(
              size: size * 0.6,
              value: 1,
              color: isDead ? Colors.grey : (isSelected ? Colors.white : AppTheme.primaryColor),
            ),
          ),
        ],
      ),
      onPressed: isDead ? null : onPressed,
      style: IconButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size(size, size),
      ),
    );
  }
}

class HexagonPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double borderWidth;

  HexagonPainter({
    required this.color,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final path = Path();
    final width = size.width;
    final height = size.height;
    final centerX = width / 2;
    final centerY = height / 2;
    final radius = width / 2;

    // Create hexagon points
    for (int i = 0; i < 6; i++) {
      final angle = 2.0 * 3.14159 * i / 6;
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(HexagonPainter oldDelegate) {
    return color != oldDelegate.color ||
           borderColor != oldDelegate.borderColor ||
           borderWidth != oldDelegate.borderWidth;
  }
} 