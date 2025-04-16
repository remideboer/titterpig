import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

abstract class BaseValueIcon extends StatelessWidget {
  final String svgAsset;
  final double size;
  final Color color;
  final TextStyle? textStyle;

  const BaseValueIcon({
    super.key,
    required this.svgAsset,
    this.size = 40,
    this.color = AppTheme.highlightColor,
    this.textStyle,
  });

  @protected
  Widget buildValueText(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            svgAsset,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            placeholderBuilder: (context) => const CircularProgressIndicator(),
            semanticsLabel: 'Icon',
            width: size,
            height: size,
          ),
          buildValueText(context),
        ],
      ),
    );
  }
} 