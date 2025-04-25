import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'single_value_icon.dart';
import '../theme/app_theme.dart';

class ShieldIcon extends StatelessWidget {
  final double size;
  final int value;
  final Color? color;

  const ShieldIcon({
    super.key,
    required this.size,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SingleValueIcon(
      svgAsset: 'assets/svg/shield.svg',
      value: value,
      size: size,
      color: color ?? AppTheme.highlightColor,
    );
  }
} 