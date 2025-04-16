import 'package:flutter/material.dart';
import '../models/stat_value.dart';
import 'stat_value_icon.dart';

class PowerIcon extends StatelessWidget {
  final double size;
  final StatValue value;

  const PowerIcon({
    super.key,
    required this.size,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return StatValueIcon(
      svgAsset: 'assets/svg/power.svg',
      value: value,
      size: size,
    );
  }
} 