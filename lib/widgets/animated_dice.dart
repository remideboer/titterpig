import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class AnimatedDice extends StatefulWidget {
  final int count;
  final Function(int) onRollComplete;

  const AnimatedDice({
    super.key,
    required this.count,
    required this.onRollComplete,
  });

  @override
  State<AnimatedDice> createState() => _AnimatedDiceState();
}

class _AnimatedDiceState extends State<AnimatedDice> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  List<int> _results = [];
  bool _isRolling = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isRolling = false;
        });
        widget.onRollComplete(_calculateTotal());
      }
    });

    // Start rolling automatically when widget is created
    roll();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void roll() {
    setState(() {
      _isRolling = true;
      _results = List.generate(widget.count, (_) => math.Random().nextInt(6) + 1);
    });
    _controller.forward(from: 0);
  }

  int _calculateTotal() {
    return _results.fold(0, (sum, roll) {
      // 1-2 = 0, 3-5 = 1, 6 = 2
      return sum + (roll <= 2 ? 0 : (roll <= 5 ? 1 : 2));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 200,
      child: Stack(
        children: [
          // Background overlay
          Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Dice display
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(widget.count, (index) {
                      return AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateX(_animation.value * math.pi * 2)
                              ..rotateY(_animation.value * math.pi * 2)
                              ..translate(0.0, math.sin(_animation.value * math.pi * 2) * 20.0),
                            child: _buildDie(_results[index]),
                          );
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  // Rolling text
                  Text(
                    _isRolling ? 'Rolling...' : 'Result: ${_calculateTotal()}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDie(int value) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Center(
        child: _buildDieFace(value),
      ),
    );
  }

  Widget _buildDieFace(int value) {
    switch (value) {
      case 1:
      case 2:
        return const SizedBox(); // Empty face
      case 3:
      case 4:
      case 5:
        return Icon(
          Icons.star,
          color: AppTheme.primaryColor,
          size: 20,
        );
      case 6:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star,
              color: AppTheme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.star,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }
} 