import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ttrpg_character_manager/services/character_service.dart';
import 'package:ttrpg_character_manager/services/character_generator_service.dart';

class MockCharacterService extends Mock implements CharacterService {
  @override
  bool isValidVitForHp(int vit) {
    final hp = 6 + (2 * vit);
    return hp >= 2;
  }
}

void main() {
  late CharacterGeneratorService generator;
  late MockCharacterService mockCharacterService;

  setUp(() {
    mockCharacterService = MockCharacterService();
    generator = CharacterGeneratorService(mockCharacterService);
  });

  group('CharacterGeneratorService', () {
    test('generates valid random character', () {
      final character = generator.generateRandomCharacter();

      // Verify character has all required fields
      expect(character.id, isNotEmpty);
      expect(character.name, isNotEmpty);
      expect(character.species, isNotNull);
      expect(character.createdAt, isNotNull);
      expect(character.lastUsed, isNotNull);

      // Verify stats follow rules
      expect(character.vit, inInclusiveRange(-3, 3));
      expect(character.ath, inInclusiveRange(-3, 3));
      expect(character.wil, inInclusiveRange(-3, 3));

      // Verify total stat points is 3
      final totalPoints = character.vit + character.ath + character.wil + 9; // Add 9 to offset -3 base
      expect(totalPoints, equals(12)); // 3 points distributed from -3 base (3 + 9 = 12)

      // Verify HP rule is followed
      final hp = 6 + (2 * character.vit);
      expect(hp, greaterThanOrEqualTo(2));
    });

    test('generates appropriate names for each species', () {
      // Generate multiple characters and verify names match species patterns
      for (var i = 0; i < 50; i++) {
        final character = generator.generateRandomCharacter();
        final name = character.name;
        final species = character.species.name;

        switch (species) {
          case 'Human':
            expect(name, matches(r'^[A-Z][a-z]+[a-z]+$'));
            break;
          case 'Elf':
            expect(name, matches(r'^[A-Z][a-z]+[a-z]+$'));
            break;
          case 'Dwarf':
            expect(name, matches(r'^[A-Z][a-z]+[a-z]+$'));
            break;
          case 'Orc':
            expect(name, matches(r'^[A-Z][a-z]+[a-z]+$'));
            break;
          default:
            fail('Unknown species: $species');
        }
      }
    });

    test('generates valid stats distribution', () {
      // Test multiple generations to ensure consistent validity
      for (var i = 0; i < 50; i++) {
        final character = generator.generateRandomCharacter();
        
        // Verify stat ranges
        expect(character.vit, inInclusiveRange(-3, 3));
        expect(character.ath, inInclusiveRange(-3, 3));
        expect(character.wil, inInclusiveRange(-3, 3));

        // Verify total points
        final totalPoints = character.vit + character.ath + character.wil + 9;
        expect(totalPoints, equals(12));

        // Verify HP rule
        final hp = 6 + (2 * character.vit);
        expect(hp, greaterThanOrEqualTo(2));
      }
    });
  });
} 