import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/spell.dart';
import '../viewmodels/spell_list_viewmodel.dart';
import '../widgets/spell_list_item.dart';

class SpellListScreen extends StatelessWidget {
  final void Function(List<Ability>) onSpellsChanged;
  final List<Ability> selectedSpells;
  final int maxSpells;

  const SpellListScreen({
    Key? key,
    required this.onSpellsChanged,
    required this.selectedSpells,
    required this.maxSpells,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SpellListViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Select Spells'),
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
                  onChanged: viewModel.setSearchQuery,
                  decoration: const InputDecoration(
                    labelText: 'Search Spells',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Selected: ${selectedSpells.length}/$maxSpells',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (viewModel.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.filteredSpells.length,
                    itemBuilder: (context, index) {
                      final spell = viewModel.filteredSpells[index];
                      final isSelected = selectedSpells.contains(spell);
                      
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
                              onPressed: isSelected || selectedSpells.length < maxSpells
                                  ? () {
                                      final updatedSpells = List<Ability>.from(selectedSpells);
                                      if (isSelected) {
                                        updatedSpells.remove(spell);
                                      } else {
                                        updatedSpells.add(spell);
                                      }
                                      onSpellsChanged(updatedSpells);
                                    }
                                  : null,
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
      },
    );
  }
} 