import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';
import '../models/character.dart';
import '../widgets/power_icon.dart';
import '../widgets/stat_value_icon.dart';
import '../widgets/heart_icon.dart';

class SecondaryStatsRow extends StatelessWidget {
  final Character character;
  final double size;

  const SecondaryStatsRow({
    super.key,
    required this.character,
    this.size = 0.25,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final svgStatSize = screenWidth * size;
    final isDead = character.isDead;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            _buildHpAndLifeDiamonds(context, svgStatSize),
            const SizedBox(height: 8)
          ],
        ),
        if (!isDead)
          Opacity(
            opacity: isDead ? 0.5 : 1.0,
            child: PowerIcon(
              value: character.powerStat,
              size: svgStatSize,
            ),
          ),
      ],
    );
  }

  Widget _buildHpAndLifeDiamonds(BuildContext context, double size) {
    final isDead = character.isDead;

    return Stack(
      children: [
        // Main HP and LIFE diamonds
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isDead)
              StatValueIcon(
                svgAsset: 'assets/svg/hp.svg',
                value: character.hpStat,
                size: size,
                color: isDead ? Colors.grey : AppTheme.highlightColor,
              ),
            if (!isDead)
              const SizedBox(width: 8),
            isDead
                ? SvgPicture.asset(
                    'assets/svg/death-skull.svg',
                    width: size,
                    height: size,
                    colorFilter:
                        const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                  )
                : HeartIcon(
                    size: size,
                    value: character.lifeStat,
                  ),
          ],
        ),
        // TEMP HP diamond
        if (character.tempHp > 0 && !isDead)
          Positioned(
            left: size * 0.6,
            top: 0,
            child: _buildTempHpDiamond(context, size * 0.5),
          ),
        // Labels
        if (!isDead)
          Positioned(
            left: -size * 0.5,
            top: size * 0.3,
            child: Transform.rotate(
              angle: -45 * 3.14159 / 180,
              child: Text(
                'HP',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: size * 0.25,
                      color: isDead ? Colors.grey : AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTempHpDiamond(BuildContext context, double size) {
    return Transform.rotate(
      angle: 45 * 3.14159 / 180,
      child: CustomPaint(
        size: Size(size, size),
        painter: DottedBorderPainter(),
        child: Container(
          width: size,
          height: size,
          child: Transform.rotate(
            angle: -45 * 3.14159 / 180,
            child: Center(
              child: Text(
                character.tempHp.toString(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: size * 0.4,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DottedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 5.0;
    final width = size.width;
    final height = size.height;
    final centerX = width / 2;
    final centerY = height / 2;

    // Calculate diamond points
    final top = Offset(centerX, 0);
    final right = Offset(width, centerY);
    final bottom = Offset(centerX, height);
    final left = Offset(0, centerY);

    // Draw top to right
    for (double i = 0; i < 1; i += (dashWidth + dashSpace) / width) {
      final start = Offset(
        top.dx + (right.dx - top.dx) * i,
        top.dy + (right.dy - top.dy) * i,
      );
      final end = Offset(
        top.dx + (right.dx - top.dx) * (i + dashWidth / width),
        top.dy + (right.dy - top.dy) * (i + dashWidth / width),
      );
      canvas.drawLine(start, end, paint);
    }

    // Draw right to bottom
    for (double i = 0; i < 1; i += (dashWidth + dashSpace) / height) {
      final start = Offset(
        right.dx + (bottom.dx - right.dx) * i,
        right.dy + (bottom.dy - right.dy) * i,
      );
      final end = Offset(
        right.dx + (bottom.dx - right.dx) * (i + dashWidth / height),
        right.dy + (bottom.dy - right.dy) * (i + dashWidth / height),
      );
      canvas.drawLine(start, end, paint);
    }

    // Draw bottom to left
    for (double i = 0; i < 1; i += (dashWidth + dashSpace) / width) {
      final start = Offset(
        bottom.dx + (left.dx - bottom.dx) * i,
        bottom.dy + (left.dy - bottom.dy) * i,
      );
      final end = Offset(
        bottom.dx + (left.dx - bottom.dx) * (i + dashWidth / width),
        bottom.dy + (left.dy - bottom.dy) * (i + dashWidth / width),
      );
      canvas.drawLine(start, end, paint);
    }

    // Draw left to top
    for (double i = 0; i < 1; i += (dashWidth + dashSpace) / height) {
      final start = Offset(
        left.dx + (top.dx - left.dx) * i,
        left.dy + (top.dy - left.dy) * i,
      );
      final end = Offset(
        left.dx + (top.dx - left.dx) * (i + dashWidth / height),
        left.dy + (top.dy - left.dy) * (i + dashWidth / height),
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 