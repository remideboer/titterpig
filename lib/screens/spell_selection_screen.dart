import 'package:flutter/material.dart';
import '../models/spell.dart';
import '../models/character.dart';
import '../widgets/hexagon_shape.dart';
import '../theme/app_theme.dart';
import '../repositories/local_character_repository.dart';
import 'package:provider/provider.dart';
import '../viewmodels/spell_list_viewmodel.dart';
import 'spell_detail_screen.dart';

class SpellSelectionScreen extends StatefulWidget {
  final List<Spell> selectedSpells;
  final int maxSpells;
  final Function(List<Spell>) onSpellsChanged;

  const SpellSelectionScreen({
    super.key,
    required this.selectedSpells,
    required this.maxSpells,
    required this.onSpellsChanged,
  });

  @override
  State<SpellSelectionScreen> createState() => _SpellSelectionScreenState();
}

class _SpellSelectionScreenState extends State<SpellSelectionScreen> {
  late List<Spell> _selectedSpells;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedSpells = List.from(widget.selectedSpells);
  }

  void _toggleSpell(Spell spell) {
    setState(() {
      if (_selectedSpells.contains(spell)) {
        _selectedSpells.remove(spell);
      } else if (_selectedSpells.length < widget.maxSpells) {
        _selectedSpells.add(spell);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You can\'t select more than ${widget.maxSpells} spells'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      widget.onSpellsChanged(_selectedSpells);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Spells (${_selectedSpells.length}/${widget.maxSpells})'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(_selectedSpells);
            },
            child: const Text('Done'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Spells',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: Consumer<SpellListViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final spells = viewModel.allSpells.where((spell) {
                  return spell.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                         spell.description.toLowerCase().contains(_searchQuery.toLowerCase());
                }).toList();

                return ListView.builder(
                  itemCount: spells.length,
                  itemBuilder: (context, index) {
                    final spell = spells[index];
                    final isSelected = _selectedSpells.contains(spell);

                    return ListTile(
                      title: Text(spell.name),
                      subtitle: Text(spell.description),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                          : _selectedSpells.length < widget.maxSpells
                              ? const Icon(Icons.add_circle_outline)
                              : const Icon(Icons.block, color: Colors.grey),
                      onTap: () => _toggleSpell(spell),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 