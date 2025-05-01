import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/species.dart';
import '../viewmodels/species_list_viewmodel.dart';
import '../providers/providers.dart';

class SpeciesEditScreen extends ConsumerStatefulWidget {
  final Species? species;

  const SpeciesEditScreen({Key? key, this.species}) : super(key: key);

  @override
  ConsumerState<SpeciesEditScreen> createState() => _SpeciesEditScreenState();
}

class _SpeciesEditScreenState extends ConsumerState<SpeciesEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _iconController;
  late TextEditingController _cultureController;
  late TextEditingController _traitsController;
  late TextEditingController _vitController;
  late TextEditingController _athController;
  late TextEditingController _wilController;
  late TextEditingController _hpController;
  late TextEditingController _lifeController;
  late TextEditingController _powerController;
  late TextEditingController _defController;
  late TextEditingController _speedController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.species?.name ?? '');
    _iconController = TextEditingController(text: widget.species?.icon ?? 'human-face.svg');
    _cultureController = TextEditingController(text: widget.species?.culture ?? '');
    _traitsController = TextEditingController(text: widget.species?.traits.join(', ') ?? '');
    _vitController = TextEditingController(text: widget.species?.vit.toString() ?? '0');
    _athController = TextEditingController(text: widget.species?.ath.toString() ?? '0');
    _wilController = TextEditingController(text: widget.species?.wil.toString() ?? '0');
    _hpController = TextEditingController(text: widget.species?.hp.toString() ?? '0');
    _lifeController = TextEditingController(text: widget.species?.life.toString() ?? '0');
    _powerController = TextEditingController(text: widget.species?.power.toString() ?? '0');
    _defController = TextEditingController(text: widget.species?.def.toString() ?? '0');
    _speedController = TextEditingController(text: widget.species?.speed.toString() ?? '0');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    _cultureController.dispose();
    _traitsController.dispose();
    _vitController.dispose();
    _athController.dispose();
    _wilController.dispose();
    _hpController.dispose();
    _lifeController.dispose();
    _powerController.dispose();
    _defController.dispose();
    _speedController.dispose();
    super.dispose();
  }

  void _saveSpecies(BuildContext context) {
    final viewModel = ref.read(speciesListViewModelProvider);
    
    final newSpecies = Species(
      name: _nameController.text,
      icon: _iconController.text,
      culture: _cultureController.text,
      traits: _traitsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      vit: int.tryParse(_vitController.text) ?? 0,
      ath: int.tryParse(_athController.text) ?? 0,
      wil: int.tryParse(_wilController.text) ?? 0,
      hp: int.tryParse(_hpController.text) ?? 0,
      life: int.tryParse(_lifeController.text) ?? 0,
      power: int.tryParse(_powerController.text) ?? 0,
      def: int.tryParse(_defController.text) ?? 0,
      speed: int.tryParse(_speedController.text) ?? 0,
    );

    if (widget.species != null) {
      viewModel.updateSpecies(newSpecies);
    } else {
      viewModel.addSpecies(newSpecies);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.species == null ? 'Create Species' : 'Edit Species'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveSpecies(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _iconController,
              decoration: const InputDecoration(
                labelText: 'Icon',
                border: OutlineInputBorder(),
                helperText: 'SVG file name in assets/icons',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cultureController,
              decoration: const InputDecoration(
                labelText: 'Culture',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _traitsController,
              decoration: const InputDecoration(
                labelText: 'Traits',
                border: OutlineInputBorder(),
                helperText: 'Comma-separated list of traits',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Base Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _vitController,
                    decoration: const InputDecoration(
                      labelText: 'VIT',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _athController,
                    decoration: const InputDecoration(
                      labelText: 'ATH',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _wilController,
                    decoration: const InputDecoration(
                      labelText: 'WIL',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Derived Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _hpController,
                    decoration: const InputDecoration(
                      labelText: 'HP',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _lifeController,
                    decoration: const InputDecoration(
                      labelText: 'Life',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _powerController,
                    decoration: const InputDecoration(
                      labelText: 'Power',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _defController,
                    decoration: const InputDecoration(
                      labelText: 'Defense',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _speedController,
                    decoration: const InputDecoration(
                      labelText: 'Speed',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 