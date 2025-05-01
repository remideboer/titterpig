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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the view model to rebuild when it changes
    final viewModel = ref.watch(speciesListViewModelProvider);
    final species = viewModel.filteredSpecies;

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
          if (viewModel.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (viewModel.error != null)
            Center(child: Text(viewModel.error!))
          else if (species.isEmpty)
            const Center(child: Text('No species found'))
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => viewModel.loadSpecies(),
                child: ListView.builder(
                  itemCount: species.length,
                  itemBuilder: (context, index) {
                    final currentSpecies = species[index];

                    return SpeciesListItem(
                      species: currentSpecies,
                      actions: SpeciesListItemActions(
                        species: currentSpecies,
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditSpeciesDialog(context, currentSpecies),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _showDeleteSpeciesDialog(context, currentSpecies, viewModel),
                          ),
                        ],
                      ),
                    );
                  },
                ),
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

  void _showDeleteSpeciesDialog(BuildContext context, Species species, SpeciesListViewModel viewModel) {
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
            onPressed: () async {
              await viewModel.deleteSpecies(species);
              if (mounted) {
                Navigator.pop(context);
              }
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