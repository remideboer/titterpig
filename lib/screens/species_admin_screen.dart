import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/species.dart';
import '../viewmodels/species_list_viewmodel.dart';
import '../widgets/species_list_item.dart';
import 'species_edit_screen.dart';
import '../providers/providers.dart';
import '../repositories/species_repository.dart';

class SpeciesAdminScreen extends ConsumerStatefulWidget {
  const SpeciesAdminScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SpeciesAdminScreen> createState() => _SpeciesAdminScreenState();
}

class _SpeciesAdminScreenState extends ConsumerState<SpeciesAdminScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _speciesRepository = SpeciesRepository();
  List<Species> _species = [];

  @override
  void initState() {
    super.initState();
    _loadSpecies();
  }

  Future<void> _loadSpecies() async {
    final species = await _speciesRepository.getSpecies();
    setState(() {
      _species = species;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    setState(() {});
                  },
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          Expanded(
            child: _buildSpeciesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeciesList() {
    final searchQuery = _searchController.text.toLowerCase();
    final filteredSpecies = _species.where((species) {
      return species.name.toLowerCase().contains(searchQuery) ||
             species.culture.toLowerCase().contains(searchQuery) ||
             species.traits.any((trait) => trait.toLowerCase().contains(searchQuery));
    }).toList();

    if (filteredSpecies.isEmpty) {
      return const Center(child: Text('No species found'));
    }

    return ListView.builder(
      itemCount: filteredSpecies.length,
      itemBuilder: (context, index) {
        final species = filteredSpecies[index];
        return SpeciesListItem(
          species: species,
          actions: SpeciesListItemActions(
            species: species,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditSpeciesDialog(context, species),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showDeleteSpeciesDialog(context, species),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddSpeciesDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SpeciesEditScreen(),
      ),
    ).then((_) => _loadSpecies());
  }

  void _showEditSpeciesDialog(BuildContext context, Species species) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpeciesEditScreen(species: species),
      ),
    ).then((_) => _loadSpecies());
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
              setState(() {
                _species.remove(species);
              });
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