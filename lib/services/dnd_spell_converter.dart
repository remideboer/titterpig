import '../models/dnd_spell.dart';
import '../models/spell.dart';

class DndSpellConverter {
  Spell convertToSpell(DndSpell dndSpell) {
    // Calculate spell cost based on level
    int cost = _calculateSpellCost(dndSpell.level);
    
    // Convert damage dice if present
    String convertedDamage = '';
    if (dndSpell.damage.isNotEmpty) {
      convertedDamage = _convertDamageDice(dndSpell.damage);
    }

    // Create effect description
    String effect = _createEffectDescription(dndSpell);

    return Spell(
      name: dndSpell.name,
      cost: cost,
      damage: convertedDamage,
      effect: effect,
    );
  }

  int _calculateSpellCost(int level) {
    // Base cost is 1 for cantrips, 2 for 1st level, etc.
    return level + 1;
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