import 'package:flutter_test/flutter_test.dart';
import 'package:ttrpg_character_manager/models/background.dart';

void main() {
  group('Background Model Tests', () {
    test('Background creation and modification', () {
      final background = Background(
        id: '1',
        name: 'Noble',
        description: 'A noble background',
        placeOfBirth: 'Castle',
        parents: 'Noble parents',
        siblings: 'Two siblings',
      );

      expect(background.name, 'Noble');
      expect(background.description, 'A noble background');
      expect(background.placeOfBirth, 'Castle');
      expect(background.parents, 'Noble parents');
      expect(background.siblings, 'Two siblings');
    });

    test('Background copyWith functionality', () {
      final background = Background(
        id: '1',
        name: 'Noble',
        description: 'A noble background',
        placeOfBirth: 'Castle',
        parents: 'Noble parents',
        siblings: 'Two siblings',
      );

      final modifiedBackground = background.copyWith(
        description: 'A modified noble background',
        placeOfBirth: 'Palace',
      );

      expect(modifiedBackground.id, background.id);
      expect(modifiedBackground.name, background.name);
      expect(modifiedBackground.description, 'A modified noble background');
      expect(modifiedBackground.placeOfBirth, 'Palace');
      expect(modifiedBackground.parents, background.parents);
      expect(modifiedBackground.siblings, background.siblings);
    });
  });
} 