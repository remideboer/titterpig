import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/character.dart';
import 'hexagon_shape.dart';
import 'animated_dice.dart';
import 'dart:math';

final checkStateProvider = StateProvider<bool>((ref) => true); // Always show options

enum CheckDifficulty {
  easy(1),
  normal(3),
  hard(5);

  final int targetNumber;
  const CheckDifficulty(this.targetNumber);
}

class CheckWidget extends ConsumerWidget {
  final Character character;
  final int statValue;
  final String statType;

  const CheckWidget({
    super.key,
    required this.character,
    required this.statValue,
    required this.statType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Choose Difficulty',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: CheckDifficulty.values.map((difficulty) {
              return _DifficultyButton(
                difficulty: difficulty,
                statValue: statValue,
                character: character,
                statType: statType,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _DifficultyButton extends StatefulWidget {
  final CheckDifficulty difficulty;
  final int statValue;
  final Character character;
  final String statType;

  const _DifficultyButton({
    required this.difficulty,
    required this.statValue,
    required this.character,
    required this.statType,
  });

  @override
  State<_DifficultyButton> createState() => _DifficultyButtonState();
}

class _DifficultyButtonState extends State<_DifficultyButton> {
  bool _showResult = false;
  int? _rollResult;
  bool? _isSuccess;

  int _getStatValue(Character character) {
    switch (widget.statType) {
      case 'VIT':
        return character.vit;
      case 'ATH':
        return character.ath;
      case 'WIL':
        return character.wil;
      default:
        return 0;
    }
  }

  void _rollCheck(Character character, CheckDifficulty difficulty) {
    final statValue = _getStatValue(character);
    // Calculate dice count: 3 base + stat value, minimum 1
    final diceCount = math.max(1, 3 + statValue);
    final targetNumber = difficulty.targetNumber;

    // Show the dice roll animation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: AnimatedDice(
          count: diceCount,
          onRollComplete: (total) {
            // Close the dice dialog
            Navigator.of(context).pop();
            
            // Show the result
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Check Result'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Rolled: $total Target: $targetNumber'),
                    const SizedBox(height: 8),
                    Text(
                      total >= targetNumber ? 'Success!' : 'Failure!',
                      style: TextStyle(
                        color: total >= targetNumber ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      // Close the result dialog
                      Navigator.of(context).pop();
                      // Close the check display
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.difficulty.name.toUpperCase(),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => _rollCheck(widget.character, widget.difficulty),
          child: HexagonContainer(
            size: 40,
            borderColor: Theme.of(context).primaryColor,
            fillColor: Colors.transparent,
            child: Center(
              child: Text(
                widget.difficulty.targetNumber.toString(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ),
        if (_showResult)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              children: [
                Text(
                  'Roll: $_rollResult',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  _isSuccess! ? 'Success!' : 'Fail!',
                  style: TextStyle(
                    color: _isSuccess! ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
} 