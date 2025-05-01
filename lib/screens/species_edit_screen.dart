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
  late Species _currentSpecies;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.species?.name ?? '');
    _iconController = TextEditingController(text: widget.species?.icon ?? 'human-face.svg');
    _cultureController = TextEditingController(text: widget.species?.culture ?? '');
    _traitsController = TextEditingController(text: widget.species?.traits.join(', ') ?? '');
    _currentSpecies = widget.species ?? const Species(name: '', icon: '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    _cultureController.dispose();
    _traitsController.dispose();
    super.dispose();
  }

  void _updateStat(String stat, int delta) {
    if (delta > 0 && !_currentSpecies.canIncreaseStat(stat)) return;
    if (delta < 0 && !_currentSpecies.canDecreaseStat(stat)) return;

    setState(() {
      _currentSpecies = _currentSpecies.copyWith(
        vit: stat == 'vit' ? _currentSpecies.vit + delta : _currentSpecies.vit,
        ath: stat == 'ath' ? _currentSpecies.ath + delta : _currentSpecies.ath,
        wil: stat == 'wil' ? _currentSpecies.wil + delta : _currentSpecies.wil,
        hp: stat == 'hp' ? _currentSpecies.hp + delta : _currentSpecies.hp,
        life: stat == 'life' ? _currentSpecies.life + delta : _currentSpecies.life,
        power: stat == 'power' ? _currentSpecies.power + delta : _currentSpecies.power,
        def: stat == 'def' ? _currentSpecies.def + delta : _currentSpecies.def,
        speed: stat == 'speed' ? _currentSpecies.speed + delta : _currentSpecies.speed,
      );
    });
  }

  void _saveSpecies(BuildContext context) {
    final viewModel = ref.read(speciesListViewModelProvider);
    
    final newSpecies = Species(
      name: _nameController.text,
      icon: _iconController.text,
      culture: _cultureController.text,
      traits: _traitsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      vit: _currentSpecies.vit,
      ath: _currentSpecies.ath,
      wil: _currentSpecies.wil,
      hp: _currentSpecies.hp,
      life: _currentSpecies.life,
      power: _currentSpecies.power,
      def: _currentSpecies.def,
      speed: _currentSpecies.speed,
    );

    if (widget.species != null) {
      viewModel.updateSpecies(newSpecies);
    } else {
      viewModel.addSpecies(newSpecies);
    }

    Navigator.pop(context);
  }

  Widget _buildStatInput(String label, String stat) {
    final cost = _currentSpecies.getStatCost(stat);
    final value = _currentSpecies.getStatValue(stat);
    final canIncrease = _currentSpecies.canIncreaseStat(stat);
    final canDecrease = _currentSpecies.canDecreaseStat(stat);

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
          Text('Cost: $cost', style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          IntrinsicWidth(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: IconButton(
                    icon: const Icon(Icons.remove, size: 16),
                    padding: EdgeInsets.zero,
                    onPressed: canDecrease ? () => _updateStat(stat, -1) : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    value.toString(),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: IconButton(
                    icon: const Icon(Icons.add, size: 16),
                    padding: EdgeInsets.zero,
                    onPressed: canIncrease ? () => _updateStat(stat, 1) : null,
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
                helperText: 'SVG file name in assets/svg',
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
            Center(
              child: Text(
                'Remaining Points: ${_currentSpecies.remainingPoints}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Base Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatInput('VIT', 'vit'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatInput('ATH', 'ath'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatInput('WIL', 'wil'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Derived Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatInput('HP', 'hp'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatInput('Life', 'life'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatInput('Power', 'power'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatInput('Defense', 'def'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatInput('Speed', 'speed'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 