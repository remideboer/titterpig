import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/character.dart';
import '../services/character_service.dart';
import '../repositories/local_character_repository.dart';
import '../repositories/species_repository.dart';
import '../services/name_generator_service.dart';
import '../repositories/name_data_repository.dart';
import '../widgets/hexagon_shape.dart';
import '../models/species.dart';
import '../models/def_category.dart';
import '../themes/app_theme.dart';

class CharacterCreationScreen extends StatefulWidget {
  final Character? character;

  const CharacterCreationScreen({
    Key? key,
    this.character,
  }) : super(key: key);

  @override
  State<CharacterCreationScreen> createState() => _CharacterCreationScreenState();
}

class _CharacterCreationScreenState extends State<CharacterCreationScreen> {
  final _nameController = TextEditingController();
  final _repository = LocalCharacterRepository();
  final _speciesRepository = SpeciesRepository();
  final _nameGeneratorService = NameGeneratorService(NameDataRepository());
  
  int _vit = 0;
  int _ath = 0;
  int _wil = 0;
  int _remainingPoints = CharacterService.totalPoints;
  Species _selectedSpecies = const Species(name: 'Human', icon: 'human-face.svg');
  List<Species> _availableSpecies = [];
  late DefCategory _selectedDefense;

  @override
  void initState() {
    super.initState();
    _loadSpecies();
    if (widget.character != null) {
      _nameController.text = widget.character!.name;
      _selectedSpecies = widget.character!.species;
      _vit = widget.character!.vit;
      _ath = widget.character!.ath;
      _wil = widget.character!.wil;
      _remainingPoints = 0; // Character is already created, no points to spend
      _selectedDefense = widget.character!.defCategory;
    } else {
      _selectedDefense = DefCategory.none;
    }
  }

  Future<void> _loadSpecies() async {
    final species = await _speciesRepository.getSpecies();
    setState(() {
      _availableSpecies = species;
      if (widget.character == null) {
        _selectedSpecies = species.first;
      }
    });
  }

  Future<void> _generateRandomName() async {
    final name = await _nameGeneratorService.generateName(_selectedSpecies.name);
    setState(() {
      _nameController.text = name;
    });
  }

  bool get _canSave => 
      _nameController.text.isNotEmpty && 
      _remainingPoints == 0 && 
      CharacterService.isValidVitForHp(_vit);

  void _updateStat(String stat, int delta) {
    final currentValue = _getStatValue(stat);
    final isVit = stat == 'vit';
    
    if (CharacterService.canUpdateStat(
      currentValue: currentValue,
      delta: delta,
      remainingPoints: _remainingPoints,
      isVit: isVit,
    )) {
      setState(() {
        _setStatValue(stat, currentValue + delta);
        _remainingPoints -= delta;
      });
    }
  }

  int _getStatValue(String stat) {
    switch (stat) {
      case 'vit': return _vit;
      case 'ath': return _ath;
      case 'wil': return _wil;
      default: throw ArgumentError('Invalid stat: $stat');
    }
  }

  void _setStatValue(String stat, int value) {
    switch (stat) {
      case 'vit': _vit = value; break;
      case 'ath': _ath = value; break;
      case 'wil': _wil = value; break;
      default: throw ArgumentError('Invalid stat: $stat');
    }
  }

  void _selectDefense(DefCategory category) {
    setState(() {
      _selectedDefense = _selectedDefense == category ? DefCategory.none : category;
    });
  }

  Future<void> _saveCharacter() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
      return;
    }

    if (widget.character != null) {
      // Update existing character
      final updatedCharacter = Character(
        id: widget.character!.id,
        name: _nameController.text,
        species: _selectedSpecies,
        vit: _vit,
        ath: _ath,
        wil: _wil,
        tempHp: widget.character!.tempHp,
        defCategory: _selectedDefense,
        hasShield: widget.character!.hasShield,
        spells: widget.character!.spells,
        sessionLog: widget.character!.sessionLog,
        notes: widget.character!.notes,
        xp: widget.character!.tempHp,
      );
      await _repository.updateCharacter(updatedCharacter);
    } else {
      // Create new character
      final character = Character(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        species: _selectedSpecies,
        vit: _vit,
        ath: _ath,
        wil: _wil,
        defCategory: _selectedDefense,
      );
      await _repository.addCharacter(character);
    }

    if (context.mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hp = CharacterService.calculateHp(_vit);
    final life = CharacterService.calculateLife(_vit);
    final power = CharacterService.calculatePower(_wil);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.character != null ? 'Edit Character' : 'Create Character'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name Section
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.casino),
                  onPressed: _generateRandomName,
                  tooltip: 'Generate Random Name',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Species Selection
            DropdownButtonFormField<Species>(
              value: _selectedSpecies,
              decoration: const InputDecoration(
                labelText: 'Species',
                border: OutlineInputBorder(),
              ),
              items: _availableSpecies.map((species) {
                return DropdownMenuItem(
                  value: species,
                  child: Text(species.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedSpecies = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),

            // Points Remaining
            Center(
              child: Text(
                'Remaining Points: $_remainingPoints',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 16),

            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildStatBox('VIT', _vit, () => _updateStat('vit', -1), () => _updateStat('vit', 1)),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildStatBox('ATH', _ath, () => _updateStat('ath', -1), () => _updateStat('ath', 1)),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildStatBox('WIL', _wil, () => _updateStat('wil', -1), () => _updateStat('wil', 1)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Derived Stats Section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDiamondStat('HP', hp, null),
                const SizedBox(width: 20),
                _buildDiamondStat('LIFE', life, null),
              ],
            ),
            const SizedBox(height: 24),

            // Power Section
            Center(
              child: Column(
                children: [
                  const Text('POWER'),
                  Text(power.toString(), style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Defense Section
            Center(
              child: Column(
                children: [
                  _buildShieldIcon(CharacterService.calculateDefense(_ath, _selectedDefense)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDefenseCircle('L', DefCategory.light),
                      const SizedBox(width: 8),
                      _buildDefenseCircle('M', DefCategory.medium),
                      const SizedBox(width: 8),
                      _buildDefenseCircle('H', DefCategory.heavy),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canSave ? _saveCharacter : null,
                child: Text(widget.character != null ? 'Update Character' : 'Create Character'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, int value, VoidCallback onDecrement, VoidCallback onIncrement) {
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
                    onPressed: value > CharacterService.minStat ? onDecrement : null,
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
                    onPressed: value < CharacterService.maxStat ? onIncrement : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiamondStat(String label, int value, int? tempValue) {
    return Transform.rotate(
      angle: 45 * 3.14159 / 180,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
        ),
        child: Transform.rotate(
          angle: -45 * 3.14159 / 180,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label),
                Text(value.toString()),
                if (tempValue != null) Text('(+$tempValue)'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShieldIcon(int value) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        shape: BoxShape.circle,
      ),
      child: Center(child: Text(value.toString())),
    );
  }

  Widget _buildDefenseCircle(String label, DefCategory category) {
    final isSelected = _selectedDefense == category;
    return IconButton(
      icon: Text(
        label,
        style: TextStyle(
          fontSize: 30 * 0.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : AppTheme.primaryColor,
        ),
      ),
      onPressed: () => _selectDefense(category),
      style: IconButton.styleFrom(
        backgroundColor: isSelected ? AppTheme.highlightColor : Colors.transparent,
        shape: const CircleBorder(),
        side: BorderSide(
          color: isSelected ? AppTheme.accentColor : AppTheme.primaryColor,
          width: 2,
        ),
        minimumSize: const Size(30, 30),
        padding: EdgeInsets.zero,
      ),
    );
  }
} 