import 'package:flutter/material.dart';
import '../models/spell.dart';
import '../screens/spell_detail_screen.dart';
import '../widgets/hexagon_cost.dart';
import '../theme/app_theme.dart';

class SpellListItemActions extends StatelessWidget {
  final Spell spell;
  final List<Widget> actions;

  const SpellListItemActions({
    Key? key,
    required this.spell,
    required this.actions,
  }) : super(key: key);

  void _showInsufficientPowerMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Insufficient power to cast this spell'),
        backgroundColor: Colors.orange[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: actions.map((action) {
        if (action is IconButton) {
          return IconButton(
            icon: action.icon,
            onPressed: action.onPressed == null 
              ? () => _showInsufficientPowerMessage(context)
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
  final SpellListItemActions actions;
  final bool showDieCount;

  const SpellListItem({
    Key? key,
    required this.spell,
    required this.actions,
    this.showDieCount = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        children: [
          // Left side - Cost in hexagon
          HexagonCost(
            cost: spell.cost,
            backgroundColor: AppTheme.primaryColor,
            borderColor: AppTheme.highlightColor,
            textColor: Colors.white,
          ),
          const SizedBox(width: 12),
          
          // Middle - Spell details
          Expanded(
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SpellDetailScreen(spell: spell),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spell.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.highlightColor,
                    ),
                  ),
                  if (spell.description.isNotEmpty)
                    Text(
                      spell.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.highlightColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Row(
                    children: [
                      Text(
                        spell.type,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.highlightColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        spell.range,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.highlightColor,
                        ),
                      ),
                      if (showDieCount && spell.effectValue != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${spell.effectValue!.count}d6',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.highlightColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Right side - Actions
          actions,
        ],
      ),
    );
  }
} 