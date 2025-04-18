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

  bool _isSpellSelected(Spell spell) {
    return _selectedSpells.any((s) => s.versionId == spell.versionId);
  }

  Spell _findMatchingSpell(Spell spell) {
    return _selectedSpells.firstWhere(
      (s) => s.versionId == spell.versionId,
      orElse: () => spell,
    );
  }

  void _toggleSpell(Spell spell) {
    setState(() {
      if (_isSpellSelected(spell)) {
        _selectedSpells.removeWhere((s) => s.versionId == spell.versionId);
      } else if (_selectedSpells.length < widget.maxSpells) {
        // Use the existing spell instance if it's already selected
        final existingSpell = _findMatchingSpell(spell);
        _selectedSpells.add(existingSpell);
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
        title: Text('(${_selectedSpells.length}/${widget.maxSpells})'),
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
                }).toList()
                  ..sort((a, b) {
                    // First sort by selection status
                    final aSelected = _isSpellSelected(a);
                    final bSelected = _isSpellSelected(b);
                    if (aSelected != bSelected) {
                      return aSelected ? -1 : 1; // Selected spells first
                    }
                    // Then sort by cost
                    final costComparison = a.cost.compareTo(b.cost);
                    if (costComparison != 0) {
                      return costComparison;
                    }
                    // Finally sort by name
                    return a.name.compareTo(b.name);
                  });

                return ListView.builder(
                  itemCount: spells.length,
                  itemBuilder: (context, index) {
                    final spell = spells[index];
                    final isSelected = _isSpellSelected(spell);

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
                            if (spell.effectValue != null)
                              Text(
                                '${spell.effectValue}',
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
                        trailing: IconButton(
                          icon: isSelected
                              ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                              : _selectedSpells.length < widget.maxSpells
                                  ? const Icon(Icons.add_circle_outline)
                                  : const Icon(Icons.block, color: Colors.grey),
                          onPressed: () => _toggleSpell(spell),
                        ),
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