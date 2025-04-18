import '../models/dnd_spell.dart';
import '../models/spell.dart';

class DndSpellConverter {
  static Spell convertToSpell(Map<String, dynamic> dndSpell) {
    return Spell(
      name: dndSpell['name'] ?? 'Unknown Spell',
      description: dndSpell['desc']?.join('\n') ?? 'No description available',
      cost: _calculateCost(dndSpell),
      isDndSpell: true,
      damage: dndSpell['damage']?['damage_at_slot_level']?.values.first ?? '',
      effect: dndSpell['desc']?.join('\n') ?? '',
      type: dndSpell['school']?['name'] ?? 'Spell',
      range: dndSpell['range'] ?? 'Self',
    );
  }

  static int _calculateCost(Map<String, dynamic> dndSpell) {
    // Get the spell level from the D&D spell data
    final level = dndSpell['level'] ?? 0;
    
    // Convert D&D spell level to our cost system:
    // Cost equals level (0 for cantrips, 1 for 1st level, 2 for 2nd level, etc.)
    return level;
  }

  int _calculateSpellCost(int level) {
    // Cost equals level (0 for cantrips, 1 for 1st level, 2 for 2nd level, etc.)
    return level;
  }

  String _convertDamageDice(String damageDice) {
    // Parse the damage dice string (e.g., "2d8")
    final parts = damageDice.split('d');
    if (parts.length != 2) return '';
    
    final count = int.tryParse(parts[0]) ?? 0;
    final size = int.tryParse(parts[1]) ?? 0;
    
    if (count == 0 || size == 0) return '';
    
    // Convert to d6 system
    final convertedCount = ((count * size) / 6).floor();
    return '${convertedCount}d6';
  }

  String _createEffectDescription(DndSpell dndSpell) {
    final effectParts = <String>[];
    
    // Add school and level
    effectParts.add('${dndSpell.school} spell');
    
    // Add casting time
    effectParts.add('Casting Time: ${dndSpell.castingTime}');
    
    // Add range
    effectParts.add('Range: ${dndSpell.range}');
    
    // Add duration
    effectParts.add('Duration: ${dndSpell.duration}');
    
    // Add components
    if (dndSpell.components.isNotEmpty) {
      effectParts.add('Components: ${dndSpell.components.join(", ")}');
    }
    
    // Add concentration/ritual tags
    if (dndSpell.concentration) {
      effectParts.add('Concentration');
    }
    if (dndSpell.ritual) {
      effectParts.add('Ritual');
    }
    
    // Add description
    effectParts.add(dndSpell.description);
    
    return effectParts.join('\n\n');
  }
} 