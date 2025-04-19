import 'package:flutter/material.dart';
import '../models/spell.dart';
import '../models/character.dart';
import '../widgets/hexagon_shape.dart';
import '../theme/app_theme.dart';
import '../repositories/local_character_repository.dart';
import 'package:provider/provider.dart';
import '../viewmodels/spell_list_viewmodel.dart';
import '../widgets/spell_list_item.dart';
import 'spell_detail_screen.dart';

class SpellSelectionScreen extends StatefulWidget {
  final Function(List<Spell>) onSpellsChanged;
  final List<Spell> selectedSpells;
  final int maxSpells;

  const SpellSelectionScreen({
    Key? key,
    required this.onSpellsChanged,
    required this.selectedSpells,
    required this.maxSpells,
  }) : super(key: key);

  @override
  _SpellSelectionScreenState createState() => _SpellSelectionScreenState();
}

class _SpellSelectionScreenState extends State<SpellSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late List<Spell> _currentSpells;

  @override
  void initState() {
    super.initState();
    _currentSpells = List.from(widget.selectedSpells);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Spell> _filterAndSortSpells(List<Spell> spells) {
    // First, filter spells based on search query
    var filteredSpells = spells;
    if (_searchQuery.isNotEmpty) {
      filteredSpells = spells.where((spell) =>
        spell.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        spell.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Then sort the filtered spells
    return filteredSpells..sort((a, b) {
      // First, sort by selection status
      final isSelectedA = _currentSpells.contains(a);
      final isSelectedB = _currentSpells.contains(b);
      if (isSelectedA != isSelectedB) {
        return isSelectedB ? 1 : -1; // Selected spells come first
      }

      // Then sort by cost
      if (a.cost != b.cost) {
        return a.cost.compareTo(b.cost);
      }

      // Finally, sort by name
      return a.name.compareTo(b.name);
    });
  }

  void _toggleSpell(Spell spell) {
    setState(() {
      if (_currentSpells.contains(spell)) {
        _currentSpells.remove(spell);
      } else if (_currentSpells.length < widget.maxSpells) {
        _currentSpells.add(spell);
      }
      widget.onSpellsChanged(_currentSpells);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SpellListViewModel>();
    final spells = _filterAndSortSpells(viewModel.allSpells);

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Spell (${_currentSpells.length}/${widget.maxSpells})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => viewModel.loadSpells(),
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
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: spells.length,
              itemBuilder: (context, index) {
                final spell = spells[index];
                final isSelected = _currentSpells.contains(spell);
                final canAdd = _currentSpells.length < widget.maxSpells;
                
                return SpellListItem(
                  spell: spell,
                  actions: SpellListItemActions(
                    spell: spell,
                    actions: [
                      IconButton(
                        icon: Icon(
                          isSelected ? Icons.check_circle : Icons.add_circle_outline,
                          color: isSelected ? Colors.green : null,
                        ),
                        onPressed: (isSelected || canAdd) ? () => _toggleSpell(spell) : null,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

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