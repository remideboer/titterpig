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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatButton(
          label: 'VIT',
          value: character.vit,
          onTap: () => _showCheckDialog(context, character, character.vit, Stat.vit),
        ),
        _StatButton(
          label: 'ATH',
          value: character.ath,
          onTap: () => _showCheckDialog(context, character, character.ath, Stat.ath),
        ),
        _StatButton(
          label: 'WIL',
          value: character.wil,
          onTap: () => _showCheckDialog(context, character, character.wil, Stat.wil),
        ),
      ],
    );
  }

  void _showCheckDialog(BuildContext context, Character character, int statValue, Stat statType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CheckWidget(
        character: character,
        statValue: statValue,
        statType: statType,
      ),
    );
  }
}

class _StatButton extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onTap;

  const _StatButton({
    Key? key,
    required this.label,
    required this.value,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 0.25 * MediaQuery.of(context).size.width,
        height: 0.75 * (0.25 * MediaQuery.of(context).size.width),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
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
} 