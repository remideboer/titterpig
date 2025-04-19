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

  List<Spell> _filterSpells(List<Spell> spells) {
    if (_searchQuery.isEmpty) return spells;
    return spells.where((spell) =>
      spell.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      spell.description.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  void _addSpell(Spell spell) {
    if (_currentSpells.length < widget.maxSpells) {
      setState(() {
        _currentSpells.add(spell);
        widget.onSpellsChanged(_currentSpells);
      });
    }
  }

  void _removeSpell(Spell spell) {
    setState(() {
      _currentSpells.remove(spell);
      widget.onSpellsChanged(_currentSpells);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SpellListViewModel>();
    final spells = _filterSpells(viewModel.allSpells);

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Spell (${_currentSpells.length}/${widget.maxSpells})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => viewModel.refreshSpells(),
            tooltip: 'Refresh Spells',
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
                return ListTile(
                  title: Text(spell.name),
                  subtitle: Text(
                    spell.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Cost: ${spell.cost}'),
                      if (isSelected)
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => _removeSpell(spell),
                        )
                      else if (canAdd)
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => _addSpell(spell),
                        ),
                    ],
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SpellDetailScreen(spell: spell),
                    ),
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