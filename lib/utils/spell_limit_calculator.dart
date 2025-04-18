/// Utility class to calculate spell limits based on WIL stat
class SpellLimitCalculator {
  /// Returns the maximum number of spells a character can have based on their WIL stat.
  /// Uses Fibonacci sequence starting at WIL=1 (2 spells), WIL=2 (3 spells), WIL=3 (5 spells), etc.
  static int calculateSpellLimit(int wil) {
    if (wil <= 0) return 0;
    
    // Calculate the (wil+1)th Fibonacci number starting from 2,3
    int prev = 2; // First number (for WIL=1)
    int current = 3; // Second number (for WIL=2)
    
    if (wil == 1) return prev;
    if (wil == 2) return current;
    
    // Calculate next Fibonacci numbers until we reach the desired position
    for (int i = 3; i <= wil; i++) {
      final next = prev + current;
      prev = current;
      current = next;
    }
    
    return current;
  }
} 