import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/spell.dart';
import '../theme/app_theme.dart';
import '../widgets/hexagon_shape.dart';
import '../widgets/cost_range_slider.dart';
import 'spell_edit_screen.dart';
import '../viewmodels/spell_list_viewmodel.dart';

class SpellsAdminScreen extends StatefulWidget {
  const SpellsAdminScreen({super.key});

  @override
  State<SpellsAdminScreen> createState() => _SpellsAdminScreenState();
}

class _SpellsAdminScreenState extends State<SpellsAdminScreen> {
  double _maxCost = 10;
  RangeValues _costRange = const RangeValues(0, 10);
  bool _showOnlyDndSpells = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpellListViewModel>().loadSpells();
    });
  }

  void _calculateMaxCost(List<Spell> spells) {
    if (spells.isNotEmpty) {
      setState(() {
        _maxCost = spells.map((s) => s.cost.toDouble()).reduce((a, b) => a > b ? a : b);
        _costRange = RangeValues(0, _maxCost);
      });
    }
  }

  List<Spell> _getFilteredSpells(List<Spell> spells) {
    return spells.where((spell) => 
      spell.cost >= _costRange.start && spell.cost <= _costRange.end
    ).toList();
  }

  void _showSpellForm({Spell? spell}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpellEditScreen(spell: spell),
      ),
    ).then((result) {
      if (result == true) {
        setState(() {
          _calculateMaxCost(context.read<SpellListViewModel>().localSpells);
        });
      }
    });
  }

  void _deleteSpell(Spell spell) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Spell'),
        content: Text('Are you sure you want to delete ${spell.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<SpellListViewModel>().removeSpell(spell);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildCostHexagon(int cost) {
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
              child: Text(
                cost.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
            : viewModel.localSpells;

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
            title: const Text('Manage Spells'),
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
                padding: const EdgeInsets.all(16.0),
                child: CostRangeSlider(
                  maxCost: _maxCost,
                  currentRange: _costRange,
                  onChanged: (values) {
                    setState(() {
                      _costRange = values;
                    });
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _getFilteredSpells(spells).length,
                  itemBuilder: (context, index) {
                    final spell = _getFilteredSpells(spells)[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: _buildCostHexagon(spell.cost),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                spell.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            if (spell.isDndSpell) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.cloud_download, size: 16),
                            ],
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (spell.effect.isNotEmpty) Text('Effect: ${spell.effect}'),
                            if (spell.damage.isNotEmpty) Text('Damage: ${spell.damage}'),
                            Text('Type: ${spell.type} • Range: ${spell.range}'),
                          ],
                        ),
                        trailing: !spell.isDndSpell
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _showSpellForm(spell: spell),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _deleteSpell(spell),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: !_showOnlyDndSpells
              ? FloatingActionButton(
                  onPressed: () => _showSpellForm(),
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
    );
  }
} 