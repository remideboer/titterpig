import 'package:flutter/material.dart';
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
import '../utils/spell_limit_calculator.dart';
import 'package:flutter/services.dart';
import 'spell_selection_screen.dart';
import '../widgets/background_editor.dart';
import '../models/background.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../widgets/spell_list_item.dart';
import '../widgets/avatar_selector.dart';

class CharacterCreationScreen extends ConsumerStatefulWidget {
  final Character? character;
  final Function(Character)? onCharacterSaved;
  final int initialPage;

  const CharacterCreationScreen({
    Key? key,
    this.character,
    this.onCharacterSaved,
    this.initialPage = 0,
  }) : super(key: key);

  @override
  ConsumerState<CharacterCreationScreen> createState() => _CharacterCreationScreenState();
}

class _CharacterCreationScreenState extends ConsumerState<CharacterCreationScreen> {
  final _nameController = TextEditingController();
  final _repository = LocalCharacterRepository();
  final _speciesRepository = SpeciesRepository();
  final _nameGeneratorService = NameGeneratorService(NameDataRepository());
  late final PageController _pageController;
  late int _currentPage;
  
  int _vit = 0;
  int _ath = 0;
  int _wil = 0;
  int _remainingPoints = CharacterService.totalPoints;
  Species _selectedSpecies = const Species(name: 'Human', icon: 'human-face.svg');
  List<Species> _availableSpecies = [];
  List<SpeciesOption> _dropdownOptions = [];
  late DefCategory _selectedDefense;
  bool _showSpellOverlay = false;
  List<Ability> _spells = [];
  Background? _background;
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
    _loadSpecies();
    if (widget.character != null) {
      _nameController.text = widget.character!.name;
      _selectedSpecies = widget.character!.species;
      _vit = widget.character!.vit;
      _ath = widget.character!.ath;
      _wil = widget.character!.wil;
      _remainingPoints = 0;
      _selectedDefense = widget.character!.defCategory;
      _spells = List.from(widget.character!.spells);
      _background = widget.character!.background;
      _avatarPath = widget.character!.avatarPath;
    } else {
      _selectedDefense = DefCategory.none;
      _spells = [];
      _background = null;
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
    setState(() {
      switch (stat) {
        case 'vit': _vit = value; break;
        case 'ath': _ath = value; break;
        case 'wil': 
          _wil = value;
          // If reducing WIL would put us over the spell limit, remove excess spells
          final spellLimit = SpellLimitCalculator.calculateSpellLimit(_wil);
          if (_spells.length > spellLimit) {
            _spells = _spells.sublist(0, spellLimit);
          }
          break;
        default: throw ArgumentError('Invalid stat: $stat');
      }
    });
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

  void _addSpell(Ability spell) {
    setState(() {
      _spells.add(spell);
    });
  }

  Future<void> _saveCharacter() async {
    if (!_canSave) return;

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
        avatarPath: _avatarPath,
        tempHp: widget.character!.tempHp,
        defCategory: _selectedDefense,
        hasShield: widget.character!.hasShield,
        spells: _spells,
        sessionLog: widget.character!.sessionLog,
        notes: widget.character!.notes,
        xp: widget.character!.xp,
        createdAt: widget.character!.createdAt,
        lastUsed: DateTime.now(),
        background: _background,
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
        avatarPath: _avatarPath,
        defCategory: _selectedDefense,
        spells: _spells,
        createdAt: DateTime.now(),
        lastUsed: DateTime.now(),
        background: _background,
      );
      await _repository.addCharacter(savedCharacter);
    }

    if (widget.onCharacterSaved != null) {
      widget.onCharacterSaved!(savedCharacter);
    }

    if (mounted) {
      Navigator.of(context).pop(savedCharacter);
    }
  }

  void _showSpellSelection() async {
    final spellLimit = SpellLimitCalculator.calculateSpellLimit(_wil);
    if (_spells.length >= spellLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You can\'t have more than $spellLimit spells with WIL $_wil'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final result = await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: SpellSelectionScreen(
            selectedSpells: _spells,
            maxSpells: spellLimit,
            onSpellsChanged: (updatedSpells) {
              setState(() {
                _spells = updatedSpells;
              });
            },
          ),
        ),
      ),
    );
  }

  void _generateRandomCharacter() {
    final generator = ref.read(characterGeneratorProvider);
    final randomCharacter = generator.generateRandomCharacter();

    setState(() {
      _nameController.text = randomCharacter.name;
      _selectedSpecies = randomCharacter.species;
      _vit = randomCharacter.vit;
      _ath = randomCharacter.ath;
      _wil = randomCharacter.wil;
      _remainingPoints = 0;
      _avatarPath = randomCharacter.avatarPath;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildPageIndicator(int page, String label) {
    final isSelected = _currentPage == page;
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          page,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.highlightColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.highlightColor : AppTheme.primaryColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.primaryColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsView() {
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add random generation button at the top
          if (widget.character == null) // Only show for new characters
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton.icon(
                onPressed: _generateRandomCharacter,
                icon: const Icon(Icons.casino),
                label: const Text('Generate Random Character'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16.0),
                ),
              ),
            ),

          // Avatar Selector
          Center(
            child: AvatarSelector(
              initialAvatarPath: widget.character?.avatarPath,
              onAvatarSelected: (path) {
                setState(() {
                  _avatarPath = path;
                });
              },
              size: 120,
            ),
          ),
          const SizedBox(height: 24),

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
                  child: _buildStatInput('VIT', _vit, () => _updateStat('vit', -1), () => _updateStat('vit', 1)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildStatInput('ATH', _ath, () => _updateStat('ath', -1), () => _updateStat('ath', 1)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildStatInput('WIL', _wil, () => _updateStat('wil', -1), () => _updateStat('wil', 1)),
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
                    Row(
                      children: [
                        Text(
                          'ABILITIES',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${_spells.length}/${SpellLimitCalculator.calculateSpellLimit(_wil)})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.highlightColor,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _showSpellSelection,
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
                        return SpellListItem(
                          spell: spell,
                          actions: SpellListItemActions(
                            spell: spell,
                            actions: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    _spells.removeAt(index);
                                  });
                                },
                              ),
                            ],
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
    );
  }

  Widget _buildBackgroundView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Background',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          BackgroundEditor(
            background: _background,
            onSave: (background) {
              setState(() {
                _background = background;
                // Propagate changes immediately if we can
                if (_canSave && widget.onCharacterSaved != null) {
                  final updatedCharacter = widget.character != null
                    ? Character(
                        id: widget.character!.id,
                        name: _nameController.text,
                        species: _selectedSpecies,
                        vit: _vit,
                        ath: _ath,
                        wil: _wil,
                        avatarPath: _avatarPath,
                        tempHp: widget.character!.tempHp,
                        defCategory: _selectedDefense,
                        hasShield: widget.character!.hasShield,
                        spells: _spells,
                        sessionLog: widget.character!.sessionLog,
                        notes: widget.character!.notes,
                        xp: widget.character!.xp,
                        createdAt: widget.character!.createdAt,
                        lastUsed: DateTime.now(),
                        background: background,
                      )
                    : Character(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: _nameController.text,
                        species: _selectedSpecies,
                        vit: _vit,
                        ath: _ath,
                        wil: _wil,
                        avatarPath: _avatarPath,
                        defCategory: _selectedDefense,
                        spells: _spells,
                        createdAt: DateTime.now(),
                        lastUsed: DateTime.now(),
                        background: background,
                      );
                  widget.onCharacterSaved!(updatedCharacter);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.character != null ? 'Edit Character' : 'Create Character'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _canSave ? _saveCharacter : null,
            child: Text(
              widget.character != null ? 'Update' : 'Create',
              style: TextStyle(
                color: _canSave ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).disabledColor,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Page Indicator
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPageIndicator(0, 'Stats'),
                    const SizedBox(width: 16),
                    _buildPageIndicator(1, 'Background'),
                  ],
                ),
              ),
              // Swipeable Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    // If we're navigating away from background view, save the current state
                    if (_currentPage == 1 && _canSave && widget.onCharacterSaved != null) {
                      final updatedCharacter = widget.character != null
                        ? Character(
                            id: widget.character!.id,
                            name: _nameController.text,
                            species: _selectedSpecies,
                            vit: _vit,
                            ath: _ath,
                            wil: _wil,
                            avatarPath: _avatarPath,
                            tempHp: widget.character!.tempHp,
                            defCategory: _selectedDefense,
                            hasShield: widget.character!.hasShield,
                            spells: _spells,
                            sessionLog: widget.character!.sessionLog,
                            notes: widget.character!.notes,
                            xp: widget.character!.xp,
                            createdAt: widget.character!.createdAt,
                            lastUsed: DateTime.now(),
                            background: _background,
                          )
                        : Character(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            name: _nameController.text,
                            species: _selectedSpecies,
                            vit: _vit,
                            ath: _ath,
                            wil: _wil,
                            avatarPath: _avatarPath,
                            defCategory: _selectedDefense,
                            spells: _spells,
                            createdAt: DateTime.now(),
                            lastUsed: DateTime.now(),
                            background: _background,
                          );
                      widget.onCharacterSaved!(updatedCharacter);
                    }
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildStatsView(),
                    _buildBackgroundView(),
                  ],
                ),
              ),
            ],
          ),
          // Spell selection overlay
          if (_showSpellOverlay)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.6,
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
                        'Max Power: ${CharacterService.calculatePower(_wil)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: Ability.availableSpells.length,
                          itemBuilder: (context, index) {
                            final spell = Ability.availableSpells[index];
                            final canAdd = spell.cost <= CharacterService.calculatePower(_wil) && 
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
                                    message: spell.cost > CharacterService.calculatePower(_wil)
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
                    onPressed: label == 'VIT' 
                        ? (CharacterService.isValidVitForHp(value - 1) ? onIncrement : null)
                        : onIncrement,
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
                    onPressed: onDecrement,
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