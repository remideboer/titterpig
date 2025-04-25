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
    const backgroundCircleMultiplier = 1.5;
    const svgSizeModifier = 0.8;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Semi-transparent circle background
          Container(
            width: size * backgroundCircleMultiplier,
            height: size * backgroundCircleMultiplier,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor.withAlpha(255), // 0.2 * 255 ≈ 51
              border: Border.all(
                color: color,
                width: 2,
              ),
            ),
          ),
          Positioned(
              bottom: 0,
              top:0,
              child:
          SvgPicture.asset(
            svgAsset,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            placeholderBuilder: (context) => const CircularProgressIndicator(),
            semanticsLabel: 'Icon',
            width: size * svgSizeModifier,
            height: size * svgSizeModifier,
          )
          ),
          Positioned(
              child:
          buildValueText(context))
          ,
        ],
      ),
    );
  }
} 