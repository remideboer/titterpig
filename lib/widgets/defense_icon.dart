import 'package:flutter/material.dart';
import 'single_value_icon.dart';
import '../theme/app_theme.dart';
import '../models/def_category.dart';

class DefenseIcon extends StatelessWidget {
  final double size;
  final int value;
  final Color? color;
  final DefCategory defCategory;

  const DefenseIcon({
    super.key,
    required this.size,
    required this.value,
    this.color,
    this.defCategory = DefCategory.none,
  });

  String _getSvgAsset() {
    switch (defCategory) {
      case DefCategory.none:
        return 'assets/svg/armor-none.svg';
      case DefCategory.light:
        return 'assets/svg/armor-light.svg';
      case DefCategory.medium:
        return 'assets/svg/armor-medium.svg';
      case DefCategory.heavy:
        return 'assets/svg/armor-heavy.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleValueIcon(
      svgAsset: _getSvgAsset(),
      value: value,
      size: size,
      color: color ?? AppTheme.highlightColor,
    );
  }
} 