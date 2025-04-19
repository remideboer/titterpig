import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ttrpg_character_manager/main.dart';
import 'package:ttrpg_character_manager/models/character.dart';
import 'package:ttrpg_character_manager/models/species.dart';

void main() {
  testWidgets('App starts and shows character list', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(isDarkMode: false),
      ),
    );

    // Verify the app starts and shows the character list screen
    expect(find.byType(Scaffold), findsOneWidget);
  });

  group('Character Model Tests', () {
    test('Character creation with minimum stats', () {
      final character = Character(
        id: '1',
        name: 'Test Character',
        species: const Species(name: 'Human', icon: 'human-face.svg'),
        vit: -3,
        ath: -3,
        wil: -3,
        createdAt: DateTime.now(),
        lastUsed: DateTime.now(),
      );

      expect(character.name, 'Test Character');
      expect(character.vit, -3);
      expect(character.ath, -3);
      expect(character.wil, -3);
      expect(character.hpStat.max, 0); // 6 + (2 × -3)
      expect(character.lifeStat.max, 0); // 3 + (-3)
      expect(character.powerStat.max, 0); // -3 × 3
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
      expect(character.hpStat.max, 12); // 6 + (2 × 3)
      expect(character.lifeStat.max, 6); // 3 + 3
      expect(character.powerStat.max, 9); // 3 × 3
    });
  });
} 