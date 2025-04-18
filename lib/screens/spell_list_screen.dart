import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/spell_list_viewmodel.dart';
import '../models/spell.dart';
import '../services/dnd_spell_converter.dart';
import 'spell_detail_screen.dart';
import '../widgets/hexagon_shape.dart';
import '../theme/app_theme.dart';

class SpellListScreen extends StatefulWidget {
  final Function(Spell) onSpellSelected;
  final List<Spell> selectedSpells;

  const SpellListScreen({
    Key? key,
    required this.onSpellSelected,
    required this.selectedSpells,
  }) : super(key: key);

  @override
  State<SpellListScreen> createState() => _SpellListScreenState();
}

class _SpellListScreenState extends State<SpellListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DndSpellConverter _converter = DndSpellConverter();
  bool _showOnlyDndSpells = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpellListViewModel>().loadSpells();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SpellListViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final spells = _showOnlyDndSpells 
            ? viewModel.dndSpells 
            : viewModel.allSpells;
            
        if (spells.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No spells available'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => viewModel.checkForUpdates(),
                  child: const Text('Sync D&D Spells'),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Spells'),
            actions: [
              IconButton(
                icon: const Icon(Icons.sync),
                onPressed: () => viewModel.checkForUpdates(),
                tooltip: 'Sync D&D Spells',
              ),
              IconButton(
                icon: Icon(_showOnlyDndSpells ? Icons.list : Icons.cloud),
                onPressed: () => setState(() => _showOnlyDndSpells = !_showOnlyDndSpells),
                tooltip: _showOnlyDndSpells ? 'Show All Spells' : 'Show Only D&D Spells',
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search spells',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: spells.length,
                  itemBuilder: (context, index) {
                    final spell = spells[index];
                    if (_searchController.text.isNotEmpty &&
                        !spell.name.toLowerCase().contains(_searchController.text.toLowerCase())) {
                      return const SizedBox.shrink();
                    }
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Row(
                          children: [
                            Text(spell.name),
                            if (spell.isDndSpell) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.cloud_download, size: 16),
                            ],
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(spell.description),
                            if (spell.damage.isNotEmpty)
                              Text('${spell.damage} ${spell.effect}'),
                            Text('${spell.type} • Range: ${spell.range}'),
                            Text(
                              'Cost: ${spell.cost}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => widget.onSpellSelected(spell),
                            ),
                            if (!spell.isDndSpell)
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editSpell(context, spell),
                              ),
                          ],
                        ),
                        onTap: () => _showSpellDetails(context, spell),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: Hero(
            tag: 'spell_list_fab',
            child: FloatingActionButton(
              onPressed: () => _addNewSpell(context),
              child: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }

  void _showSpellDetails(BuildContext context, Spell spell) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpellDetailScreen(
          spell: spell,
          onSpellSelected: widget.onSpellSelected,
        ),
      ),
    );
  }

  void _editSpell(BuildContext context, Spell spell) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${spell.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Name'),
              controller: TextEditingController(text: spell.name),
              onChanged: (value) => spell = spell.copyWith(name: value),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Description'),
              controller: TextEditingController(text: spell.description),
              onChanged: (value) => spell = spell.copyWith(description: value),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Cost'),
              controller: TextEditingController(text: spell.cost.toString()),
              keyboardType: TextInputType.number,
              onChanged: (value) => spell = spell.copyWith(
                cost: int.tryParse(value) ?? spell.cost,
              ),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Damage'),
              controller: TextEditingController(text: spell.damage),
              onChanged: (value) => spell = spell.copyWith(damage: value),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Effect'),
              controller: TextEditingController(text: spell.effect),
              onChanged: (value) => spell = spell.copyWith(effect: value),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Type'),
              controller: TextEditingController(text: spell.type),
              onChanged: (value) => spell = spell.copyWith(type: value),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Range'),
              controller: TextEditingController(text: spell.range),
              onChanged: (value) => spell = spell.copyWith(range: value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<SpellListViewModel>().updateSpell(spell, spell);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _addNewSpell(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Spell'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Name'),
              onChanged: (value) => _newSpell = _newSpell.copyWith(name: value),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Description'),
              onChanged: (value) => _newSpell = _newSpell.copyWith(description: value),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Cost'),
              keyboardType: TextInputType.number,
              onChanged: (value) => _newSpell = _newSpell.copyWith(
                cost: int.tryParse(value) ?? 0,
              ),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Damage'),
              onChanged: (value) => _newSpell = _newSpell.copyWith(damage: value),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Effect'),
              onChanged: (value) => _newSpell = _newSpell.copyWith(effect: value),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Type'),
              onChanged: (value) => _newSpell = _newSpell.copyWith(type: value),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Range'),
              onChanged: (value) => _newSpell = _newSpell.copyWith(range: value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<SpellListViewModel>().addSpell(_newSpell);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Spell _newSpell = Spell(
    name: '',
    description: '',
    cost: 0,
    damage: '',
    effect: '',
    type: 'Spell',
    range: 'Self',
  );

  Widget _buildHexagon(String value, String label) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        children: [
          HexagonContainer(
            size: 40,
            fillColor: AppTheme.primaryColor,
            borderColor: AppTheme.highlightColor,
            borderWidth: 2,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (label.isNotEmpty)
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 