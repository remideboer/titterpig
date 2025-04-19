import 'package:flutter_test/flutter_test.dart';
import 'package:ttrpg_character_manager/models/background.dart';

void main() {
  group('Background', () {
    test('creates custom background correctly', () {
      final background = Background.custom(
        name: 'Custom Background',
        description: 'A custom background description',
        placeOfBirth: 'Custom Birthplace',
        parents: 'Custom Parents',
        siblings: 'Custom Siblings',
      );

      expect(background.id, isNotEmpty);
      expect(background.name, 'Custom Background');
      expect(background.description, 'A custom background description');
      expect(background.placeOfBirth, 'Custom Birthplace');
      expect(background.parents, 'Custom Parents');
      expect(background.siblings, 'Custom Siblings');
      expect(background.templateId, isNull);
      expect(background.isCustomized, isFalse);
    });

    test('creates background from template correctly', () {
      final template = Background(
        id: 'noble',
        name: 'Noble',
        description: 'Noble background description',
        placeOfBirth: 'Noble Manor',
        parents: 'Noble Parents',
        siblings: 'Noble Siblings',
        isCustomized: false,
      );

      final background = Background.fromTemplate(template: template);

      expect(background.id, isNot(template.id));
      expect(background.name, template.name);
      expect(background.description, template.description);
      expect(background.placeOfBirth, template.placeOfBirth);
      expect(background.parents, template.parents);
      expect(background.siblings, template.siblings);
      expect(background.templateId, isNull);
      expect(background.isCustomized, isFalse);
    });

    test('customizes template background correctly', () {
      final template = Background(
        id: 'merchant',
        name: 'Merchant',
        description: 'Merchant background description',
        placeOfBirth: 'Trade City',
        parents: 'Merchant Parents',
        siblings: 'Merchant Siblings',
        isCustomized: false,
      );

      final customized = Background.fromTemplate(
        template: template,
        customize: true,
      );

      expect(customized.id, isNot(template.id));
      expect(customized.name, template.name);
      expect(customized.description, template.description);
      expect(customized.placeOfBirth, template.placeOfBirth);
      expect(customized.parents, template.parents);
      expect(customized.siblings, template.siblings);
      expect(customized.templateId, template.id);
      expect(customized.isCustomized, isTrue);
    });

    test('converts background to customized version', () {
      final original = Background(
        id: 'test',
        name: 'Test Background',
        description: 'Test Description',
        placeOfBirth: 'Test Place',
        parents: 'Test Parents',
        siblings: 'Test Siblings',
        isCustomized: false,
      );

      final customized = original.toCustomized();

      expect(customized.id, isNot(original.id));
      expect(customized.name, original.name);
      expect(customized.description, original.description);
      expect(customized.placeOfBirth, original.placeOfBirth);
      expect(customized.parents, original.parents);
      expect(customized.siblings, original.siblings);
      expect(customized.templateId, original.id);
      expect(customized.isCustomized, isTrue);

      // Calling toCustomized on an already customized background should return the same instance
      expect(customized.toCustomized(), equals(customized));
    });

    test('copyWith creates new instance with updated values', () {
      final background = Background(
        id: 'test',
        name: 'Original Name',
        description: 'Original Description',
        placeOfBirth: 'Original Place',
        parents: 'Original Parents',
        siblings: 'Original Siblings',
        templateId: 'template',
        isCustomized: true,
      );

      final updated = background.copyWith(
        name: 'New Name',
        description: 'New Description',
      );

      expect(updated.id, background.id);
      expect(updated.name, 'New Name');
      expect(updated.description, 'New Description');
      expect(updated.placeOfBirth, background.placeOfBirth);
      expect(updated.parents, background.parents);
      expect(updated.siblings, background.siblings);
      expect(updated.templateId, background.templateId);
      expect(updated.isCustomized, background.isCustomized);

      // Verify original is unchanged
      expect(background.name, 'Original Name');
      expect(background.description, 'Original Description');
    });

    test('serializes and deserializes correctly', () {
      final background = Background(
        id: 'test',
        name: 'Test Background',
        description: 'Test Description',
        placeOfBirth: 'Test Place',
        parents: 'Test Parents',
        siblings: 'Test Siblings',
        templateId: 'template',
        isCustomized: true,
      );

      final json = background.toJson();
      final deserialized = Background.fromJson(json);

      expect(deserialized.id, background.id);
      expect(deserialized.name, background.name);
      expect(deserialized.description, background.description);
      expect(deserialized.placeOfBirth, background.placeOfBirth);
      expect(deserialized.parents, background.parents);
      expect(deserialized.siblings, background.siblings);
      expect(deserialized.templateId, background.templateId);
      expect(deserialized.isCustomized, background.isCustomized);
    });

    test('creates empty background correctly', () {
      final background = Background.empty();

      expect(background.id, isEmpty);
      expect(background.name, isEmpty);
      expect(background.description, isEmpty);
      expect(background.placeOfBirth, isEmpty);
      expect(background.parents, isEmpty);
      expect(background.siblings, isEmpty);
      expect(background.templateId, isNull);
      expect(background.isCustomized, isFalse);
    });
  });
} 