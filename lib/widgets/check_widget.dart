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

  const CheckWidget({
    super.key,
    required this.character,
    required this.statValue,
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

  const _DifficultyButton({
    required this.difficulty,
    required this.statValue,
  });

  @override
  State<_DifficultyButton> createState() => _DifficultyButtonState();
}

class _DifficultyButtonState extends State<_DifficultyButton> {
  bool _showResult = false;
  int? _rollResult;
  bool? _isSuccess;

  void _rollCheck() {
    // Roll 3 base dice plus stat value number of dice
    final diceRolls = List.generate(3 + widget.statValue, (_) => Random().nextInt(6) + 1);
    final total = diceRolls.reduce((a, b) => a + b);
    
    setState(() {
      _rollResult = total;
      _isSuccess = total >= widget.difficulty.targetNumber;
      _showResult = true;
    });
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
          onTap: _rollCheck,
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