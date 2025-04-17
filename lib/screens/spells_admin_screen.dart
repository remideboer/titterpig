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
  double _maxCost = 10; // Default max cost
  double _currentCostFilter = 10; // Default current filter

  @override
  void initState() {
    super.initState();
    _calculateMaxCost();
  }

  void _calculateMaxCost() {
    if (Spell.availableSpells.isNotEmpty) {
      setState(() {
        _maxCost = Spell.availableSpells.map((s) => s.cost.toDouble()).reduce((a, b) => a > b ? a : b);
        _currentCostFilter = _maxCost;
      });
    }
  }

  List<Spell> _getFilteredSpells() {
    return Spell.availableSpells.where((spell) => spell.cost <= _currentCostFilter).toList();
  }

  void _showSpellForm({Spell? spell}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpellEditScreen(spell: spell),
      ),
    ).then((result) {
      if (result == true) {
        setState(() {
          _calculateMaxCost();
        });
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
                _calculateMaxCost();
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
      body: Column(
        children: [
          // Cost filter slider
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter by Cost: ${_currentCostFilter.toInt()}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('0'),
                    Expanded(
                      child: Slider(
                        value: _currentCostFilter,
                        min: 0,
                        max: _maxCost,
                        divisions: _maxCost.toInt(),
                        label: _currentCostFilter.toInt().toString(),
                        onChanged: (value) {
                          setState(() {
                            _currentCostFilter = value;
                          });
                        },
                      ),
                    ),
                    Text(_maxCost.toInt().toString()),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _getFilteredSpells().length,
              itemBuilder: (context, index) {
                final spell = _getFilteredSpells()[index];
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSpellForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
} 