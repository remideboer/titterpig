import 'package:flutter/material.dart';
import '../models/stat_value.dart';
import 'stat_value_icon.dart';

class HeartIcon extends StatelessWidget {
  final double size;
  final StatValue value;

  const HeartIcon({
    Key? key,
    required this.size,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StatValueIcon(
      svgAsset: 'assets/svg/heart.svg',
      value: value,
      size: size,
    );
  }
} 