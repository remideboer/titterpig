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

class _SpellsAdminScreenState extends State<SpellsAdminScreen> with SingleTickerProviderStateMixin {
  double _maxCost = 10;
  RangeValues _costRange = const RangeValues(0, 10);
  bool _showOnlyDndSpells = false;
  final PageController _pageController = PageController();
  late AnimationController _syncAnimationController;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _syncAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpellListViewModel>().loadSpells();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _syncAnimationController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_showOnlyDndSpells) {
      setState(() => _isSyncing = true);
      _syncAnimationController.repeat();
      await context.read<SpellListViewModel>().checkForUpdates();
      setState(() => _isSyncing = false);
      _syncAnimationController.stop();
    }
  }

  Future<void> _handleSync() async {
    setState(() => _isSyncing = true);
    _syncAnimationController.repeat();
    await context.read<SpellListViewModel>().checkForUpdates();
    setState(() => _isSyncing = false);
    _syncAnimationController.stop();
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
                  onPressed: _handleSync,
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
                icon: RotationTransition(
                  turns: _syncAnimationController,
                  child: Icon(
                    Icons.sync,
                    color: _isSyncing ? AppTheme.highlightColor : null,
                  ),
                ),
                onPressed: _handleSync,
                tooltip: 'Sync D&D Spells',
              ),
              IconButton(
                icon: Icon(_showOnlyDndSpells ? Icons.cloud_done : Icons.cloud_off),
                onPressed: () {
                  setState(() => _showOnlyDndSpells = !_showOnlyDndSpells);
                  _pageController.animateToPage(
                    _showOnlyDndSpells ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                tooltip: _showOnlyDndSpells ? 'Show Local Spells' : 'Show D&D Spells',
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
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _showOnlyDndSpells = index == 1;
                    });
                  },
                  children: [
                    // Local spells page
                    ListView.builder(
                      itemCount: _getFilteredSpells(viewModel.localSpells).length,
                      itemBuilder: (context, index) {
                        final spell = _getFilteredSpells(viewModel.localSpells)[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: _buildCostHexagon(spell.cost),
                            title: Text(
                              spell.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (spell.effect.isNotEmpty) Text('Effect: ${spell.effect}'),
                                if (spell.damage.isNotEmpty) Text('Damage: ${spell.damage}'),
                                Text('Type: ${spell.type} • Range: ${spell.range}'),
                              ],
                            ),
                            trailing: Row(
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
                            ),
                          ),
                        );
                      },
                    ),
                    // D&D spells page
                    RefreshIndicator(
                      onRefresh: _handleRefresh,
                      child: ListView.builder(
                        itemCount: _getFilteredSpells(viewModel.dndSpells).length,
                        itemBuilder: (context, index) {
                          final spell = _getFilteredSpells(viewModel.dndSpells)[index];
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
                                  const SizedBox(width: 8),
                                  const Icon(Icons.cloud_download, size: 16),
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
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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