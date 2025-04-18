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
  final Character character;
  final Function(List<Spell>)? onSpellsChanged;

  const SpellSelectionScreen({
    super.key,
    required this.selectedSpells,
    required this.character,
    this.onSpellsChanged,
  });

  @override
  State<SpellSelectionScreen> createState() => _SpellSelectionScreenState();
}

class _SpellSelectionScreenState extends State<SpellSelectionScreen> {
  late List<Spell> _selectedSpells;
  late Character _character;
  final LocalCharacterRepository _repository = LocalCharacterRepository();
  List<Spell> _availableSpells = [];
  bool _isLoading = true;
  double _maxCost = 0;
  RangeValues _costRange = const RangeValues(0, 0);
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedSpells = List.from(widget.selectedSpells);
    _character = widget.character;
    _searchController.addListener(_onSearchChanged);
    
    // Schedule _loadSpells to run after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSpells();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Remove _loadSpells from here
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSpells() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final viewModel = context.read<SpellListViewModel>();
      await viewModel.loadSpells();
      setState(() {
        _availableSpells = viewModel.allSpells;
        _maxCost = _availableSpells.map((s) => s.cost.toDouble()).reduce((a, b) => a > b ? a : b);
        _costRange = RangeValues(0, _maxCost);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load spells: $e')),
        );
      }
    }
  }

  List<Spell> _getFilteredSpells() {
    return _availableSpells.where((spell) => 
      spell.cost >= _costRange.start && 
      spell.cost <= _costRange.end &&
      (_searchController.text.isEmpty || 
       spell.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
       spell.description.toLowerCase().contains(_searchController.text.toLowerCase()))
    ).toList();
  }

  void _onSearchChanged() {
    setState(() {
      // Trigger rebuild to update filtered spells
    });
  }

  void _toggleSpellSelection(Spell spell) {
    setState(() {
      if (_selectedSpells.contains(spell)) {
        _selectedSpells.remove(spell);
        _character.removeSpell(spell);
      } else {
        _selectedSpells.add(spell);
        _character.addSpell(spell);
      }
      // Notify parent of changes
      widget.onSpellsChanged?.call(_selectedSpells);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Spells'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Selected spells section
          if (_selectedSpells.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Spells (${_selectedSpells.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedSpells.map((spell) {
                      return Chip(
                        label: Text(spell.name),
                        onDeleted: () => _toggleSpellSelection(spell),
                        deleteIcon: const Icon(Icons.close, size: 18),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
          // Available spells list
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Consumer<SpellListViewModel>(
                  builder: (context, viewModel, child) {
                    // Sort spells: selected first, then by cost and name
                    final filteredSpells = _getFilteredSpells();
                    final sortedSpells = List<Spell>.from(filteredSpells)
                      ..sort((a, b) {
                        final aSelected = _selectedSpells.any((s) => s.name == a.name);
                        final bSelected = _selectedSpells.any((s) => s.name == b.name);
                        
                        // Selected spells come first
                        if (aSelected != bSelected) {
                          return aSelected ? -1 : 1;
                        }
                        
                        // Then sort by cost
                        final costCompare = a.cost.compareTo(b.cost);
                        if (costCompare != 0) {
                          return costCompare;
                        }
                        
                        // Finally sort by name
                        return a.name.compareTo(b.name);
                      });

                    return ListView.builder(
                      itemCount: sortedSpells.length,
                      itemBuilder: (context, index) {
                        final spell = sortedSpells[index];
                        final isSelected = _selectedSpells.any((s) => s.name == spell.name);
                        final canSelect = spell.cost <= _character.powerStat.max;
                        
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          child: ListTile(
                            leading: _buildHexagon(spell.cost.toString(), ''),
                            title: Text(
                              spell.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (spell.damage.isNotEmpty)
                                  Text(
                                    '${spell.damage} ${spell.effect}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.highlightColor,
                                    ),
                                  ),
                                Text(
                                  '${spell.type} • Range: ${spell.range}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.highlightColor,
                                  ),
                                ),
                              ],
                            ),
                            trailing: isSelected
                              ? IconButton(
                                  icon: const Icon(Icons.check_circle),
                                  color: AppTheme.primaryColor,
                                  onPressed: () => _toggleSpellSelection(spell),
                                )
                              : (canSelect
                                  ? IconButton(
                                      icon: const Icon(Icons.add_circle_outline),
                                      color: AppTheme.primaryColor,
                                      onPressed: () => _toggleSpellSelection(spell),
                                    )
                                  : Tooltip(
                                      message: 'Requires more power',
                                      child: Icon(Icons.lock, color: AppTheme.highlightColor),
                                    )),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SpellDetailScreen(
                                    spell: spell,
                                    onSpellSelected: (_) {},
                                    allowEditing: false,
                                  ),
                                ),
                              );
                            },
                          ),
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