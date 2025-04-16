import 'package:flutter/material.dart';
import 'single_value_icon.dart';

class ShieldIcon extends StatelessWidget {
  final double size;
  final int value;

  const ShieldIcon({
    super.key,
    required this.size,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SingleValueIcon(
      svgAsset: 'assets/svg/shield.svg',
      value: value,
      size: size,
    );
  }
} 