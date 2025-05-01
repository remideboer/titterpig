import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/sound_manager.dart';
import 'animated_dice.dart';
import '../models/character.dart';

final soundManagerProvider = Provider<SoundManager>((ref) => SoundManager());

class VitalityCheckOverlay extends ConsumerStatefulWidget {
  final Character character;
  final int targetNumber;
  final Function(bool) onResult;

  const VitalityCheckOverlay({
    super.key,
    required this.character,
    required this.targetNumber,
    required this.onResult,
  });

  @override
  ConsumerState<VitalityCheckOverlay> createState() => _VitalityCheckOverlayState();
}

class _VitalityCheckOverlayState extends ConsumerState<VitalityCheckOverlay> {
  bool _isRolling = false;
  int? _rollResult;
  bool? _isSuccess;
  late int _diceCount;

  @override
  void initState() {
    super.initState();
    // Get the dice count from the character's check method
    final (diceCount, _, _) = widget.character.check('VIT', widget.targetNumber);
    _diceCount = diceCount;
  }

  void _rollCheck() {
    setState(() {
      _isRolling = true;
    });

    // Play roll sound
    final soundManager = ref.read(soundManagerProvider);
    soundManager.playRollSound();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Vitality Check',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Target Number: ${widget.targetNumber}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            if (!_isRolling && _rollResult == null)
              ElevatedButton(
                onPressed: _rollCheck,
                child: const Text('Roll Check'),
              ),
            if (_isRolling || _rollResult != null)
              AnimatedDice(
                count: _diceCount,
                onRollComplete: (result) {
                  setState(() {
                    _isRolling = false;
                    _rollResult = result;
                    _isSuccess = result >= widget.targetNumber;
                  });
                  widget.onResult(_isSuccess!);
                },
              ),
            if (_rollResult != null) ...[
              const SizedBox(height: 16),
              Text(
                'Rolled: $_rollResult',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isSuccess! ? 'Success!' : 'Failure!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: _isSuccess! ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 