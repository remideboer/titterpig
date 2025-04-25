import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/character.dart';
import '../models/def_category.dart';
import '../theme/app_theme.dart';
import 'shield_icon.dart';

class StatModifierRow extends StatefulWidget {
  final Character character;
  final double size;
  final DefCategory selectedDefense;
  final Function(DefCategory) onDefenseChanged;
  final VoidCallback onHeal;
  final VoidCallback onTakeDamage;

  const StatModifierRow({
    super.key,
    required this.character,
    required this.size,
    required this.selectedDefense,
    required this.onDefenseChanged,
    required this.onHeal,
    required this.onTakeDamage,
  });

  @override
  State<StatModifierRow> createState() => _StatModifierRowState();
}

class _StatModifierRowState extends State<StatModifierRow> {
  late Character character;
  late double size;
  late DefCategory selectedDefense;
  late Function(DefCategory) onDefenseChanged;
  late VoidCallback onHeal;
  late VoidCallback onTakeDamage;

  @override
  void initState() {
    super.initState();
    character = widget.character;
    size = widget.size;
    selectedDefense = widget.selectedDefense;
    onDefenseChanged = widget.onDefenseChanged;
    onHeal = widget.onHeal;
    onTakeDamage = widget.onTakeDamage;
  }

  void _handleHeal() {
    onHeal();
  }

  void _handleDamage() {
    onTakeDamage();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDead = character.isDead;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Left column - Health buttons
        SizedBox(
          width: screenSize.width * 0.25,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionButton(
                context: context,
                icon: SvgPicture.asset(
                  'assets/svg/health-increase.svg',
                  width: 48,
                  height: 48,
                  colorFilter: const ColorFilter.mode(
                    Colors.green,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: _handleHeal,
                color: Colors.green,
                enabled: !isDead,
              ),
              _buildActionButton(
                context: context,
                icon: SvgPicture.asset(
                  'assets/svg/health-decrease.svg',
                  width: 48,
                  height: 48,
                  colorFilter: const ColorFilter.mode(
                    Colors.red,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: _handleDamage,
                color: Colors.red,
                enabled: !isDead,
              ),
            ],
          ),
        ),
        // Center column - Shield icon
        SizedBox(
          width: screenSize.width * 0.25,
          child: Center(
            child: _buildShieldIcon(context, isDead ? null : character.def, size),
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

  Widget _buildActionButton({
    required BuildContext context,
    required Widget icon,
    required VoidCallback onPressed,
    required Color color,
    bool enabled = true,
  }) {
    return Container(
      height: 80,
      child: Center(
        child: IconButton(
          icon: Opacity(
            opacity: enabled ? 1.0 : 0.5,
            child: icon,
          ),
          onPressed: enabled ? onPressed : () {},
          style: IconButton.styleFrom(
            disabledForegroundColor: Colors.grey,
          ),
        ),
      ),
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
    return IconButton(
      icon: Text(
        label,
        style: TextStyle(
          fontSize: size * 0.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isDead 
              ? Colors.grey 
              : (isSelected ? Colors.white : AppTheme.primaryColor),
        ),
      ),
      onPressed: isDead ? null : () => onDefenseChanged(category),
      style: IconButton.styleFrom(
        backgroundColor: isDead 
            ? Colors.grey.withOpacity(0.3)
            : (isSelected ? AppTheme.highlightColor : Colors.transparent),
        shape: const CircleBorder(),
        side: BorderSide(
          color: isDead 
              ? Colors.grey 
              : (isSelected ? AppTheme.accentColor : AppTheme.primaryColor),
          width: 2,
        ),
        minimumSize: Size(size, size),
        padding: EdgeInsets.zero,
      ),
    );
  }
} 