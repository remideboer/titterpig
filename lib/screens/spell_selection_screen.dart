import 'package:flutter/material.dart';
import '../models/spell.dart';
import '../models/character.dart';
import '../widgets/hexagon_shape.dart';
import '../theme/app_theme.dart';
import '../repositories/local_character_repository.dart';

class SpellSelectionScreen extends StatefulWidget {
  final List<Spell> selectedSpells;
  final Character character;

  const SpellSelectionScreen({
    super.key,
    required this.selectedSpells,
    required this.character,
  });

  @override
  State<SpellSelectionScreen> createState() => _SpellSelectionScreenState();
}

class _SpellSelectionScreenState extends State<SpellSelectionScreen> {
  late List<Spell> _selectedSpells;
  final LocalCharacterRepository _repository = LocalCharacterRepository();

  @override
  void initState() {
    super.initState();
    _selectedSpells = List.from(widget.selectedSpells);
  }

  Future<void> _handleSpellSelection(Spell spell) async {
    setState(() {
      if (_selectedSpells.any((s) => s.name == spell.name)) {
        _selectedSpells.removeWhere((s) => s.name == spell.name);
      } else {
        _selectedSpells.add(spell);
      }
    });
    
    // Save changes immediately without closing
    await _saveChanges(shouldNavigate: false);
  }

  Future<void> _saveChanges({bool shouldNavigate = true}) async {
    final updatedCharacter = widget.character.copyWith(
      spells: List<Spell>.from(_selectedSpells),
    );
    updatedCharacter.updateDerivedStats();
    await _repository.updateCharacter(updatedCharacter);
    
    // Only navigate if explicitly requested
    if (shouldNavigate && mounted) {
      Navigator.pop(context, updatedCharacter);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _saveChanges(shouldNavigate: true);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Spells'),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              await _saveChanges(shouldNavigate: true);
              if (mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Max Power: ${widget.character.powerStat.max}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: Spell.availableSpells.length,
                itemBuilder: (context, index) {
                  final spell = Spell.availableSpells[index];
                  final isSelected = _selectedSpells.any((s) => s.name == spell.name);
                  final canSelect = spell.cost <= widget.character.powerStat.max;
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: ListTile(
                      leading: _buildHexagon(spell.cost.toString(), ''),
                      title: Text(spell.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (spell.damage.isNotEmpty)
                            Text('${spell.damage} ${spell.effect}'),
                          Text('${spell.type} • Range: ${spell.range}'),
                        ],
                      ),
                      trailing: isSelected
                        ? const Icon(Icons.check, color: AppTheme.primaryColor)
                        : (canSelect
                            ? IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => _handleSpellSelection(spell),
                              )
                            : Tooltip(
                                message: 'Requires more power',
                                child: const Icon(Icons.lock, color: Colors.grey),
                              )),
                      onTap: canSelect ? () => _handleSpellSelection(spell) : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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