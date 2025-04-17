import 'package:flutter/material.dart';
import '../models/spell.dart';
import '../theme/app_theme.dart';
import 'spell_edit_screen.dart';

class SpellsAdminScreen extends StatefulWidget {
  const SpellsAdminScreen({super.key});

  @override
  State<SpellsAdminScreen> createState() => _SpellsAdminScreenState();
}

class _SpellsAdminScreenState extends State<SpellsAdminScreen> {
  void _showSpellForm({Spell? spell}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpellEditScreen(spell: spell),
      ),
    ).then((result) {
      if (result == true) {
        setState(() {});
      }
    });
  }

  void _deleteSpell(Spell spell) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Spell'),
        content: Text('Are you sure you want to delete ${spell.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                Spell.availableSpells.removeWhere((s) => s.name == spell.name);
              });
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Spells'),
      ),
      body: ListView.builder(
        itemCount: Spell.availableSpells.length,
        itemBuilder: (context, index) {
          final spell = Spell.availableSpells[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(spell.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cost: ${spell.cost}'),
                  if (spell.effect.isNotEmpty) Text('Effect: ${spell.effect}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showSpellForm(spell: spell),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteSpell(spell),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSpellForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
} 