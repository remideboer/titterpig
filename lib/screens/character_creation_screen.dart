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
import '../models/species_option.dart';
import '../models/def_category.dart';
import '../theme/app_theme.dart';
import '../models/spell.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/settings_repository.dart';
import '../widgets/shield_icon.dart';
import '../widgets/heart_icon.dart';
import '../widgets/power_icon.dart';
import '../widgets/stat_value_icon.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/name_formatter.dart';
import 'package:provider/provider.dart';
import '../viewmodels/spell_list_viewmodel.dart';
import 'spell_selection_screen.dart';

class CharacterCreationScreen extends StatefulWidget {
  final Character? character;
  final Function(Character)? onCharacterSaved;

  const CharacterCreationScreen({
    Key? key,
    this.character,
    this.onCharacterSaved,
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
  List<SpeciesOption> _dropdownOptions = [];
  late DefCategory _selectedDefense;
  bool _showSpellOverlay = false;
  List<Spell> _spells = [];

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
      _remainingPoints = 0;
      _selectedDefense = widget.character!.defCategory;
    } else {
      _selectedDefense = DefCategory.none;
    }
  }

  Future<void> _loadSpecies() async {
    final species = await _speciesRepository.getSpecies();
    setState(() {
      _availableSpecies = species;
      _dropdownOptions = [
        ...species.map((s) => SpeciesOption(species: s)),
        const SpeciesOption(
          species: Species(name: 'Custom Species', icon: 'human-face.svg'),
          isCustomOption: true,
        ),
      ];
      if (widget.character == null) {
        _selectedSpecies = species.isNotEmpty ? species.first : const Species(name: 'Human', icon: 'human-face.svg');
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

  void _toggleSpellOverlay() {
    setState(() {
      _showSpellOverlay = !_showSpellOverlay;
    });
  }

  void _addSpell(Spell spell) {
    setState(() {
      _spells.add(spell);
    });
  }

  Future<void> _saveCharacter() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
      return;
    }

    Character savedCharacter;
    if (widget.character != null) {
      // Update existing character
      savedCharacter = Character(
        id: widget.character!.id,
        name: _nameController.text,
        species: _selectedSpecies,
        vit: _vit,
        ath: _ath,
        wil: _wil,
        tempHp: widget.character!.tempHp,
        defCategory: _selectedDefense,
        hasShield: widget.character!.hasShield,
        spells: _spells,
        sessionLog: widget.character!.sessionLog,
        notes: widget.character!.notes,
        xp: widget.character!.xp,
        createdAt: widget.character!.createdAt,
        lastUsed: DateTime.now(),
      );
      await _repository.updateCharacter(savedCharacter);
    } else {
      // Create new character
      savedCharacter = Character(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        species: _selectedSpecies,
        vit: _vit,
        ath: _ath,
        wil: _wil,
        defCategory: _selectedDefense,
        spells: _spells,
        createdAt: DateTime.now(),
        lastUsed: DateTime.now(),
      );
      await _repository.addCharacter(savedCharacter);
    }

    if (widget.onCharacterSaved != null) {
      widget.onCharacterSaved!(savedCharacter);
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
    final screenSize = MediaQuery.of(context).size;

    // Find the current species option or use the first one if not found
    final currentOption = _dropdownOptions.firstWhere(
      (option) => option.species == _selectedSpecies,
      orElse: () => _dropdownOptions.isNotEmpty ? _dropdownOptions.first : const SpeciesOption(
        species: Species(name: 'Human', icon: 'human-face.svg'),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.character != null ? 'Edit Character' : 'Create Character'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
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
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<SpeciesOption>(
                        value: currentOption,
                        decoration: const InputDecoration(
                          labelText: 'Species',
                          border: OutlineInputBorder(),
                        ),
                        items: _dropdownOptions.map((option) {
                          return DropdownMenuItem<SpeciesOption>(
                            value: option,
                            child: Text(option.species.name),
                          );
                        }).toList(),
                        onChanged: (SpeciesOption? value) {
                          if (value != null) {
                            if (value.isCustomOption) {
                              // Show custom species dialog
                              showDialog(
                                context: context,
                                builder: (context) {
                                  final controller = TextEditingController();
                                  return AlertDialog(
                                    title: const Text('Custom Species'),
                                    content: TextField(
                                      controller: controller,
                                      autofocus: true,
                                      inputFormatters: [
                                        TextInputFormatter.withFunction((oldValue, newValue) {
                                          if (newValue.text.isEmpty) return newValue;
                                          return TextEditingValue(
                                            text: newValue.text[0].toUpperCase() + 
                                                  (newValue.text.length > 1 ? newValue.text.substring(1) : ''),
                                            selection: newValue.selection,
                                          );
                                        }),
                                      ],
                                      decoration: const InputDecoration(
                                        labelText: 'Species Name',
                                        border: OutlineInputBorder(),
                                      ),
                                      onSubmitted: (name) {
                                        if (name.isNotEmpty) {
                                          setState(() {
                                            _selectedSpecies = Species(
                                              name: name[0].toUpperCase() + (name.length > 1 ? name.substring(1) : ''),
                                              icon: 'human-face.svg',
                                              isCustom: true,
                                            );
                                          });
                                          Navigator.of(context).pop();
                                        }
                                      },
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          if (controller.text.isNotEmpty) {
                                            setState(() {
                                              _selectedSpecies = Species(
                                                name: controller.text[0].toUpperCase() + 
                                                      (controller.text.length > 1 ? controller.text.substring(1) : ''),
                                                icon: 'human-face.svg',
                                                isCustom: true,
                                              );
                                            });
                                            Navigator.of(context).pop();
                                          }
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              setState(() {
                                _selectedSpecies = value.species;
                              });
                            }
                          }
                        },
                      ),
                    ),
                  ],
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
                const SizedBox(height: 24),

                // Spells Section
                Container(
                  decoration: AppTheme.defaultBorder,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ABILITIES',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _toggleSpellOverlay,
                          ),
                        ],
                      ),
                      if (_spells.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            itemCount: _spells.length,
                            itemBuilder: (context, index) {
                              final spell = _spells[index];
                              return ListTile(
                                contentPadding: const EdgeInsets.only(left: 0),
                                leading: _buildHexagon(spell.cost.toString(), ''),
                                title: Text(spell.name),
                                subtitle: spell.effect.isNotEmpty ? Text(spell.effect) : null,
                                trailing: IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    setState(() {
                                      _spells.removeAt(index);
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

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
          // Spell selection overlay
          if (_showSpellOverlay)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  width: screenSize.width * 0.8,
                  height: screenSize.height * 0.6,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Available Abilities',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: _toggleSpellOverlay,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Max Power: $power',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: Spell.availableSpells.length,
                          itemBuilder: (context, index) {
                            final spell = Spell.availableSpells[index];
                            final canAdd = spell.cost <= power && 
                                        !_spells.any((s) => s.name == spell.name);
                            return ListTile(
                              title: Text(
                                spell.name,
                                style: TextStyle(
                                  color: canAdd ? null : Colors.grey,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Cost: ${spell.cost}'),
                                  if (spell.effect.isNotEmpty)
                                    Text('Effect: ${spell.effect}'),
                                ],
                              ),
                              trailing: canAdd
                                ? IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () => _addSpell(spell),
                                  )
                                : Tooltip(
                                    message: spell.cost > power 
                                      ? 'Requires more power' 
                                      : 'Already learned',
                                    child: const Icon(Icons.lock, color: Colors.grey),
                                  ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
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

  Widget _buildHexagon(String value, String label) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        children: [
          HexagonContainer(
            size: 40,
            fillColor: AppTheme.primaryColor,
            borderColor: AppTheme.highlightColor,
            borderWidth: 2,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (label.isNotEmpty)
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 