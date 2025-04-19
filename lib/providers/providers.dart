import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/character_service.dart';
import '../services/character_generator_service.dart';
import '../services/spell_service.dart';

/// Provider for the character service
final characterServiceProvider = Provider<CharacterService>(
  (ref) => CharacterService(),
);

/// Provider for the character generator service
final characterGeneratorProvider = Provider<CharacterGeneratorService>(
  (ref) => CharacterGeneratorService(CharacterService()),
);

/// Provider for the spell service
final spellServiceProvider = Provider<SpellService>(
  (ref) => SpellService(),
); 