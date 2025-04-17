import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/spell.dart';
import '../models/character.dart';
import '../viewmodels/spell_list_viewmodel.dart';
import '../widgets/hexagon_shape.dart';
import '../theme/app_theme.dart';

class SpellSelectionScreen extends StatefulWidget {
  final Function(Spell) onSpellSelected;
  final List<Spell> selectedSpells;
  final Character character;

  const SpellSelectionScreen({
    super.key,
    required this.onSpellSelected,
    required this.selectedSpells,
    required this.character,
  });

  @override
  State<SpellSelectionScreen> createState() => _SpellSelectionScreenState();
}

class _SpellSelectionScreenState extends State<SpellSelectionScreen> {
  late List<Spell> _selectedSpells;

  @override
  void initState() {
    super.initState();
    _selectedSpells = List.from(widget.selectedSpells);
  }

  void _handleSpellSelection(Spell spell) {
    setState(() {
      if (_selectedSpells.any((s) => s.name == spell.name)) {
        _selectedSpells.removeWhere((s) => s.name == spell.name);
      } else {
        _selectedSpells.add(spell);
      }
      widget.onSpellSelected(spell);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Spells'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Consumer<SpellListViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${viewModel.error}'),
                  ElevatedButton(
                    onPressed: () => viewModel.loadSpells(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final spells = viewModel.spells;
          if (spells.isEmpty) {
            return const Center(child: Text('No spells available'));
          }

          return ListView.builder(
            itemCount: spells.length,
            itemBuilder: (context, index) {
              final spell = spells[index];
              final isSelected = _selectedSpells.any((s) => s.name == spell.name);
              final isAvailable = spell.cost <= widget.character.power;

              return ListTile(
                leading: _buildHexagon(spell.cost.toString(), ''),
                title: Text(
                  spell.name,
                  style: TextStyle(
                    color: isAvailable ? null : Colors.grey,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (spell.damage.isNotEmpty)
                      Text('${spell.damage} ${spell.effect}'),
                    Text('${spell.type} • Range: ${spell.range}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.flash_on,
                      color: isAvailable ? Colors.amber : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isSelected ? Icons.check_circle : Icons.check_circle_outline,
                      color: isSelected 
                          ? Theme.of(context).primaryColor 
                          : (isAvailable ? Colors.grey : Colors.grey[300]),
                    ),
                  ],
                ),
                onTap: isAvailable
                    ? () => _handleSpellSelection(spell)
                    : null,
              );
            },
          );
        },
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