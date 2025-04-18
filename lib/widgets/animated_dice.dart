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
  List<int> _displayValues = []; // Track current display values during animation
  bool _isRolling = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
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
          _displayValues = List.from(_results); // Set final values
        });
        widget.onRollComplete(_calculateTotal());
      }
    });

    // Update display values during animation
    _controller.addListener(() {
      const intervalValueChange = 0.20; // in percent of total animation
      if (_isRolling && _controller.value % intervalValueChange < 0.05) { // Update every 10% of animation
        setState(() {
          _displayValues = List.generate(widget.count, (_) => math.Random().nextInt(6) + 1);
        });
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
      _displayValues = List.generate(widget.count, (_) => math.Random().nextInt(6) + 1);
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
      constraints: const BoxConstraints(
        minHeight: 200,
        maxHeight: 250,
      ),
      child: Stack(
        children: [
          // Background overlay
          Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                              ..translate(25.0, 25.0)  // Move to center of the die
                              ..rotateX(_animation.value * math.pi * 2)
                              ..rotateY(_animation.value * math.pi * 2)
                              ..rotateZ(_animation.value * math.pi * 2)
                              ..translate(-25.0, -25.0),  // Move back to original position
                            child: _buildDie(_isRolling ? _displayValues[index] : _results[index]),
                          );
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  // Rolling text
                  Text(
                    _isRolling ? 'Rolling...' : '${_calculateTotal()}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontSize: _isRolling ? null : Theme.of(context).textTheme.titleLarge?.fontSize != null 
                        ? Theme.of(context).textTheme.titleLarge!.fontSize! * 2.5 
                        : 40,
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