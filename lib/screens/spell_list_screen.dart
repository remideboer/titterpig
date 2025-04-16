import 'package:flutter/material.dart';
import '../models/character.dart';
import '../models/spell.dart';
import '../theme/app_theme.dart';

class SpellListScreen extends StatelessWidget {
  final Character character;

  const SpellListScreen({
    super.key,
    required this.character,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spells'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: character.spells.length,
        itemBuilder: (context, index) {
          final spell = character.spells[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(
                spell.name,
                style: AppTheme.titleStyle,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cost: ${spell.cost}',
                    style: AppTheme.bodyStyle,
                  ),
                  if (spell.effect.isNotEmpty)
                    Text(
                      spell.effect,
                      style: AppTheme.bodyStyle,
                    ),
                  Text(
                    'Type: ${spell.type}',
                    style: AppTheme.bodyStyle,
                  ),
                ],
              ),
              trailing: Text(
                '${character.availablePower}/${character.powerStat.max}',
                style: AppTheme.bodyStyle.copyWith(
                  color: character.availablePower >= spell.cost
                      ? AppTheme.accentColor
                      : Colors.red,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 