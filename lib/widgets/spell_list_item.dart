import 'package:flutter/material.dart';
import '../models/spell.dart';
import '../screens/spell_detail_screen.dart';
import '../theme/app_theme.dart';
import '../utils/snackbar_service.dart';

abstract class SpellActionDecorator {
  Widget decorate(Widget action, Spell spell, BuildContext context);
}

class DefaultSpellActionDecorator implements SpellActionDecorator {
  @override
  Widget decorate(Widget action, Spell spell, BuildContext context) {
    if (action is IconButton) {
      return IconButton(
        icon: action.icon,
        onPressed: action.onPressed,
        color: action.onPressed == null ? Colors.grey : AppTheme.highlightColor,
      );
    }
    return action;
  }
}

class PowerCheckSpellActionDecorator implements SpellActionDecorator {
  final SpellActionDecorator _decorator;

  PowerCheckSpellActionDecorator(this._decorator);

  @override
  Widget decorate(Widget action, Spell spell, BuildContext context) {
    if (action is IconButton) {
      return IconButton(
        icon: action.icon,
        onPressed: action.onPressed == null 
          ? () => SnackBarService.showInsufficientPowerMessage(context)
          : action.onPressed,
        color: action.onPressed == null ? Colors.grey : AppTheme.highlightColor,
      );
    }
    return _decorator.decorate(action, spell, context);
  }
}

class SpellListItemActions extends StatelessWidget {
  final Spell spell;
  final List<Widget> actions;
  final SpellActionDecorator? decorator;

  const SpellListItemActions({
    Key? key,
    required this.spell,
    required this.actions,
    this.decorator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveDecorator = decorator ?? DefaultSpellActionDecorator();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: actions.map((action) => 
        effectiveDecorator.decorate(action, spell, context)
      ).toList(),
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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SpellDetailScreen(spell: spell),
            ),
          );
        },
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