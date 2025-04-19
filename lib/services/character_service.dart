import '../models/character.dart';
import '../models/def_category.dart';

/// Service class for managing character-related calculations and validations.
class CharacterService {
  static const int totalPoints = 3;
  static const int maxStat = 3;
  static const int minStat = -3;

  /// Validates if a stat value is within the allowed range.
  static bool isValidStatValue(int value) {
    return value >= minStat && value <= maxStat;
  }

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
  /// For VIT specifically, this ensures that the resulting HP stays >= 2
  /// as per BR-13.
  static bool canUpdateStat({
    required int currentValue,
    required int delta,
    required int remainingPoints,
    bool isVit = false,
  }) {
    final newValue = currentValue + delta;
    
    if (!isValidStatValue(newValue)) return false;
    if (isVit && !isValidVitForHp(newValue)) return false;
    
    final newRemaining = remainingPoints - delta;
    return newRemaining >= 0;
  }
} 