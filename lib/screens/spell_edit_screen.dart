import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/spell.dart';
import '../viewmodels/spell_list_viewmodel.dart';

class SpellEditScreen extends StatefulWidget {
  final Spell? spell;

  const SpellEditScreen({Key? key, this.spell}) : super(key: key);

  @override
  _SpellEditScreenState createState() => _SpellEditScreenState();
}

class _SpellEditScreenState extends State<SpellEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _costController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.spell?.name ?? '');
    _descriptionController = TextEditingController(text: widget.spell?.description ?? '');
    _costController = TextEditingController(text: widget.spell?.cost.toString() ?? '0');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _saveSpell(BuildContext context) {
    final viewModel = context.read<SpellListViewModel>();
    final newSpell = Spell(
      name: _nameController.text,
      description: _descriptionController.text,
      cost: int.tryParse(_costController.text) ?? 0,
    );

    if (widget.spell != null) {
      viewModel.updateSpell(widget.spell!, newSpell);
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
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveSpell(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
            TextField(
              controller: _costController,
              decoration: const InputDecoration(
                labelText: 'Cost',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }
} 