import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/spell.dart';
import '../viewmodels/spell_list_viewmodel.dart';
import '../models/die.dart';

class SpellEditScreen extends StatefulWidget {
  final Ability? spell;

  const SpellEditScreen({Key? key, this.spell}) : super(key: key);

  @override
  _SpellEditScreenState createState() => _SpellEditScreenState();
}

class _SpellEditScreenState extends State<SpellEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _costController;
  late TextEditingController _effectController;
  late TextEditingController _dieCountController;
  late String _selectedType;
  late String _selectedRange;

  // Predefined options
  static const List<String> _types = ['Spell', 'Support', 'Offensive', 'Defensive', 'Utility'];
  static const List<String> _ranges = ['Self', 'Touch', '15ft', '30ft', '60ft'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.spell?.name ?? '');
    _descriptionController = TextEditingController(text: widget.spell?.description ?? '');
    _costController = TextEditingController(text: widget.spell?.cost.toString() ?? '0');
    _effectController = TextEditingController(text: widget.spell?.effect ?? '');
    _dieCountController = TextEditingController(text: widget.spell?.effectValue?.count.toString() ?? '0');
    
    // Ensure selected values are in the predefined lists
    _selectedType = _types.contains(widget.spell?.type) ? widget.spell!.type : _types.first;
    _selectedRange = _ranges.contains(widget.spell?.range) ? widget.spell!.range : _ranges.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    _effectController.dispose();
    _dieCountController.dispose();
    super.dispose();
  }

  void _saveSpell(BuildContext context) {
    final viewModel = context.read<SpellListViewModel>();
    final dieCount = int.tryParse(_dieCountController.text) ?? 0;
    
    final newSpell = Ability(
      name: _nameController.text,
      description: _descriptionController.text,
      cost: int.tryParse(_costController.text) ?? 0,
      effect: _effectController.text,
      effectValue: dieCount > 0 ? Die(dieCount) : null,
      type: _selectedType,
      range: _selectedRange,
      versionId: widget.spell?.versionId,
      lastUpdated: DateTime.now(),
    );

    if (widget.spell != null) {
      viewModel.updateSpell(newSpell);
    } else {
      viewModel.addSpell(newSpell);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.spell == null ? 'Create Spell' : 'Edit Spell'),
        actions: [
          Hero(
            tag: 'spell-edit-save-button',
            child: IconButton(
              icon: const Icon(Icons.save),
              onPressed: () => _saveSpell(context),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _costController,
                    decoration: const InputDecoration(
                      labelText: 'Cost',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _dieCountController,
                    decoration: const InputDecoration(
                      labelText: 'Number of Dice',
                      border: OutlineInputBorder(),
                      helperText: 'Leave 0 for no dice',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _effectController,
              decoration: const InputDecoration(
                labelText: 'Effect',
                border: OutlineInputBorder(),
                helperText: 'e.g., "Deal damage to target", "Heal target"',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: _types.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRange,
              decoration: const InputDecoration(
                labelText: 'Range',
                border: OutlineInputBorder(),
              ),
              items: _ranges.map((range) {
                return DropdownMenuItem(
                  value: range,
                  child: Text(range),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedRange = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
} 