import 'package:flutter/material.dart';
import '../models/spell.dart';
import '../widgets/hexagon_shape.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../viewmodels/spell_list_viewmodel.dart';
import '../widgets/spell_list_item.dart';
import '../widgets/cost_range_slider.dart';
import '../widgets/spell_type_filter.dart';

class SpellSelectionScreen extends StatefulWidget {
  final Function(List<Ability>) onSpellsChanged;
  final List<Ability> selectedSpells;
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
  late List<Ability> _currentSpells;
  late RangeValues _costRange;
  double _maxSpellCost = 0;
  Set<String> _selectedTypes = {};
  late List<String> _availableTypes;

  @override
  void initState() {
    super.initState();
    _currentSpells = List.from(widget.selectedSpells);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    
    final allSpells = Provider.of<SpellListViewModel>(context, listen: false).allSpells;
    
    // Initialize cost range based on available spells
    _maxSpellCost = allSpells
        .map((s) => s.cost.toDouble())
        .reduce((a, b) => a > b ? a : b);
    _costRange = RangeValues(0, _maxSpellCost);

    // Get unique spell types from available spells
    _availableTypes = allSpells
        .map((s) => s.type)
        .toSet()
        .toList()
      ..sort();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Ability> _filterAndSortSpells(List<Ability> spells) {
    // First, filter spells based on search query, cost range, and selected types
    var filteredSpells = spells.where((spell) {
      final matchesSearch = _searchQuery.isEmpty ||
          spell.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          spell.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesCost = spell.cost >= _costRange.start && 
                         spell.cost <= _costRange.end;
      
      final matchesType = _selectedTypes.isEmpty || 
                         _selectedTypes.contains(spell.type);
      
      return matchesSearch && matchesCost && matchesType;
    }).toList();

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

  void _toggleSpell(Ability spell) {
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
    return Consumer<SpellListViewModel>(
      builder: (context, spellListViewModel, child) {
        final filteredSpells = _filterAndSortSpells(spellListViewModel.allSpells);
        
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Spells (${_currentSpells.length}/${widget.maxSpells})',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.highlightColor,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search Spells',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SpellTypeFilter(
                availableTypes: _availableTypes,
                selectedTypes: _selectedTypes,
                onTypesChanged: (types) {
                  setState(() {
                    _selectedTypes = types;
                  });
                },
              ),
            ),
            CostRangeSlider(
              values: _costRange,
              min: 0,
              max: _maxSpellCost,
              label: 'Filter by Cost',
              onChanged: (RangeValues values) {
                setState(() {
                  _costRange = values;
                });
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: filteredSpells.length,
                itemBuilder: (context, index) {
                  final spell = filteredSpells[index];
                  final isSelected = _currentSpells.contains(spell);
                  
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
                          onPressed: () => _toggleSpell(spell),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
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