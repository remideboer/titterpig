import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/spell.dart';
import '../viewmodels/spell_list_viewmodel.dart';
import '../widgets/spell_list_item.dart';
import '../widgets/cost_range_slider.dart';
import 'spell_edit_screen.dart';

class SpellsAdminScreen extends StatelessWidget {
  const SpellsAdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SpellListViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Manage Spells'),
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
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  onChanged: viewModel.setSearchQuery,
                  decoration: const InputDecoration(
                    labelText: 'Search Spells',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              CostRangeSlider(
                values: viewModel.costRange,
                min: 0,
                max: viewModel.maxSpellCost,
                label: 'Filter by Cost',
                onChanged: viewModel.setCostRange,
              ),
              const SizedBox(height: 8),
              if (viewModel.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.filteredSpells.length,
                    itemBuilder: (context, index) {
                      final spell = viewModel.filteredSpells[index];
                      return SpellListItem(
                        spell: spell,
                        actions: SpellListItemActions(
                          spell: spell,
                          actions: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SpellEditScreen(spell: spell),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => viewModel.removeSpell(spell),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SpellEditScreen(),
              ),
            ),
            tooltip: 'Add Spell',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
} 