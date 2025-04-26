import 'package:flutter/material.dart';
import '../models/character.dart';
import '../models/def_category.dart';
import '../theme/app_theme.dart';
import 'shield_icon.dart';
import 'heal_damage_controls.dart';
import 'shield_toggle_button.dart';

class StatModifierRow extends StatefulWidget {
  final Character character;
  final double size;
  final DefCategory selectedDefense;
  final Function(DefCategory) onDefenseChanged;
  final Function(int) onHeal;
  final Function(int) onTakeDamage;
  final Function(bool) onShieldToggled;

  const StatModifierRow({
    super.key,
    required this.character,
    required this.size,
    required this.selectedDefense,
    required this.onDefenseChanged,
    required this.onHeal,
    required this.onTakeDamage,
    required this.onShieldToggled,
  });

  @override
  State<StatModifierRow> createState() => _StatModifierRowState();
}

class _StatModifierRowState extends State<StatModifierRow> {
  late Character character;
  late double size;
  late DefCategory selectedDefense;
  late Function(DefCategory) onDefenseChanged;
  late Function(int) onHeal;
  late Function(int) onTakeDamage;
  late Function(bool) onShieldToggled;

  @override
  void initState() {
    super.initState();
    character = widget.character;
    size = widget.size;
    selectedDefense = widget.selectedDefense;
    onDefenseChanged = widget.onDefenseChanged;
    onHeal = widget.onHeal;
    onTakeDamage = widget.onTakeDamage;
    onShieldToggled = widget.onShieldToggled;
  }

  @override
  void didUpdateWidget(StatModifierRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDefense != oldWidget.selectedDefense) {
      setState(() {
        selectedDefense = widget.selectedDefense;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDead = character.isDead;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Left column - Health controls
        SizedBox(
          width: screenSize.width * 0.25,
          child: Center(
            child: HealDamageControls(
              character: character,
              onHeal: onHeal,
              onTakeDamage: onTakeDamage,
            ),
          ),
        ),
        // Center column - Shield icon and toggle
        SizedBox(
          width: screenSize.width * 0.25,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildShieldIcon(context, isDead ? null : character.def, size),
              const SizedBox(height: 8),
              ShieldToggleButton(
                isSelected: character.hasShield,
                isDead: isDead,
                onPressed: () => onShieldToggled(!character.hasShield),
                size: size * 0.5,
              ),
            ],
          ),
        ),
        // Right column - Defense circles
        SizedBox(
          width: screenSize.width * 0.25,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDefenseCircle(
                context,
                'H',
                DefCategory.heavy,
                selectedDefense == DefCategory.heavy,
                size * 0.5,
              ),
              const SizedBox(height: 8),
              _buildDefenseCircle(
                context,
                'M',
                DefCategory.medium,
                selectedDefense == DefCategory.medium,
                size * 0.5,
              ),
              const SizedBox(height: 8),
              _buildDefenseCircle(
                context,
                'L',
                DefCategory.light,
                selectedDefense == DefCategory.light,
                size * 0.5,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShieldIcon(BuildContext context, int? value, double size) {
    final isDead = character.isDead;
    return SizedBox(
      height: size * 1.5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: isDead ? 0.5 : 1.0,
            child: ShieldIcon(
              size: size,
              value: value ?? 0,
              color: isDead ? Colors.grey : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'DEF',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: size * 0.18,
                  color: isDead ? Colors.grey : Colors.white,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefenseCircle(
    BuildContext context,
    String label,
    DefCategory category,
    bool isSelected,
    double size,
  ) {
    final isDead = character.isDead;
    final backgroundColor = isDead 
        ? Colors.grey.withOpacity(0.3)
        : (isSelected ? AppTheme.highlightColor : Colors.transparent);
    final textColor = isDead 
        ? Colors.grey 
        : (isSelected ? Colors.white : AppTheme.primaryColor);
    final borderColor = isDead 
        ? Colors.grey 
        : (isSelected ? AppTheme.accentColor : AppTheme.primaryColor);

    return IconButton(
      icon: Text(
        label,
        style: TextStyle(
          fontSize: size * 0.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: textColor,
        ),
      ),
      onPressed: isDead ? null : () => onDefenseChanged(category),
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: const CircleBorder(),
        side: BorderSide(
          color: borderColor,
          width: 2,
        ),
        minimumSize: Size(size, size),
        padding: EdgeInsets.zero,
      ),
    );
  }
} 