import 'package:flutter/material.dart';
import '../models/spell.dart';
import '../screens/spell_detail_screen.dart';
import '../widgets/hexagon_cost.dart';
import '../theme/app_theme.dart';
import '../utils/snackbar_service.dart';

class SpellListItemActions extends StatelessWidget {
  final Spell spell;
  final List<Widget> actions;

  const SpellListItemActions({
    Key? key,
    required this.spell,
    required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: actions.map((action) {
        if (action is IconButton) {
          return IconButton(
            icon: action.icon,
            onPressed: action.onPressed == null 
              ? () => SnackBarService.showInsufficientPowerMessage(context)
              : action.onPressed,
            color: action.onPressed == null ? Colors.grey : AppTheme.highlightColor,
          );
        }
        return action;
      }).toList(),
    );
  }
}

class SpellListItem extends StatelessWidget {
  final Spell spell;
  final SpellListItemActions? actions;
  final bool disabled;

  const SpellListItem({
    super.key,
    required this.spell,
    this.actions,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: ListTile(
        title: Text(
          spell.name,
          style: TextStyle(
            color: disabled ? Colors.grey : null,
          ),
        ),
        subtitle: Text(
          'Cost: ${spell.cost}',
          style: TextStyle(
            color: disabled ? Colors.grey : null,
          ),
        ),
        trailing: actions,
      ),
    );
  }
} 