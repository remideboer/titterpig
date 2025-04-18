import 'package:flutter/material.dart';
import '../models/spell.dart';
import '../theme/app_theme.dart';

class SpellEditScreen extends StatefulWidget {
  final Spell? spell;
  final Function(Spell)? onSave;

  const SpellEditScreen({
    super.key,
    this.spell,
    this.onSave,
  });

  @override
  State<SpellEditScreen> createState() => _SpellEditScreenState();
}

class _SpellEditScreenState extends State<SpellEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _costController = TextEditingController();
  final _effectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _damageController = TextEditingController();
  final _typeController = TextEditingController();
  final _rangeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.spell != null) {
      _nameController.text = widget.spell!.name;
      _costController.text = widget.spell!.cost.toString();
      _effectController.text = widget.spell!.effect;
      _descriptionController.text = widget.spell!.description;
      _damageController.text = widget.spell!.damage;
      _typeController.text = widget.spell!.type;
      _rangeController.text = widget.spell!.range;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    _effectController.dispose();
    _descriptionController.dispose();
    _damageController.dispose();
    _typeController.dispose();
    _rangeController.dispose();
    super.dispose();
  }

  void _saveSpell() {
    if (_formKey.currentState?.validate() ?? false) {
      final spell = Spell(
        name: _nameController.text,
        description: _descriptionController.text,
        cost: int.tryParse(_costController.text) ?? 0,
        damage: _damageController.text,
        effect: _effectController.text,
        type: _typeController.text,
        range: _rangeController.text,
        isDndSpell: widget.spell?.isDndSpell ?? false,
      );

      if (widget.spell != null) {
        final index = Spell.availableSpells.indexWhere((s) => s.name == widget.spell?.name);
        if (index != -1) {
          Spell.availableSpells[index] = spell;
        }
      } else {
        Spell.availableSpells.add(spell);
      }

      if (widget.onSave != null) {
        widget.onSave!(spell);
      }
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.spell != null ? 'Edit Spell' : 'Create Spell'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSpell,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _costController,
              decoration: const InputDecoration(
                labelText: 'Cost',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter a cost';
                if (int.tryParse(value!) == null) return 'Please enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _effectController,
              decoration: const InputDecoration(
                labelText: 'Effect',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _damageController,
              decoration: const InputDecoration(
                labelText: 'Damage',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _typeController,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _rangeController,
              decoration: const InputDecoration(
                labelText: 'Range',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Add more fields here as needed
          ],
        ),
      ),
    );
  }
} 