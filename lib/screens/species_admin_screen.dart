import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/species.dart';
import '../viewmodels/species_list_viewmodel.dart';
import '../widgets/species_list_item.dart';
import 'species_edit_screen.dart';
import '../providers/providers.dart';

class SpeciesAdminScreen extends ConsumerStatefulWidget {
  const SpeciesAdminScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SpeciesAdminScreen> createState() => _SpeciesAdminScreenState();
}

class _SpeciesAdminScreenState extends ConsumerState<SpeciesAdminScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load species when the screen is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(speciesListViewModelProvider).loadSpecies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(speciesListViewModelProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Species'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddSpeciesDialog(context),
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
                labelText: 'Search species',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    viewModel.clearSearchQuery();
                  },
                ),
              ),
              onChanged: (value) => viewModel.setSearchQuery(value),
            ),
          ),
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final species = viewModel.filteredSpecies;
                if (species.isEmpty) {
                  return const Center(child: Text('No species found'));
                }

                return ListView.builder(
                  itemCount: species.length,
                  itemBuilder: (context, index) {
                    final speciesItem = species[index];
                    return SpeciesListItem(
                      species: speciesItem,
                      actions: SpeciesListItemActions(
                        species: speciesItem,
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditSpeciesDialog(context, speciesItem),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _showDeleteSpeciesDialog(context, speciesItem),
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

  void _showAddSpeciesDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SpeciesEditScreen(),
      ),
    );
  }

  void _showEditSpeciesDialog(BuildContext context, Species species) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpeciesEditScreen(species: species),
      ),
    );
  }

  void _showDeleteSpeciesDialog(BuildContext context, Species species) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Species'),
        content: Text('Are you sure you want to delete ${species.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(speciesListViewModelProvider).removeSpecies(species);
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