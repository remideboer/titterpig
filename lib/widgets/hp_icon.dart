import 'package:flutter/material.dart';
import '../models/stat_value.dart';
import 'stat_value_icon.dart';

class HpIcon extends StatelessWidget {
  final double size;
  final StatValue value;

  const HpIcon({
    super.key,
    required this.size,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return StatValueIcon(
      svgAsset: 'assets/svg/hp.svg',
      value: value,
      size: size,
    );
  }
} 