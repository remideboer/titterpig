import 'dart:math';

class Die {
  final int count;
  static const int sides = 6;

  Die(this.count);

  int roll() {
    int total = 0;
    for (int i = 0; i < count; i++) {
      final roll = Random().nextInt(sides) + 1;
      // Calculate effect based on roll:
      // 1-2 = 0 effect
      // 3-5 = 1 effect
      // 6 = 2 effect
      total += roll <= 2 ? 0 : (roll <= 5 ? 1 : 2);
    }
    return total;
  }

  @override
  String toString() {
    return '${count}d$sides';
  }

  static Die fromDndDice(int count, int sides) {
    if (count == 0 || sides == 0) return Die(0);
    
    // Calculate maximum possible damage
    final maxDamage = count * sides;
    
    // Convert to d6 system by dividing max damage by 6 and rounding up
    final convertedCount = (maxDamage / 6).ceil();
    
    return Die(convertedCount);
  }
} 