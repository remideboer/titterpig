import '../models/character.dart';
import '../models/def_category.dart';

/// Service class for managing character-related calculations and validations.
class CharacterService {
  static const int totalPoints = 3;
  static const int minStat = -3;
  static const int maxStat = 3;  // Maximum value for any base stat
  static const int minLife = 1;  // Minimum allowed LIFE value

  /// Validates if a VIT value would result in valid HP (>= 2).
  /// 
  /// According to BR-13, a character's HP must always be 2 or greater.
  /// HP is calculated as 6 + (2 × VIT), so this method ensures the
  /// calculation results in HP >= 2.
  /// 
  /// Example:
  /// - VIT -2 gives HP 2: 6 + (2 × -2) = 2 (valid)
  /// - VIT -3 gives HP 0: 6 + (2 × -3) = 0 (invalid)
  static bool isValidVitForHp(int vit) {
    final hp = calculateHp(vit);
    return hp >= 2;
  }

  /// Validates if a VIT value would result in valid LIFE (>= 1).
  /// LIFE is calculated as 3 + VIT, so VIT must be >= -2.
  static bool isValidVitForLife(int vit) {
    final life = calculateLife(vit);
    return life >= minLife;
  }

  /// Calculates HP based on VIT.
  /// 
  /// HP = baseHp + (hpPerVit × VIT)
  /// where baseHp = 6 and hpPerVit = 2
  static int calculateHp(int vit) {
    return Character.baseHp + Character.hpPerVit * vit;
  }

  static int calculateLife(int vit) {
    return Character.baseLife + vit;
  }

  static int calculatePower(int wil) {
    return wil * 3;
  }

  static int calculateDef(DefCategory defCategory, bool hasShield) {
    return defCategory.defValue + (hasShield ? 2 : 0);
  }

  static int calculateDefense(int ath, DefCategory defCategory) {
    return ath + defCategory.defValue;
  }

  /// Validates if a stat can be updated with the given delta.
  /// 
  /// Priority of constraints:
  /// 1. VIT must result in HP >= 2 (highest priority)
  /// 2. VIT must result in LIFE >= 1
  /// 3. General minimum stat value of -3 (lowest priority)
  static bool canUpdateStat({
    required int currentValue,
    required int delta,
    required int remainingPoints,
    bool isVit = false,
  }) {
    final newValue = currentValue + delta;
    final newRemaining = remainingPoints - delta;
    
    // Check if we have enough points
    if (newRemaining < 0) return false;
    
    // For VIT, check HP and LIFE requirements first
    if (isVit) {
      if (!isValidVitForHp(newValue)) return false;
      if (!isValidVitForLife(newValue)) return false;
      return true;  // If HP and LIFE are valid, allow any value
    }
    
    // For other stats, check the minimum value
    return newValue >= minStat;
  }
} 