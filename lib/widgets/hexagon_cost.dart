import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class HexagonCost extends StatelessWidget {
  final int cost;
  final double size;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;

  const HexagonCost({
    Key? key,
    required this.cost,
    this.size = 40,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppTheme.primaryColor;
    final txtColor = textColor ?? AppTheme.valueDisplayColor;
    final brdColor = borderColor ?? AppTheme.highlightColor;

    return CustomPaint(
      size: Size(size, size),
      painter: _HexagonPainter(
        backgroundColor: bgColor,
        borderColor: brdColor,
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(
            cost.toString(),
            style: TextStyle(
              color: txtColor,
              fontWeight: FontWeight.bold,
              fontSize: size * 0.4,
            ),
          ),
        ),
      ),
    );
  }
}

class _HexagonPainter extends CustomPainter {
  final Color backgroundColor;
  final Color borderColor;

  _HexagonPainter({
    required this.backgroundColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _createHexagonPath(size);

    // Draw background
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, bgPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(path, borderPaint);
  }

  Path _createHexagonPath(Size size) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (var i = 0; i < 6; i++) {
      final angle = (i * 60) * math.pi / 180;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_HexagonPainter oldDelegate) => 
    backgroundColor != oldDelegate.backgroundColor ||
    borderColor != oldDelegate.borderColor;
} 