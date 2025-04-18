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

  const SpellSelectionScreen({
    super.key,
    required this.selectedSpells,
    required this.character,
  });

  @override
  State<SpellSelectionScreen> createState() => _SpellSelectionScreenState();
}

class _SpellSelectionScreenState extends State<SpellSelectionScreen> {
  late List<Spell> _selectedSpells;
  final LocalCharacterRepository _repository = LocalCharacterRepository();
  List<Spell> _availableSpells = [];
  bool _isLoading = true;
  double _maxCost = 0;
  RangeValues _costRange = const RangeValues(0, 0);

  @override
  void initState() {
    super.initState();
    _selectedSpells = List.from(widget.selectedSpells);
    _loadSpells();
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
      spell.cost >= _costRange.start && spell.cost <= _costRange.end
    ).toList();
  }

  Future<void> _handleSpellSelection(Spell spell) async {
    setState(() {
      if (_selectedSpells.any((s) => s.name == spell.name)) {
        _selectedSpells.removeWhere((s) => s.name == spell.name);
      } else {
        _selectedSpells.add(spell);
      }
    });
    
    // Save changes immediately without closing
    await _saveChanges(shouldNavigate: false);
  }

  Future<void> _saveChanges({bool shouldNavigate = true}) async {
    final updatedCharacter = widget.character.copyWith(
      spells: List<Spell>.from(_selectedSpells),
    );
    updatedCharacter.updateDerivedStats();
    await _repository.updateCharacter(updatedCharacter);
    
    if (shouldNavigate && mounted) {
      Navigator.pop(context, updatedCharacter);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _saveChanges(shouldNavigate: false);
        return true;
      },
      child: Column(
        children: [
          // Header with title and close button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Manage Spells',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  color: AppTheme.primaryColor,
                  onPressed: () {
                    _saveChanges(shouldNavigate: false);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          // Max power display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Max Power: ${widget.character.powerStat.max}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          // Cost filter range slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: RangeSlider(
              values: _costRange,
              min: 0,
              max: _maxCost,
              divisions: _maxCost.toInt(),
              activeColor: AppTheme.primaryColor,
              inactiveColor: AppTheme.highlightColor,
              labels: RangeLabels(
                _costRange.start.round().toString(),
                _costRange.end.round().toString(),
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _costRange = values;
                });
              },
            ),
          ),
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
                        final canSelect = spell.cost <= widget.character.powerStat.max;
                        
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
                              ? Icon(Icons.check, color: AppTheme.primaryColor)
                              : (canSelect
                                  ? IconButton(
                                      icon: const Icon(Icons.add),
                                      color: AppTheme.primaryColor,
                                      onPressed: () => _handleSpellSelection(spell),
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
                                    onSpellSelected: (spell) {
                                      if (canSelect) {
                                        _handleSpellSelection(spell);
                                      }
                                    },
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
          // Save button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _saveChanges(shouldNavigate: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.accentColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Save Changes'),
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