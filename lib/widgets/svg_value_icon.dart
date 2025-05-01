import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';
import '../models/stat_value.dart';

class SvgValueIcon extends StatelessWidget {
  final String svgAsset;
  final StatValue value;
  final double size;
  final Color color;
  final TextStyle? textStyle;

  const SvgValueIcon({
    Key? key,
    required this.svgAsset,
    required this.value,
    this.size = 40,
    this.color = AppTheme.highlightColor,
    this.textStyle,
  }) : super(key: key);

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
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value.toString(),
                style: textStyle ?? Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: size * 0.4,
                    ),
              ),
              Text(
                '/${value.maxString}',
                style: textStyle ?? Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.accentColor,
                      fontSize: size * 0.2,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 