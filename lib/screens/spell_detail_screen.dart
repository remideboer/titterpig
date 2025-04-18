import 'package:flutter/material.dart';
import '../models/spell.dart';
import '../widgets/hexagon_shape.dart';
import '../theme/app_theme.dart';
import 'spell_edit_screen.dart';

class SpellDetailScreen extends StatelessWidget {
  final Spell spell;
  final Function(Spell) onSpellSelected;
  final bool allowEditing;

  const SpellDetailScreen({
    super.key,
    required this.spell,
    required this.onSpellSelected,
    this.allowEditing = false,
  });

  void _editSpell(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpellEditScreen(
          spell: spell,
          onSave: (updatedSpell) {
            Navigator.pop(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SpellDetailScreen(
                  spell: updatedSpell,
                  onSpellSelected: onSpellSelected,
                  allowEditing: allowEditing,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(spell.name),
        actions: [
          if (allowEditing && !spell.isDndSpell)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editSpell(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Spell cost hexagon
            Center(
              child: _buildHexagon(spell.cost.toString(), 'Cost'),
            ),
            const SizedBox(height: 24),

            // Spell details
            if (spell.damage.isNotEmpty) ...[
              _buildDetailSection('Damage', spell.damage),
              const SizedBox(height: 16),
            ],
            _buildDetailSection('Effect', spell.effect),
            const SizedBox(height: 16),
            _buildDetailSection('Type', spell.type),
            const SizedBox(height: 16),
            _buildDetailSection('Range', spell.range),
            const SizedBox(height: 32),

            // Only show select button if onSpellSelected is not a no-op
            if (onSpellSelected.toString() != 'Closure: (Spell) => Null')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    onSpellSelected(spell);
                    Navigator.pop(context);
                  },
                  child: const Text('Select Spell'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHexagon(String value, String label) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        children: [
          HexagonContainer(
            size: 80,
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
                      fontSize: 24,
                    ),
                  ),
                  if (label.isNotEmpty)
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
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

  Widget _buildDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
} 