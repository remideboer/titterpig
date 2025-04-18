import '../models/dnd_spell.dart';
import '../models/spell.dart';
import 'package:ttrpg_character_manager/models/die.dart';

class DndSpellConverter {
  static Spell convertToSpell(Map<String, dynamic> dndSpell) {
    // Parse spell text to find damage dice
    final String description = dndSpell['desc']?.join('\n') ?? '';
    final String higherLevel = dndSpell['higher_level']?.join('\n') ?? '';
    final String fullText = '$description\n$higherLevel';
    
    // Find all dice notations in the text (e.g., "1d8", "2d6", etc.)
    final dicePattern = RegExp(r'(\d+)d(\d+)');
    final matches = dicePattern.allMatches(fullText);
    
    // Convert all found dice to d6 system and take the highest
    Die? effectValue;
    String convertedText = fullText;
    
    for (final match in matches) {
      final count = int.parse(match.group(1)!);
      final sides = int.parse(match.group(2)!);
      final convertedDie = Die.fromDndDice(count, sides);
      
      // Keep the highest effect value
      if (effectValue == null || convertedDie.count > effectValue.count) {
        effectValue = convertedDie;
      }
      
      // Replace the original dice notation with the converted one (just the dice notation)
      convertedText = convertedText.replaceAll(
        match.group(0)!,
        '${convertedDie.count}d6',
      );
    }

    // Determine spell type based on description
    String type = 'Spell';
    if (convertedText.toLowerCase().contains('damage')) {
      type = 'Offensive';
    } else if (convertedText.toLowerCase().contains('heal') || 
               convertedText.toLowerCase().contains('restore')) {
      type = 'Support';
    } else if (convertedText.toLowerCase().contains('shield') || 
               convertedText.toLowerCase().contains('protect')) {
      type = 'Defensive';
    } else if (convertedText.toLowerCase().contains('teleport') || 
               convertedText.toLowerCase().contains('move')) {
      type = 'Utility';
    }

    // Determine range
    String range = dndSpell['range'] ?? 'Self';
    if (range.toLowerCase().contains('self')) {
      range = 'Self';
    } else if (range.toLowerCase().contains('touch')) {
      range = 'Touch';
    } else if (range.toLowerCase().contains('feet') || 
               range.toLowerCase().contains('ft')) {
      final rangeMatch = RegExp(r'(\d+)\s*(?:feet|ft)').firstMatch(range);
      if (rangeMatch != null) {
        range = '${rangeMatch.group(1)}ft';
      }
    }

    return Spell(
      name: dndSpell['name'] ?? 'Unknown Spell',
      description: convertedText,
      cost: _calculateCost(dndSpell),
      isDndSpell: true,
      effectValue: effectValue,
      effect: convertedText,
      type: type,
      range: range,
    );
  }

  static int _calculateCost(Map<String, dynamic> dndSpell) {
    final level = dndSpell['level'] ?? 0;
    return level;
  }

  int _calculateSpellCost(int level) {
    // Cost equals level (0 for cantrips, 1 for 1st level, 2 for 2nd level, etc.)
    return level;
  }

  static String _convertDamageDice(String damageDice) {
    // Parse the damage dice string (e.g., "2d8")
    final parts = damageDice.split('d');
    if (parts.length != 2) return '';
    
    final count = int.tryParse(parts[0]) ?? 0;
    final size = int.tryParse(parts[1]) ?? 0;
    
    if (count == 0 || size == 0) return '';
    
    // Calculate maximum possible damage
    final maxDamage = count * size;
    
    // Convert to d6 system by dividing max damage by 6 and rounding up
    final convertedCount = (maxDamage / 6).ceil();
    
    // Add damage value explanation
    return '${convertedCount}d6 (1-2=0, 3-5=1, 6=2)';
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