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

class CharacterSheetScreen extends StatefulWidget {
  final Character character;
  final Function(Character) onCharacterUpdated;

  const CharacterSheetScreen({
    super.key,
    required this.character,
    required this.onCharacterUpdated,
  });

  @override
  State<CharacterSheetScreen> createState() => _CharacterSheetScreenState();
}

class _CharacterSheetScreenState extends State<CharacterSheetScreen> {
  late DefCategory selectedDefense;
  bool _showSpellOverlay = false;
  final LocalCharacterRepository _repository = LocalCharacterRepository();
  SettingsRepository? _settingsRepository;

  @override
  void initState() {
    super.initState();
    selectedDefense = widget.character.defCategory;
    widget.character.updateDerivedStats();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _settingsRepository = SettingsRepository(prefs);
    });
  }

  void _selectDefense(DefCategory category) {
    setState(() {
      selectedDefense = selectedDefense == category ? DefCategory.none : category;
      widget.character.defCategory = selectedDefense;
      widget.character.updateDerivedStats();
      _repository.updateCharacter(widget.character);
    });
  }

  void _toggleSpellOverlay() {
    setState(() {
      _showSpellOverlay = !_showSpellOverlay;
    });
  }

  void _addSpell(Spell spell) {
    setState(() {
      widget.character.spells.add(spell);
      widget.character.updateDerivedStats();
      _repository.updateCharacter(widget.character);
    });
  }

  void _useSpell(Spell spell) {
    if (widget.character.availablePower >= spell.cost) {
      setState(() {
        widget.character.availablePower -= spell.cost;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough power!')),
      );
    }
  }

  void _resetPower() {
    setState(() {
      widget.character.availablePower = widget.character.powerStat.max;
    });
  }

  void _takeDamage() {
    setState(() {
      if (widget.character.hpStat.current > 0) {
        // First try to reduce temp HP if available
        if (widget.character.tempHp > 0) {
          widget.character.tempHp--;
        } else {
          // If no temp HP, reduce actual HP
          widget.character.hpStat = widget.character.hpStat.copyWithCurrent(
            widget.character.hpStat.current - 1
          );
        }
      } else if (widget.character.lifeStat.current > 0) {
        widget.character.decreaseLife();
        if (widget.character.lifeStat.current == 0) {
          _showDeathDialog();
        }
      }
      widget.character.updateDerivedStats();
      _repository.updateCharacter(widget.character);
    });
  }

  void _heal() {
    setState(() {
      // First try to heal HP if not at max
      if (widget.character.hpStat.current < widget.character.hpStat.max) {
        widget.character.hpStat = widget.character.hpStat.copyWithCurrent(
          widget.character.hpStat.current + 1
        );
      } else if (widget.character.lifeStat.current < widget.character.lifeStat.max) {
        // If HP is at max, try to heal life
        widget.character.increaseLife();
      }
      widget.character.updateDerivedStats();
      _repository.updateCharacter(widget.character);
    });
  }

  void _showDeathDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Character Death'),
        content: Text('${NameFormatter.formatName(widget.character.name)} died :('),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final mainStatSize = screenSize.width * 0.25;
    final svgStatSize = mainStatSize;
    final isDead = widget.character.lifeStat.current == 0;

    var defOptionScreenProportion = 0.5;
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) {
          widget.character.updateDerivedStats();
          await widget.onCharacterUpdated(widget.character);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${NameFormatter.formatName(widget.character.name)} (${widget.character.species.name})',
            style: AppTheme.titleStyle.copyWith(
              color: isDead ? Colors.grey : null,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetPower,
              tooltip: 'Reset Power',
            ),
          ],
        ),
        body: Stack(
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
                      _buildStatBox('VIT', widget.character.vit),
                      _buildStatBox('ATH', widget.character.ath),
                      _buildStatBox('WIL', widget.character.wil),
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
                          value: widget.character.powerStat,
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
                            _buildShieldIcon(widget.character.def, svgStatSize),
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
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _toggleSpellOverlay,
                            ),
                          ],
                        ),
                        if (widget.character.spells.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          // List of learned spells with cost hexagons
                          SizedBox(
                            height: 200, // Fixed height for the scrollable list
                            child: ListView.builder(
                              itemCount: widget.character.spells.length,
                              itemBuilder: (context, index) {
                                // Sort spells by cost
                                final sortedSpells = List<Spell>.from(widget.character.spells)
                                  ..sort((a, b) => a.cost.compareTo(b.cost));
                                final spell = sortedSpells[index];
                                final canUse = spell.cost <= widget.character.availablePower;
                                return ListTile(
                                  contentPadding: const EdgeInsets.only(left: 0),
                                  leading: _buildHexagon(spell.cost.toString(), ''),
                                  title: Text(spell.name),
                                  subtitle: spell.effect.isNotEmpty ? Text(spell.effect) : null,
                                  trailing: Icon(
                                    Icons.flash_on,
                                    color: canUse ? Colors.amber : Colors.grey,
                                  ),
                                  onTap: canUse ? () => _useSpell(spell) : null,
                                  onLongPress: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(spell.name),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Cost: ${spell.cost}'),
                                            if (spell.effect.isNotEmpty) ...[
                                              const SizedBox(height: 8),
                                              Text('Effect: ${spell.effect}'),
                                            ],
                                            const SizedBox(height: 16),
                                            Text(
                                              canUse 
                                                ? 'You have enough power to use this spell'
                                                : 'You need ${spell.cost - widget.character.availablePower} more power to use this spell',
                                              style: TextStyle(
                                                color: canUse ? Colors.green : Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: const Text('Close'),
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
            // Spell selection overlay - appears when adding new spells
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
                        // Overlay header with title and close button
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
                          'Max Power: ${widget.character.power}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        // List of available spells to learn
                        Expanded(
                          child: ListView.builder(
                            itemCount: Spell.availableSpells.length,
                            itemBuilder: (context, index) {
                              final spell = Spell.availableSpells[index];
                              final canAdd = spell.cost <= widget.character.power && 
                                          !widget.character.spells.any((s) => s.name == spell.name);
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
                                      onPressed: () {
                                        _addSpell(spell);
                                        _toggleSpellOverlay();
                                      },
                                    )
                                  : Tooltip(
                                      message: spell.cost > widget.character.power 
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
      ),
    );
  }

  Widget _buildHpAndLifeDiamonds(double size) {
    final isDead = widget.character.lifeStat.current == 0;
    
    return Stack(
      children: [
        // Main HP and LIFE diamonds
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatValueIcon(
              svgAsset: 'assets/svg/hp.svg',
              value: widget.character.hpStat,
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
                : _buildDiamondStat('LIFE', widget.character.lifeStat, null, size),
          ],
        ),
        // TEMP HP diamond
        if (widget.character.tempHp > 0 && !isDead)
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
          widget.character.defCategory = selectedDefense;
          widget.character.updateDerivedStats();
          _repository.updateCharacter(widget.character);
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
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HexagonContainer(
            size: 40,
            child: Center(
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          if (label.isNotEmpty) 
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                label,
                style: const TextStyle(fontSize: 10),
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
                decoration: AppTheme.defaultBorder,
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
                widget.character.tempHp.toString(),
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
      decoration: AppTheme.defaultBorder,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.highlightColor,
          )),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
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