import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttrpg_character_manager/main.dart';
import 'package:ttrpg_character_manager/models/character.dart';
import 'package:ttrpg_character_manager/models/species.dart';
import 'package:ttrpg_character_manager/services/character_service.dart';

void main() {
  testWidgets('App starts and shows character list', (WidgetTester tester) async {
    // Initialize SharedPreferences
    SharedPreferences.setMockInitialValues({
      'sound_muted': false,
      'isDarkMode': false,
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(isDarkMode: false),
      ),
    );

    // Wait for all async operations to complete
    await tester.pumpAndSettle();

    // Verify we're on the character list screen
    expect(find.text('Select a character from the list'), findsOneWidget);
  });

  group('Character Model Tests', () {
    test('Character creation with minimum valid stats', () {
      // Find minimum valid VIT that keeps HP >= 2
      var minValidVit = -3;
      while (!CharacterService.isValidVitForHp(minValidVit)) {
        minValidVit++;
      }

      final character = Character(
        id: '1',
        name: 'Test Character',
        species: const Species(name: 'Human', icon: 'human-face.svg'),
        vit: minValidVit,
        ath: -3,
        wil: -3,
        createdAt: DateTime.now(),
        lastUsed: DateTime.now(),
      );

      expect(character.name, 'Test Character');
      expect(character.vit, minValidVit);
      expect(character.ath, -3);
      expect(character.wil, -3);
      expect(character.hpStat.max, 2); // Minimum valid HP
      expect(character.lifeStat.max, Character.baseLife + minValidVit);
      expect(character.powerStat.max, -9); // -3 × 3 = -9
    });

    test('Character creation with maximum stats', () {
      final character = Character(
        id: '1',
        name: 'Test Character',
        species: const Species(name: 'Human', icon: 'human-face.svg'),
        vit: 3,
        ath: 3,
        wil: 3,
        createdAt: DateTime.now(),
        lastUsed: DateTime.now(),
      );

      expect(character.name, 'Test Character');
      expect(character.vit, 3);
      expect(character.ath, 3);
      expect(character.wil, 3);
      expect(character.hpStat.max, 12); // 6 + (2 × 3) = 12
      expect(character.lifeStat.max, 6); // 3 + 3 = 6
      expect(character.powerStat.max, 9); // 3 × 3 = 9
    });

    test('VIT validation ensures HP stays at or above 2', () {
      // Test that we can't create a character with HP < 2
      for (var vit = -3; vit <= 3; vit++) {
        final hp = CharacterService.calculateHp(vit);
        final isValid = CharacterService.isValidVitForHp(vit);
        expect(isValid, hp >= 2, 
          reason: 'VIT $vit gives HP $hp, should be ${hp >= 2 ? 'valid' : 'invalid'}');
      }
    });
  });
} 