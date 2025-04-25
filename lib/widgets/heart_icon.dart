import 'package:flutter/material.dart';
import 'package:ttrpg_character_manager/models/stat_value.dart';
import 'package:ttrpg_character_manager/theme/app_theme.dart';
import 'package:ttrpg_character_manager/widgets/stat_value_icon.dart';

class HeartIcon extends StatelessWidget {
  final StatValue value;
  final double size;
  final int tempHpToLife;
  final bool isDead;

  const HeartIcon({
    Key? key,
    required this.value,
    required this.size,
    this.tempHpToLife = 0,
    this.isDead = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        StatValueIcon(
          svgAsset: 'assets/svg/heart.svg',
          value: value,
          size: size,
          color: isDead ? Colors.grey : AppTheme.highlightColor,
        ),
        if (tempHpToLife > 0 && value.current < value.max)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.4,
              height: size * 0.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor,
                border: Border.all(
                  color: AppTheme.highlightColor,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  tempHpToLife.toString(),
                  style: TextStyle(
                    color: AppTheme.valueDisplayColor,
                    fontSize: size * 0.25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
} 