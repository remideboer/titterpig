import 'package:flutter/material.dart';
import '../models/stat_value.dart';
import 'base_value_icon.dart';
import '../theme/app_theme.dart';

class StatValueIcon extends BaseValueIcon {
  final StatValue value;

  const StatValueIcon({
    super.key,
    required super.svgAsset,
    required this.value,
    super.size,
    super.color,
    super.textStyle,
  });

  @override
  Widget buildValueText(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Current value centered in the SVG
        Text(
          value.toString(),
          style: textStyle ?? Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: size * 0.4,
              ),
        ),
        // Max value positioned lower but centered horizontally
        Positioned(
          bottom: 0, // Position lower than before
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              '/${value.maxString}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.accentColor.withAlpha(179), // 0.7 * 255 ≈ 179
                    fontSize: size * 0.2,
                  ),
            ),
          ),
        ),
      ],
    );
  }
} 