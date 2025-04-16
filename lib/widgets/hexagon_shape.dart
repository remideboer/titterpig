import 'package:flutter/material.dart';
import 'dart:math' as math;

class HexagonPainter extends CustomPainter {
  final Color borderColor;
  final Color? fillColor;
  final double borderWidth;

  HexagonPainter({
    this.borderColor = Colors.black,
    this.fillColor,
    this.borderWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = fillColor ?? Colors.transparent
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final path = _createHexagonPath(size);
    
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  Path _createHexagonPath(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;
    final radius = math.min(width, height) / 2;
    final centerX = width / 2;
    final centerY = height / 2;

    path.moveTo(centerX + radius * math.cos(0), centerY + radius * math.sin(0));

    for (int i = 1; i <= 6; i++) {
      final angle = (i * 60) * math.pi / 180;
      path.lineTo(
        centerX + radius * math.cos(angle),
        centerY + radius * math.sin(angle),
      );
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class HexagonContainer extends StatelessWidget {
  final double size;
  final Widget child;
  final Color borderColor;
  final Color? fillColor;
  final double borderWidth;

  const HexagonContainer({
    Key? key,
    required this.size,
    required this.child,
    this.borderColor = Colors.black,
    this.fillColor,
    this.borderWidth = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: HexagonPainter(
          borderColor: borderColor,
          fillColor: fillColor,
          borderWidth: borderWidth,
        ),
        child: Center(child: child),
      ),
    );
  }
} 