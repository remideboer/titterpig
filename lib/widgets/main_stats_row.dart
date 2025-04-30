import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/character.dart';
import 'check_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainStatsRow extends ConsumerWidget {
  final Character character;
  final double size;

  const MainStatsRow({
    super.key,
    required this.character,
    this.size = 0.25,
  });

  Widget _buildStatBox(BuildContext context, String label, int value, double width, double height, bool isDead) {
    return GestureDetector(
      onTap: () {
        if (isDead) return;
        // Show check widget for this stat
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => CheckWidget(
            character: character,
            statValue: value,
          ),
        );
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDead ? Colors.grey : AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth = screenWidth * size;
    final boxHeight = boxWidth * 0.75;
    final isDead = character.isDead;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatBox(context, 'VIT', character.vit, boxWidth, boxHeight, isDead),
            _buildStatBox(context, 'ATH', character.ath, boxWidth, boxHeight, isDead),
            _buildStatBox(context, 'WIL', character.wil, boxWidth, boxHeight, isDead),
          ],
        ),
      ],
    );
  }
} 