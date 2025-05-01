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
  int _vit = 0;
  int _ath = 0;
  int _wil = 0;
  int _hp = 0;
  int _life = 0;
  int _power = 0;
  int _def = 0;
  int _speed = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.species?.name ?? '');
    _iconController = TextEditingController(text: widget.species?.icon ?? 'human-face.svg');
    _cultureController = TextEditingController(text: widget.species?.culture ?? '');
    _traitsController = TextEditingController(text: widget.species?.traits.join(', ') ?? '');
    _vit = widget.species?.vit ?? 0;
    _ath = widget.species?.ath ?? 0;
    _wil = widget.species?.wil ?? 0;
    _hp = widget.species?.hp ?? 0;
    _life = widget.species?.life ?? 0;
    _power = widget.species?.power ?? 0;
    _def = widget.species?.def ?? 0;
    _speed = widget.species?.speed ?? 0;
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
    setState(() {
      switch (stat) {
        case 'vit': _vit += delta; break;
        case 'ath': _ath += delta; break;
        case 'wil': _wil += delta; break;
        case 'hp': _hp += delta; break;
        case 'life': _life += delta; break;
        case 'power': _power += delta; break;
        case 'def': _def += delta; break;
        case 'speed': _speed += delta; break;
      }
    });
  }

  void _saveSpecies(BuildContext context) {
    final viewModel = ref.read(speciesListViewModelProvider);
    
    final newSpecies = Species(
      name: _nameController.text,
      icon: _iconController.text,
      culture: _cultureController.text,
      traits: _traitsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      vit: _vit,
      ath: _ath,
      wil: _wil,
      hp: _hp,
      life: _life,
      power: _power,
      def: _def,
      speed: _speed,
    );

    if (widget.species != null) {
      viewModel.updateSpecies(newSpecies);
    } else {
      viewModel.addSpecies(newSpecies);
    }

    Navigator.pop(context);
  }

  Widget _buildStatInput(String label, int value, VoidCallback onIncrement, VoidCallback onDecrement) {
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
                SizedBox(
                  width: 28,
                  height: 28,
                  child: IconButton(
                    icon: const Icon(Icons.remove, size: 16),
                    padding: EdgeInsets.zero,
                    onPressed: onDecrement,
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
                    onPressed: onIncrement,
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
            const Text('Base Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatInput('VIT', _vit, 
                    () => _updateStat('vit', 1),
                    () => _updateStat('vit', -1),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatInput('ATH', _ath,
                    () => _updateStat('ath', 1),
                    () => _updateStat('ath', -1),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatInput('WIL', _wil,
                    () => _updateStat('wil', 1),
                    () => _updateStat('wil', -1),
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
                  child: _buildStatInput('HP', _hp,
                    () => _updateStat('hp', 1),
                    () => _updateStat('hp', -1),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatInput('Life', _life,
                    () => _updateStat('life', 1),
                    () => _updateStat('life', -1),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatInput('Power', _power,
                    () => _updateStat('power', 1),
                    () => _updateStat('power', -1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatInput('Defense', _def,
                    () => _updateStat('def', 1),
                    () => _updateStat('def', -1),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatInput('Speed', _speed,
                    () => _updateStat('speed', 1),
                    () => _updateStat('speed', -1),
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