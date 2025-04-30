import 'package:shared_preferences/shared_preferences.dart';
import '../../models/character.dart';
import '../../models/spell.dart';
import '../../models/stat_value.dart';
import '../../models/species.dart';
import '../../models/background.dart';
import '../../models/def_category.dart';

class CharacterMapper {
  static const int currentSaveVersion = 2;

  static Map<String, dynamic> toJson(Character character) {
    return {
      'version': currentSaveVersion,
      'id': character.id,
      'name': character.name,
      'species': character.species.toJson(),
      'vit': character.vit,
      'ath': character.ath,
      'wil': character.wil,
      'avatarPath': character.avatarPath,
      'tempHp': character.tempHp,
      'tempHpToLife': character.tempHpToLife,
      'hp': character.hpStat.max,
      'currentLife': character.lifeStat.current,
      'maxLife': character.lifeStat.max,
      'power': character.powerStat.max,
      'availablePower': character.powerStat.current,
      'def': character.def,
      'defCategory': character.defCategory.index,
      'hasShield': character.hasShield,
      'spells': character.spells.map((s) => s.toJson()).toList(),
      'sessionLog': character.sessionLog,
      'notes': character.notes,
      'xp': character.xp,
      'createdAt': character.createdAt.toIso8601String(),
      'lastUsed': character.lastUsed.toIso8601String(),
      'background': character.background?.toJson(),
    };
  }

  static Character fromJson(Map<String, dynamic> json) {
    // Check save version
    final saveVersion = json['version'] as int? ?? 1;
    if (saveVersion > currentSaveVersion) {
      throw FormatException(
        'This character was saved with a newer version of the app (v$saveVersion). '
        'Please update the app to load this character.'
      );
    }

    // Helper function to safely convert to int
    int safeToInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is num) return value.toInt();
      return 0;
    }

    // Helper function to safely convert to DateTime
    DateTime safeToDateTime(dynamic value) {
      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    // Helper function to safely convert spells
    List<Ability> safeToSpells(dynamic value) {
      if (value is List) {
        return value.map((s) => Ability.fromJson(s)).toList();
      }
      return [];
    }

    // Handle both string and Map species formats
    Species species;
    if (json['species'] is String) {
      species = Species(
        name: json['species'] as String,
        icon: '${json['species'].toString().toLowerCase()}-face.svg',
      );
    } else {
      species = Species.fromJson(json['species'] as Map<String, dynamic>);
    }

    final character = Character(
      id: json['id'] as String,
      name: json['name'] as String,
      species: species,
      vit: safeToInt(json['vit']),
      ath: safeToInt(json['ath']),
      wil: safeToInt(json['wil']),
      avatarPath: json['avatarPath'] as String?,
      tempHp: safeToInt(json['tempHp']),
      tempHpToLife: safeToInt(json['tempHpToLife']),
      defCategory: DefCategory.values[safeToInt(json['defCategory'])],
      hasShield: json['hasShield'] as bool? ?? false,
      spells: safeToSpells(json['spells']),
      sessionLog: List<String>.from(json['sessionLog'] ?? []),
      notes: json['notes'] as String? ?? '',
      xp: safeToInt(json['xp']),
      createdAt: safeToDateTime(json['createdAt']),
      lastUsed: safeToDateTime(json['lastUsed']),
      background: json['background'] != null 
          ? Background.fromJson(json['background'] as Map<String, dynamic>)
          : null,
    );
    
    // Initialize stat values from JSON
    character.lifeStat = StatValue(
      current: safeToInt(json['currentLife'] ?? json['life'] ?? (Character.baseLife + safeToInt(json['vit']))),
      max: safeToInt(json['maxLife'] ?? json['life'] ?? (Character.baseLife + safeToInt(json['vit'])))
    );
    
    character.powerStat = StatValue(
      current: safeToInt(json['availablePower'] ?? json['power']),
      max: safeToInt(json['power'])
    );
    
    return character;
  }
} 