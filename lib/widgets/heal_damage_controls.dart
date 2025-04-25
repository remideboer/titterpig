import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/character.dart';
import '../theme/app_theme.dart';
import 'heal_damage_input.dart';

class HealDamageControls extends StatefulWidget {
  final Character character;
  final Function(int) onHeal;
  final Function(int) onTakeDamage;

  const HealDamageControls({
    super.key,
    required this.character,
    required this.onHeal,
    required this.onTakeDamage,
  });

  @override
  State<HealDamageControls> createState() => _HealDamageControlsState();
}

class _HealDamageControlsState extends State<HealDamageControls> {
  int _currentAmount = 1;

  void _handleAmountChanged(int amount) {
    if (amount < 1) return;
    setState(() {
      _currentAmount = amount;
    });
  }

  void _handleClear() {
    setState(() {
      _currentAmount = 1;
    });
  }

  void _handleHeal() {
    widget.onHeal(_currentAmount);
    _handleClear();
  }

  void _handleDamage() {
    widget.onTakeDamage(_currentAmount);
    _handleClear();
  }

  Widget _buildActionButton({
    required Widget icon,
    required VoidCallback onPressed,
    required Color color,
    bool enabled = true,
  }) {
    return Container(
      height: 40,
      child: Center(
        child: IconButton(
          icon: Opacity(
            opacity: enabled ? 1.0 : 0.5,
            child: icon,
          ),
          onPressed: enabled ? onPressed : () {},
          style: IconButton.styleFrom(
            disabledForegroundColor: Colors.grey,
            padding: EdgeInsets.zero,
            minimumSize: const Size(40, 40),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDead = widget.character.isDead;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        HealDamageInput(
          value: _currentAmount,
          onValueChanged: _handleAmountChanged,
          onClear: _handleClear,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionButton(
              icon: SvgPicture.asset(
                'assets/svg/health-increase.svg',
                width: 32,
                height: 32,
                colorFilter: const ColorFilter.mode(
                  Colors.green,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: _handleHeal,
              color: Colors.green,
              enabled: !isDead,
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              icon: SvgPicture.asset(
                'assets/svg/health-decrease.svg',
                width: 32,
                height: 32,
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
      ],
    );
  }
} 