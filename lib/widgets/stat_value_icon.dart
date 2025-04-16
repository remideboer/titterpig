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
    return Row(
      children: [
        // Current value centered in the SVG
        Spacer(),
        Text(
          value.toString(),
          style: textStyle ?? Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.accentColor,
                fontWeight: FontWeight.bold,
                fontSize: size * 0.4,
              ),
        ),
        // Max value positioned lower but centered horizontally
     Text(
              '/${value.maxString}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.accentColor.withAlpha(179), // 0.7 * 255 ≈ 179
                    fontSize: size * 0.2,
                  ),
            ),
      Spacer()
      ],
    );
  }
} 