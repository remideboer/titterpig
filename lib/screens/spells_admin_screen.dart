import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/spell.dart';
import '../viewmodels/spell_list_viewmodel.dart';
import '../widgets/spell_list_item.dart';
import '../widgets/cost_range_slider.dart';
import 'spell_edit_screen.dart';

class SpellsAdminScreen extends StatefulWidget {
  const SpellsAdminScreen({Key? key}) : super(key: key);

  @override
  _SpellsAdminScreenState createState() => _SpellsAdminScreenState();
}

class _SpellsAdminScreenState extends State<SpellsAdminScreen> {
  late SpellListViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<SpellListViewModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Spells'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddSpellDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search spells',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _viewModel.clearSearchQuery();
                      },
                    ),
                  ),
                  onChanged: (value) => _viewModel.setSearchQuery(value),
                ),
                const SizedBox(height: 8),
                Consumer<SpellListViewModel>(
                  builder: (context, viewModel, child) {
                    return Column(
                      children: [
                        CostRangeSlider(
                          values: viewModel.costRange,
                          min: 0,
                          max: viewModel.maxSpellCost,
                          onChanged: (RangeValues values) {
                            viewModel.setCostRange(values);
                          },
                          label: 'Spell Cost Range',
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Filter by Type:',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: viewModel.selectedTypes.isEmpty 
                                ? null 
                                : viewModel.clearSelectedTypes,
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: viewModel.availableTypes.map((type) {
                            return FilterChip(
                              label: Text(type),
                              selected: viewModel.selectedTypes.contains(type),
                              onSelected: (bool selected) {
                                viewModel.toggleType(type);
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<SpellListViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final spells = viewModel.filteredSpells;
                if (spells.isEmpty) {
                  return const Center(child: Text('No spells found'));
                }

                return ListView.builder(
                  itemCount: spells.length,
                  itemBuilder: (context, index) {
                    final spell = spells[index];
                    return SpellListItem(
                      spell: spell,
                      actions: SpellListItemActions(
                        spell: spell,
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditSpellDialog(context, spell),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _showDeleteSpellDialog(context, spell),
                          ),
                        ],
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

  void _showAddSpellDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SpellEditScreen(),
      ),
    );
  }

  void _showEditSpellDialog(BuildContext context, Ability spell) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpellEditScreen(spell: spell),
      ),
    );
  }

  void _showDeleteSpellDialog(BuildContext context, Ability spell) {
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
              _viewModel.removeSpell(spell);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
} 