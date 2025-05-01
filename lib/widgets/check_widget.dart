import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/character.dart';
import 'hexagon_shape.dart';
import 'animated_dice.dart';
import 'dart:math';
import '../utils/sound_manager.dart';

final checkStateProvider = StateProvider<bool>((ref) => true); // Always show options
final soundManagerProvider = Provider<SoundManager>((ref) => SoundManager());

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
                ref: ref,
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

class _RollResult extends StatelessWidget {
  final int total;
  final int targetNumber;

  const _RollResult({
    required this.total,
    required this.targetNumber,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = total >= targetNumber;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Rolled: $total Target: $targetNumber',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.cancel,
                color: isSuccess ? Colors.green : Colors.red,
                size: 32,
              ),
              const SizedBox(width: 8),
              Text(
                isSuccess ? 'Success!' : 'Failure!',
                style: TextStyle(
                  color: isSuccess ? Colors.green : Colors.red,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
  final WidgetRef ref;

  const _DifficultyButton({
    required this.difficulty,
    required this.statValue,
    required this.character,
    required this.statType,
    required this.ref,
  });

  @override
  State<_DifficultyButton> createState() => _DifficultyButtonState();
}

class _DifficultyButtonState extends State<_DifficultyButton> {
  bool _showResult = false;
  int? _rollResult;
  bool? _isSuccess;

  int _getStatValue(Character character) {
    // Use the stat that initiated the check flow
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

    // Play roll sound
    final soundManager = widget.ref.read(soundManagerProvider);
    soundManager.playRollSound();

    // Show the dice roll animation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedDice(
                  count: diceCount,
                  onRollComplete: (total) {
                    setState(() {
                      _rollResult = total;
                      _isSuccess = total >= targetNumber;
                    });
                  },
                ),
                if (_rollResult != null) ...[
                  const SizedBox(height: 16),
                  _RollResult(
                    total: _rollResult!,
                    targetNumber: targetNumber,
                  ),
                ],
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // Close the dice dialog and check display
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
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
      ],
    );
  }
} 