import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:ttrpg_character_manager/widgets/animated_dice.dart';

import '../models/character.dart';
import '../models/def_category.dart';
import '../models/spell.dart';
import '../repositories/local_character_repository.dart';
import '../repositories/settings_repository.dart';
import '../theme/app_theme.dart';
import '../utils/name_formatter.dart';
import '../utils/snackbar_service.dart';
import '../utils/sound_manager.dart';
import '../utils/spell_limit_calculator.dart';
import '../widgets/character_background_view.dart';
import '../widgets/main_stats_row.dart';
import '../widgets/spell_list_item.dart';
import 'character_creation_screen.dart';
import 'spell_selection_screen.dart';
import '../widgets/secondary_stats_row.dart';
import '../widgets/stat_modifier_row.dart';
import '../widgets/avatar_selector.dart';
import '../viewmodels/character_list_viewmodel.dart';

class CharacterSheetScreen extends StatefulWidget {
  final Character character;
  final Function(Character)? onCharacterUpdated;

  const CharacterSheetScreen({
    super.key,
    required this.character,
    this.onCharacterUpdated,
  });

  @override
  State<CharacterSheetScreen> createState() => _CharacterSheetScreenState();
}

class _CharacterSheetScreenState extends State<CharacterSheetScreen> {
  late DefCategory selectedDefense;
  bool _showSpellOverlay = false;
  final LocalCharacterRepository _repository = LocalCharacterRepository();
  SettingsRepository? _settingsRepository;
  late Character _character;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    selectedDefense = widget.character.defCategory;
    _character = widget.character;
    _character.updateDerivedStats();
    _initializeSettings();
    _updateLastUsed();
  }

  @override
  void didUpdateWidget(CharacterSheetScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.character != oldWidget.character) {
      setState(() {
        _character = widget.character;
        selectedDefense = widget.character.defCategory;
        _character.updateDerivedStats();
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initializeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _settingsRepository = SettingsRepository(prefs);
    });
  }

  Future<void> _updateLastUsed() async {
    _character.lastUsed = DateTime.now();
    await _repository.updateCharacter(_character);
  }

  Future<void> _handleSpellUse(Ability spell,
      {bool shouldRollDice = false}) async {
    if (_character.availablePower < spell.cost) {
      SnackBarService.showInsufficientPowerMessage(
        context,
        spellName: spell.name,
        requiredPower: spell.cost,
      );
      return;
    }

    if (_character.isDead) {
      SnackBarService.showDeadCharacterMessage(context);
      return;
    }

    // Cast the spell first
    setState(() {
      _character.availablePower -= spell.cost;
      _updateLastUsed();
      SnackBarService.showSpellCastMessage(context, spell.name, spell.cost);
    });

    // Then roll dice if needed
    if (shouldRollDice && spell.effectValue != null) {
      // Play roll sound
      SoundManager().playRollSound();

      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            content: Stack(
              children: [
                AnimatedDice(
                  count: spell.effectValue!.count,
                  onRollComplete: (result) {
                    // Don't close automatically, let user close manually
                  },
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  void _showSpellSelection() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: SpellSelectionScreen(
            selectedSpells: _character.spells,
            maxSpells: SpellLimitCalculator.calculateSpellLimit(_character.wil),
            onSpellsChanged: (updatedSpells) {
              setState(() {
                _character.spells = updatedSpells;
                _character.updateDerivedStats();
                _updateLastUsed();
              });
            },
          ),
        ),
      ),
    );
  }

  void _heal([int amount = 1]) {
    setState(() {
      _character.heal(amount);
      _updateLastUsed();
    });
  }

  void _takeDamage([int amount = 1]) {
    setState(() {
      _character.takeDamage(amount);
      _updateLastUsed();
    });
  }

  void _showDeathDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Character Death'),
        content: Text('${NameFormatter.formatName(_character.name)} died :('),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _editCharacter() async {
    final updatedCharacter = await Navigator.push<Character>(
      context,
      MaterialPageRoute(
        builder: (context) => CharacterCreationScreen(
          character: _character,
          initialPage: _currentPage,
          onCharacterSaved: (character) {
            // Update character immediately when changes are made
            setState(() {
              _character = character;
              selectedDefense = character.defCategory;
              _updateLastUsed(); // Ensure we update the last used timestamp
            });
            if (widget.onCharacterUpdated != null) {
              widget.onCharacterUpdated!(character);
            }
          },
        ),
      ),
    );

    // Final update when editing is complete
    if (updatedCharacter != null) {
      setState(() {
        _character = updatedCharacter;
        selectedDefense = updatedCharacter.defCategory;
        _updateLastUsed();
      });
      if (widget.onCharacterUpdated != null) {
        widget.onCharacterUpdated!(updatedCharacter);
      }
    }
  }

  // Add this method to handle resurrection
  void _resurrectCharacter() {
    setState(() {
      _character.resurrect();
      _updateLastUsed();
      
      // Notify parent if needed
      if (widget.onCharacterUpdated != null) {
        widget.onCharacterUpdated!(_character);
      }
    });
  }

  void _showAvatarSelector() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Avatar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              AvatarSelector(
                initialAvatarPath: _character.avatarPath,
                onAvatarSelected: (path) async {
                  if (path != null) {
                    // Create updated character
                    final updatedCharacter = Character(
                      id: _character.id,
                      name: _character.name,
                      species: _character.species,
                      vit: _character.vit,
                      ath: _character.ath,
                      wil: _character.wil,
                      avatarPath: path,
                      tempHp: _character.tempHp,
                      defCategory: _character.defCategory,
                      hasShield: _character.hasShield,
                      spells: _character.spells,
                      sessionLog: _character.sessionLog,
                      notes: _character.notes,
                      xp: _character.xp,
                      createdAt: _character.createdAt,
                      lastUsed: DateTime.now(),
                      background: _character.background,
                    );

                    // Update in repository
                    await _repository.updateCharacter(updatedCharacter);

                    // Update local state
                    setState(() {
                      _character = updatedCharacter;
                    });

                    // Update last used timestamp
                    await _updateLastUsed();

                    // Notify parent widget and trigger character list reload
                    if (widget.onCharacterUpdated != null) {
                      widget.onCharacterUpdated!(updatedCharacter);
                    }

                    // Force a reload of the character list
                    if (mounted) {
                      final viewModel = context.read<CharacterListViewModel>();
                      await viewModel.loadCharacters();
                    }
                  }
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
                size: 150,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(NameFormatter.formatName(_character.name)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editCharacter,
          ),
        ],
      ),
      body: Column(
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
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildMainStatsView(),
                _buildBackgroundView(),
              ],
            ),
          ),
        ],
      ),
    );
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

  Widget _buildMainStatsView() {
    final screenSize = MediaQuery.of(context).size;
    final mainStatSize = screenSize.width * 0.25;
    final svgStatSize = mainStatSize;
    final isDead = _character.isDead;

    var defOptionScreenProportion = 0.5;
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar display
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Left placeholder for balance
                    SizedBox(
                      width: screenSize.width * 0.25,
                      child: isDead ? Container() : null,
                    ),
                    // Center avatar
                    GestureDetector(
                      onTap: isDead ? null : () => _showAvatarSelector(),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.surface,
                          border: Border.all(
                            color: isDead ? Colors.grey.withOpacity(0.5) : Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: _character.avatarPath != null
                              ? ColorFiltered(
                                  colorFilter: isDead
                                      ? const ColorFilter.matrix([
                                          0.2126, 0.7152, 0.0722, 0, 0,
                                          0.2126, 0.7152, 0.0722, 0, 0,
                                          0.2126, 0.7152, 0.0722, 0, 0,
                                          0, 0, 0, 1, 0,
                                        ])
                                      : const ColorFilter.mode(
                                          Colors.transparent,
                                          BlendMode.srcOver,
                                        ),
                                  child: Image.file(
                                    File(_character.avatarPath!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildDefaultAvatar();
                                    },
                                  ),
                                )
                              : _buildDefaultAvatar(),
                        ),
                      ),
                    ),
                    // Right side - resurrect button or placeholder
                    SizedBox(
                      width: screenSize.width * 0.25,
                      child: isDead
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Resurrect',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppTheme.highlightColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              IconButton(
                                onPressed: _resurrectCharacter,
                                icon: SvgPicture.asset(
                                  'assets/svg/resurrect.svg',
                                  width: 32,
                                  height: 32,
                                  colorFilter: const ColorFilter.mode(
                                    AppTheme.highlightColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                tooltip: 'Resurrect Character',
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  side: BorderSide(
                                    color: AppTheme.highlightColor,
                                    width: 2,
                                  ),
                                  padding: const EdgeInsets.all(8),
                                ),
                              ),
                            ],
                          )
                        : null,
                    ),
                  ],
                ),
              ),

              // Main stats row (VIT, ATH, WIL)
              Consumer(
                builder: (context, ref, child) => MainStatsRow(
                  character: _character,
                  size: 0.25,
                ),
              ),
              const SizedBox(height: 24),

              // Health and power row
              SecondaryStatsRow(
                character: _character,
                size: 0.25,
              ),
              const SizedBox(height: 24),

              // Defense section
              Center(
                child: StatModifierRow(
                  character: _character,
                  size: svgStatSize,
                  selectedDefense: selectedDefense,
                  onDefenseChanged: (category) {
                    setState(() {
                      selectedDefense = selectedDefense == category ? DefCategory.none : category;
                      _character.defCategory = selectedDefense;
                      _character.updateDerivedStats();
                      _updateLastUsed();
                    });
                  },
                  onHeal: _heal,
                  onTakeDamage: _takeDamage,
                  onShieldToggled: (hasShield) {
                    setState(() {
                      _character.hasShield = hasShield;
                      _character.updateDerivedStats();
                      _updateLastUsed();
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Abilities section container - lists learned spells and allows adding new ones
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDead ? Colors.grey : AppTheme.primaryColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Abilities header row with title and add button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'ABILITIES',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: isDead ? Colors.grey : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${_character.spells.length}/${SpellLimitCalculator.calculateSpellLimit(_character.wil)})',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: isDead ? Colors.grey : AppTheme.highlightColor,
                                  ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            if (_character.power > 0 && !isDead) ...[
                              Tooltip(
                                message:
                                    _character.availablePower < _character.power
                                        ? 'Restore power to maximum'
                                        : 'Power is already at maximum',
                                child: IconButton(
                                  onPressed: _character.availablePower <
                                          _character.power
                                      ? () {
                                          setState(() {
                                            _character.availablePower =
                                                _character.power;
                                            _updateLastUsed();
                                          });
                                          SnackBarService.showSpellCastMessage(
                                            context,
                                            'Power restored',
                                            _character.power,
                                          );
                                        }
                                      : null,
                                  icon: const Icon(Icons.refresh),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Tooltip(
                              message: isDead 
                                  ? 'Cannot manage spells while dead'
                                  : (_character.power < 1
                                      ? 'Insufficient maximum power to learn spells (requires WIL 1 or higher)'
                                      : 'Manage your character\'s spells'),
                              child: TextButton.icon(
                                onPressed: isDead ? null : (_character.power >= 1
                                    ? _showSpellSelection
                                    : null),
                                icon: Icon(
                                  Icons.auto_awesome,
                                  color: isDead ? Colors.grey : null,
                                ),
                                label: Text(
                                  'Manage Spells',
                                  style: TextStyle(
                                    color: isDead ? Colors.grey : null,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (_character.spells.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      // List of learned spells with cost hexagons
                      SizedBox(
                        height: 200, // Fixed height for the scrollable list
                        child: Builder(
                          builder: (context) {
                            // Sort spells by availability and then by cost
                            final sortedSpells =
                                List<Ability>.from(_character.spells)
                                  ..sort((a, b) {
                                    final aAvailable =
                                        a.cost <= _character.availablePower;
                                    final bAvailable =
                                        b.cost <= _character.availablePower;
                                    if (aAvailable != bAvailable) {
                                      return aAvailable
                                          ? -1
                                          : 1; // Available spells first
                                    }
                                    return a.cost
                                        .compareTo(b.cost); // Then sort by cost
                                  });

                            return ListView.builder(
                              itemCount: sortedSpells.length,
                              itemBuilder: (context, index) {
                                final spell = sortedSpells[index];
                                final canUse =
                                    !isDead && spell.cost <= _character.availablePower;
                                return SpellListItem(
                                  spell: spell,
                                  disabled: isDead,
                                  actions: SpellListItemActions(
                                    spell: spell,
                                    decorator: PowerCheckSpellActionDecorator(DefaultSpellActionDecorator()),
                                    actions: [
                                      if (spell.effectValue != null)
                                        IconButton(
                                          icon: const Icon(Icons.casino),
                                          onPressed: canUse
                                              ? () => _handleSpellUse(spell,
                                                  shouldRollDice: true)
                                              : null,
                                          color: canUse
                                              ? AppTheme.highlightColor
                                              : Colors.grey,
                                        ),
                                      IconButton(
                                        icon: Icon(canUse
                                            ? Icons.flash_on
                                            : Icons.flash_off),
                                        onPressed: canUse
                                            ? () => _handleSpellUse(spell)
                                            : null,
                                        color: canUse
                                            ? AppTheme.highlightColor
                                            : Colors.grey,
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    final isDead = _character.isDead;
    return Icon(
      Icons.person,
      size: 60,
      color: isDead ? Colors.grey : Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildBackgroundView() {
    if (_character.background == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_edu,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No background information available',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _editCharacter(),
              icon: const Icon(Icons.edit),
              label: const Text('Add Background'),
            ),
          ],
        ),
      );
    }

    return CharacterBackgroundView(
      background: _character.background,
      onEdit: () => _editCharacter(),
    );
  }
}
