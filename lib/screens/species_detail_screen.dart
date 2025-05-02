import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ttrpg_character_manager/screens/species_edit_screen.dart';
import 'package:ttrpg_character_manager/theme/app_theme.dart';
import 'package:ttrpg_character_manager/utils/name_formatter.dart';
import '../models/species.dart';
import '../viewmodels/species_list_viewmodel.dart';
import '../providers/providers.dart';
import '../widgets/avatar_selector.dart';

class SpeciesDetailScreen extends ConsumerWidget {
  final Species species;

  const SpeciesDetailScreen({Key? key, required this.species})
      : super(key: key);

  Widget _buildInfoDisplay(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primaryColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child:
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  NameFormatter.formatName(value.toString()),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildStatDisplay(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          IntrinsicWidth(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: IconButton(
                    icon: Icon(Icons.remove, size: 16),
                    padding: EdgeInsets.zero,
                    onPressed: null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    value.toString(),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: IconButton(
                    icon: Icon(Icons.add, size: 16),
                    padding: EdgeInsets.zero,
                    onPressed: null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the species list to get updates
    final viewModel = ref.watch(speciesListViewModelProvider);
    final updatedSpecies = viewModel.species.firstWhere(
      (s) => s.name == species.name,
      orElse: () => species,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Species Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SpeciesEditScreen(species: updatedSpecies),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoDisplay(updatedSpecies.name),
            const SizedBox(height: 16),
            // Icon Selection
            Center(
              child: AvatarSelector(
                initialAvatarPath: updatedSpecies.icon,
                onAvatarSelected: (path) {
                  // setState(() {
                  //   _iconPath = path;
                  // });
                },
                size: 120,
                editable: false,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoDisplay(updatedSpecies.culture),
            const SizedBox(height: 16),
            _buildInfoDisplay(updatedSpecies.traits.join(', ')),
            const SizedBox(height: 16),
            const Center(child: SizedBox(height: 16)),
            const SizedBox(height: 16),
            const Text('Base Stats',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatDisplay('VIT', updatedSpecies.vit.toString()),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatDisplay('ATH', updatedSpecies.ath.toString()),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatDisplay('WIL', updatedSpecies.wil.toString()),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Derived Stats',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatDisplay('HP', updatedSpecies.hp.toString()),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatDisplay('Life', updatedSpecies.life.toString()),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatDisplay('Power', updatedSpecies.power.toString()),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatDisplay('Defense', updatedSpecies.def.toString()),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatDisplay('Speed', updatedSpecies.speed.toString()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
