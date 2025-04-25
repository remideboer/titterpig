import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/character.dart';

class MainStatsRow extends StatelessWidget {
  final Character character;
  final double size;

  const MainStatsRow({
    super.key,
    required this.character,
    this.size = 0.25,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth = screenWidth * size;
    final boxHeight = boxWidth * 0.75;
    final isDead = character.isDead;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatBox(context, 'VIT', character.vit, boxWidth, boxHeight, isDead),
        _buildStatBox(context, 'ATH', character.ath, boxWidth, boxHeight, isDead),
        _buildStatBox(context, 'WIL', character.wil, boxWidth, boxHeight, isDead),
      ],
    );
  }

  Widget _buildStatBox(BuildContext context, String label, int value, double width, double height, bool isDead) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDead ? Colors.grey : AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDead ? Colors.grey : AppTheme.highlightColor,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (isDead)
            const Icon(
              Icons.block,
              color: Colors.white,
              size: 24,
            )
          else
            Text(
              value.toString(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
        ],
      ),
    );
  }
} 