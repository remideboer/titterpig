import 'package:flutter/material.dart';
import 'single_value_icon.dart';
import '../theme/app_theme.dart';

class DefenseIcon extends StatelessWidget {
  final double size;
  final int value;
  final Color? color;

  const DefenseIcon({
    super.key,
    required this.size,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SingleValueIcon(
      svgAsset: 'assets/svg/armor-heavy.svg',
      value: value,
      size: size,
      color: color ?? AppTheme.highlightColor,
    );
  }
} 