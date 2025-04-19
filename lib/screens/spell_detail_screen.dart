import 'package:flutter/material.dart';
import '../models/spell.dart';
import 'spell_edit_screen.dart';

class SpellDetailScreen extends StatelessWidget {
  final Spell spell;

  const SpellDetailScreen({
    Key? key,
    required this.spell,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(spell.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SpellEditScreen(spell: spell),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(spell.description),
            const SizedBox(height: 16),
            Text(
              'Cost',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(spell.cost.toString()),
          ],
        ),
      ),
    );
  }
} 