import 'package:flutter/material.dart';
import 'base_value_icon.dart';
import '../theme/app_theme.dart';

class SingleValueIcon extends BaseValueIcon {
  final int value;

  const SingleValueIcon({
    Key? key,
    required String svgAsset,
    required this.value,
    double size = 40,
    Color color = AppTheme.highlightColor,
    TextStyle? textStyle,
  }) : super(
          key: key,
          svgAsset: svgAsset,
          size: size,
          color: color,
          textStyle: textStyle,
        );

  @override
  Widget buildValueText(BuildContext context) {
    return Text(
      value.toString(),
      style: textStyle ?? Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.4,
          ),
    );
  }
} 