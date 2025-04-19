import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ttrpg_character_manager/models/character.dart';
import 'package:ttrpg_character_manager/services/character_service.dart';
import 'package:ttrpg_character_manager/models/species.dart';

/// Service for generating random characters following BR-15
class CharacterGeneratorService {
  final CharacterService _characterService;
  final Random _random = Random();

  CharacterGeneratorService(this._characterService);

  /// Generates a random character following BR-15 rules
  Character generateRandomCharacter() {
    final species = _generateRandomSpecies();
    final name = _generateRandomName(species);
    final stats = _generateValidStats();

    return Character(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      species: species,
      vit: stats['vit']!,
      ath: stats['ath']!,
      wil: stats['wil']!,
      createdAt: DateTime.now(),
      lastUsed: DateTime.now(),
    );
  }

  /// Generates random stats following the rules:
  /// - Total points: 3
  /// - Each stat between -3 and 3
  /// - VIT must result in HP >= 2 and Life >= 1
  Map<String, int> _generateValidStats() {
    while (true) {
      final stats = _generateRandomStats();
      final vit = stats['vit']!;
      
      // Verify both HP and Life rules (BR-08, BR-13)
      if (CharacterService.isValidVitForHp(vit) && 
          CharacterService.isValidVitForLife(vit)) {
        return stats;
      }
    }
  }

  Map<String, int> _generateRandomStats() {
    // Initialize with minimum valid VIT (-2) and minimum values for others
    var remainingPoints = CharacterService.totalPoints;
    var stats = {
      'vit': -2,  // Start at -2 to ensure valid HP and Life
      'ath': CharacterService.minStat, 
      'wil': CharacterService.minStat
    };
    
    // Randomly distribute points
    while (remainingPoints > 0) {
      final stat = ['vit', 'ath', 'wil'][_random.nextInt(3)];
      if (stats[stat]! < CharacterService.maxStat) {  // Max value check
        stats[stat] = stats[stat]! + 1;
        remainingPoints--;
      }
    }
    
    return stats;
  }

  /// Generates a random species from available species list
  Species _generateRandomSpecies() {
    const availableSpecies = [
      Species(name: 'Human', icon: 'human-face.svg'),
      Species(name: 'Elf', icon: 'elf-face.svg'),
      Species(name: 'Dwarf', icon: 'dwarf-face.svg'),
      Species(name: 'Orc', icon: 'orc-face.svg'),
    ];

    return availableSpecies[_random.nextInt(availableSpecies.length)];
  }

  /// Generates a random name based on species
  String _generateRandomName(Species species) {
    // Species-specific name components
    final nameComponents = {
      'Human': {
        'prefixes': ['Al', 'Ber', 'Car', 'Don', 'Ed'],
        'suffixes': ['ric', 'win', 'mund', 'ard', 'ward'],
      },
      'Elf': {
        'prefixes': ['Ae', 'Cae', 'Tha', 'Ael', 'Gal'],
        'suffixes': ['rith', 'lis', 'dril', 'wen', 'nor'],
      },
      'Dwarf': {
        'prefixes': ['Thor', 'Dur', 'Bal', 'Gim', 'Bom'],
        'suffixes': ['in', 'li', 'dur', 'bur', 'fur'],
      },
      'Orc': {
        'prefixes': ['Gru', 'Mog', 'Gor', 'Dur', 'Zug'],
        'suffixes': ['mak', 'nak', 'tuk', 'gul', 'lak'],
      },
    };

    final components = nameComponents[species.name]!;
    final prefix = components['prefixes']![_random.nextInt(components['prefixes']!.length)];
    final suffix = components['suffixes']![_random.nextInt(components['suffixes']!.length)];

    return '$prefix$suffix';
  }
} 