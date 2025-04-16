import 'package:flutter/material.dart';
import '../models/spell.dart';
import '../theme/app_theme.dart';

class SpellsAdminScreen extends StatefulWidget {
  const SpellsAdminScreen({super.key});

  @override
  State<SpellsAdminScreen> createState() => _SpellsAdminScreenState();
}

class _SpellsAdminScreenState extends State<SpellsAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _costController = TextEditingController();
  final _effectController = TextEditingController();
  bool _isEditing = false;
  Spell? _editingSpell;

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    _effectController.dispose();
    super.dispose();
  }

  void _showSpellForm({Spell? spell}) {
    _isEditing = spell != null;
    _editingSpell = spell;
    
    if (spell != null) {
      _nameController.text = spell.name;
      _costController.text = spell.cost.toString();
      _effectController.text = spell.effect;
    } else {
      _nameController.clear();
      _costController.clear();
      _effectController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isEditing ? 'Edit Spell' : 'Add Spell'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(labelText: 'Cost'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter a cost';
                  if (int.tryParse(value!) == null) return 'Please enter a valid number';
                  return null;
                },
              ),
              TextFormField(
                controller: _effectController,
                decoration: const InputDecoration(labelText: 'Effect'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                final spell = Spell(
                  name: _nameController.text,
                  cost: int.parse(_costController.text),
                  effect: _effectController.text,
                );

                setState(() {
                  if (_isEditing) {
                    final index = Spell.availableSpells.indexWhere((s) => s.name == _editingSpell?.name);
                    if (index != -1) {
                      Spell.availableSpells[index] = spell;
                    }
                  } else {
                    Spell.availableSpells.add(spell);
                  }
                });

                Navigator.of(context).pop();
              }
            },
            child: Text(_isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
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