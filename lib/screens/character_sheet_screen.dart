import 'package:flutter/material.dart';
import '../models/character.dart';
import '../models/stat_value.dart';
import '../widgets/hexagon_shape.dart';
import '../theme/app_theme.dart';
import '../models/spell.dart';
import '../repositories/local_character_repository.dart';
import '../repositories/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/shield_icon.dart';
import '../widgets/heart_icon.dart';
import '../widgets/power_icon.dart';
import '../widgets/stat_value_icon.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/name_formatter.dart';
import '../models/def_category.dart';
import 'spell_selection_screen.dart';
import 'spell_detail_screen.dart';
import 'character_creation_screen.dart';
import 'package:ttrpg_character_manager/widgets/animated_dice.dart';
import '../utils/sound_manager.dart';
import '../utils/spell_limit_calculator.dart';
import '../widgets/character_background_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  void _selectDefense(DefCategory category) {
    setState(() {
      selectedDefense = selectedDefense == category ? DefCategory.none : category;
      _character.defCategory = selectedDefense;
      _character.updateDerivedStats();
      _updateLastUsed();
    });
  }

  void _toggleSpellOverlay() {
    setState(() {
      _showSpellOverlay = !_showSpellOverlay;
    });
  }

  void _addSpell(Spell spell) {
    setState(() {
      _character.spells.add(spell);
      _character.updateDerivedStats();
      _updateLastUsed();
    });
  }

  Future<void> _handleSpellUse(Spell spell, {bool shouldRollDice = false}) async {
    if (_character.availablePower < spell.cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Insufficient power to cast ${spell.name} (requires ${spell.cost} power)',
            style: TextStyle(color: AppTheme.accentColor),
          ),
          backgroundColor: AppTheme.highlightColor,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Cast the spell first
    setState(() {
      _character.availablePower -= spell.cost;
      _updateLastUsed();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Used ${spell.name} (${spell.cost} power)'),
          backgroundColor: AppTheme.greenColor,
          duration: const Duration(seconds: 2),
        ),
      );
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

  void _castSpell(Spell spell) {
    _handleSpellUse(spell);
  }

  void _throwDice(Spell spell) {
    _handleSpellUse(spell, shouldRollDice: true);
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

  void _takeDamage() {
    setState(() {
      if (_character.hpStat.current > 0) {
        // First try to reduce temp HP if available
        if (_character.tempHp > 0) {
          _character.tempHp--;
        } else {
          // If no temp HP, reduce actual HP
          _character.hpStat = _character.hpStat.copyWithCurrent(
            _character.hpStat.current - 1
          );
        }
      } else if (_character.lifeStat.current > 0) {
        _character.decreaseLife();
        if (_character.lifeStat.current == 0) {
          _showDeathDialog();
        }
      }
      _character.updateDerivedStats();
      _updateLastUsed();
    });
  }

  void _heal() {
    setState(() {
      // First try to heal HP if not at max
      if (_character.hpStat.current < _character.hpStat.max) {
        _character.hpStat = _character.hpStat.copyWithCurrent(
          _character.hpStat.current + 1
        );
      } else if (_character.lifeStat.current < _character.lifeStat.max) {
        // If HP is at max, try to heal life
        _character.increaseLife();
      }
      _character.updateDerivedStats();
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
    final isDead = _character.lifeStat.current == 0;

    var defOptionScreenProportion = 0.5;
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main stats row (VIT, ATH, WIL)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatBox('VIT', _character.vit),
                  _buildStatBox('ATH', _character.ath),
                  _buildStatBox('WIL', _character.wil),
                ],
              ),
              const SizedBox(height: 24),

              // Health and power row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      _buildHpAndLifeDiamonds(svgStatSize),
                      const SizedBox(height: 8)
                    ],
                  ),
                  Opacity(
                    opacity: isDead ? 0.5 : 1.0,
                    child: PowerIcon(
                      value: _character.powerStat,
                      size: svgStatSize,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Defense section
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildActionButton(
                          icon: Icons.remove,
                          onPressed: _takeDamage,
                          color: Colors.red,
                          enabled: !isDead,
                        ),
                        const SizedBox(width: 8),
                        _buildShieldIcon(_character.def, svgStatSize),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          icon: Icons.add,
                          onPressed: _heal,
                          color: Colors.green,
                          enabled: !isDead,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Armor type selection row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDefenseCircle('L', DefCategory.light, selectedDefense == DefCategory.light, svgStatSize * defOptionScreenProportion),
                        const SizedBox(width: 8),
                        _buildDefenseCircle('M', DefCategory.medium, selectedDefense == DefCategory.medium, svgStatSize * defOptionScreenProportion),
                        const SizedBox(width: 8),
                        _buildDefenseCircle('H', DefCategory.heavy, selectedDefense == DefCategory.heavy, svgStatSize * defOptionScreenProportion),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Abilities section container - lists learned spells and allows adding new ones
              Container(
                decoration: AppTheme.defaultBorder,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Abilities header row with title and add button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ABILITIES',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        TextButton.icon(
                          onPressed: _showSpellSelection,
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('Manage Spells'),
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
                            final sortedSpells = List<Spell>.from(_character.spells)
                              ..sort((a, b) {
                                final aAvailable = a.cost <= _character.availablePower;
                                final bAvailable = b.cost <= _character.availablePower;
                                if (aAvailable != bAvailable) {
                                  return aAvailable ? -1 : 1; // Available spells first
                                }
                                return a.cost.compareTo(b.cost); // Then sort by cost
                              });

                            return ListView.builder(
                              itemCount: sortedSpells.length,
                              itemBuilder: (context, index) {
                                final spell = sortedSpells[index];
                                final canUse = spell.cost <= _character.availablePower;
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  child: ListTile(
                                    leading: _buildHexagon(spell.cost.toString(), ''),
                                    title: Text(
                                      spell.name,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (spell.effectValue != null)
                                          Text(
                                            '${spell.effectValue}',
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: AppTheme.highlightColor,
                                            ),
                                          ),
                                        Text(
                                          '${spell.type} • Range: ${spell.range}',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: AppTheme.highlightColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Dice icon (only shown for spells with effectValue)
                                        if (spell.effectValue != null)
                                          IconButton(
                                            icon: const Icon(Icons.casino),
                                            color: canUse ? AppTheme.highlightColor : Colors.grey,
                                            onPressed: canUse ? () => _throwDice(spell) : null,
                                            tooltip: canUse ? 'Roll dice' : 'Not enough power',
                                          )
                                        else
                                          const SizedBox(width: 48), // Empty space to maintain alignment
                                        IconButton(
                                          icon: Icon(canUse ? Icons.flash_on : Icons.flash_off),
                                          color: canUse ? AppTheme.highlightColor : Colors.grey,
                                          onPressed: canUse ? () => _castSpell(spell) : null,
                                          tooltip: canUse ? 'Cast spell' : 'Not enough power',
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SpellDetailScreen(spell: spell),
                                        ),
                                      );
                                    },
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

  Widget _buildHpAndLifeDiamonds(double size) {
    final isDead = _character.lifeStat.current == 0;
    
    return Stack(
      children: [
        // Main HP and LIFE diamonds
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatValueIcon(
              svgAsset: 'assets/svg/hp.svg',
              value: _character.hpStat,
              size: size,
              color: isDead ? Colors.grey : AppTheme.highlightColor,
            ),
            const SizedBox(width: 8),
            isDead
                ? SvgPicture.asset(
                    'assets/svg/death-skull.svg',
                    width: size,
                    height: size,
                    colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                  )
                : _buildDiamondStat('LIFE', _character.lifeStat, null, size),
          ],
        ),
        // TEMP HP diamond
        if (_character.tempHp > 0 && !isDead)
          Positioned(
            left: size * 0.6,
            top: 0,
            child: _buildTempHpDiamond(size * 0.5),
          ),
        // Labels
        Positioned(
          left: -size * 0.5,
          top: size * 0.3,
          child: Transform.rotate(
            angle: -45 * 3.14159 / 180,
            child: Text(
              'HP',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: size * 0.25,
                color: isDead ? Colors.grey : AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Positioned(
          right: -size * 0.5,
          top: size * 0.3,
          child: Transform.rotate(
            angle: 45 * 3.14159 / 180,
            child: Text(
              'LIFE',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: size * 0.25,
                color: isDead ? Colors.grey : AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShieldIcon(int value, double size) {
    return SizedBox(
      height: size * 1.5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShieldIcon(
            size: size,
            value: value,
          ),
          const SizedBox(height: 4),
          Text(
            'DEF',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: size * 0.18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefenseCircle(String label, DefCategory category, bool isSelected, double size) {
    return IconButton(
      icon: Text(
        label,
        style: TextStyle(
          fontSize: size * 0.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : AppTheme.primaryColor,
        ),
      ),
      onPressed: () {
        setState(() {
          selectedDefense = selectedDefense == category ? DefCategory.none : category;
          _character.defCategory = selectedDefense;
          _character.updateDerivedStats();
          _updateLastUsed();
        });
      },
      style: IconButton.styleFrom(
        backgroundColor: isSelected ? AppTheme.highlightColor : Colors.transparent,
        shape: const CircleBorder(),
        side: BorderSide(
          color: isSelected ? AppTheme.accentColor : AppTheme.primaryColor,
          width: 2,
        ),
        minimumSize: Size(size, size),
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

  Widget _buildDiamondStat(String label, StatValue value, int? tempValue, double size) {
    // Calculate the size needed to fit the rotated diamond
    final containerSize = size * 1.4142; // sqrt(2) to account for 45-degree rotation
    return SizedBox(
      width: containerSize,
      height: containerSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // TEMP HP diamond (only for HP stat)
          if (label == 'HP' && tempValue != null && tempValue > 0)
            Positioned(
              bottom: 0,
              child: Transform.rotate(
                angle: 45 * 3.14159 / 180,
                child: CustomPaint(
                  size: Size(size, size),
                  painter: DottedBorderPainter(),
                  child: Container(
                    width: size,
                    height: size,
                    child: Transform.rotate(
                      angle: -45 * 3.14159 / 180,
                      child: Center(
                        child: Text(
                          tempValue.toString(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: size * 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          // Main diamond or icon
          if (label == 'LIFE')
            HeartIcon(
              size: size,
              value: value,
            )
          else
            Transform.rotate(
              angle: 45 * 3.14159 / 180,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.primaryColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Transform.rotate(
                  angle: -45 * 3.14159 / 180,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          value.toString(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: size * 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '/${value.maxString}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: size * 0.18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // Angled label for HP (parallel to left side)
          if (label == 'HP')
            Positioned(
              left: -size * 0.4,
              top: containerSize * 0.5,
              child: Transform.rotate(
                angle: -45 * 3.14159 / 180,
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: size * 0.18,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTempHpDiamond(double size) {
    return Transform.rotate(
      angle: 45 * 3.14159 / 180,
      child: CustomPaint(
        size: Size(size, size),
        painter: DottedBorderPainter(),
        child: Container(
          width: size,
          height: size,
          child: Transform.rotate(
            angle: -45 * 3.14159 / 180,
            child: Center(
              child: Text(
                _character.tempHp.toString(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: size * 0.4,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required VoidCallback onPressed, required Color color, bool enabled = true}) {
    return IconButton(
      icon: Icon(icon, color: enabled ? color : Colors.grey),
      onPressed: enabled ? onPressed : () {},
      style: IconButton.styleFrom(
        disabledForegroundColor: Colors.grey,
      ),
    );
  }

  Widget _buildStatBox(String label, int value) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth = screenWidth * 0.25; // 25% of screen width
    final boxHeight = boxWidth * 0.75; // 3:4 ratio

    return Container(
      width: boxWidth,
      height: boxHeight,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.highlightColor,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label, 
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.accentColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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

class DottedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dashWidth = 5.0;
    final dashSpace = 5.0;
    final width = size.width;
    final height = size.height;
    final centerX = width / 2;
    final centerY = height / 2;

    // Calculate diamond points
    final top = Offset(centerX, 0);
    final right = Offset(width, centerY);
    final bottom = Offset(centerX, height);
    final left = Offset(0, centerY);

    // Draw top to right
    for (double i = 0; i < 1; i += (dashWidth + dashSpace) / width) {
      final start = Offset(
        top.dx + (right.dx - top.dx) * i,
        top.dy + (right.dy - top.dy) * i,
      );
      final end = Offset(
        top.dx + (right.dx - top.dx) * (i + dashWidth / width),
        top.dy + (right.dy - top.dy) * (i + dashWidth / width),
      );
      canvas.drawLine(start, end, paint);
    }

    // Draw right to bottom
    for (double i = 0; i < 1; i += (dashWidth + dashSpace) / height) {
      final start = Offset(
        right.dx + (bottom.dx - right.dx) * i,
        right.dy + (bottom.dy - right.dy) * i,
      );
      final end = Offset(
        right.dx + (bottom.dx - right.dx) * (i + dashWidth / height),
        right.dy + (bottom.dy - right.dy) * (i + dashWidth / height),
      );
      canvas.drawLine(start, end, paint);
    }

    // Draw bottom to left
    for (double i = 0; i < 1; i += (dashWidth + dashSpace) / width) {
      final start = Offset(
        bottom.dx + (left.dx - bottom.dx) * i,
        bottom.dy + (left.dy - bottom.dy) * i,
      );
      final end = Offset(
        bottom.dx + (left.dx - bottom.dx) * (i + dashWidth / width),
        bottom.dy + (left.dy - bottom.dy) * (i + dashWidth / width),
      );
      canvas.drawLine(start, end, paint);
    }

    // Draw left to top
    for (double i = 0; i < 1; i += (dashWidth + dashSpace) / height) {
      final start = Offset(
        left.dx + (top.dx - left.dx) * i,
        left.dy + (top.dy - left.dy) * i,
      );
      final end = Offset(
        left.dx + (top.dx - left.dx) * (i + dashWidth / height),
        left.dy + (top.dy - left.dy) * (i + dashWidth / height),
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 