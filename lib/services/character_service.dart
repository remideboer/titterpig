import '../models/character.dart';
import '../models/def_category.dart';

class CharacterService {
  static const int totalPoints = 3;
  static const int maxStat = 3;
  static const int minStat = -3;

  static bool isValidStatValue(int value) {
    return value >= minStat && value <= maxStat;
  }

  static bool isValidVitForHp(int vit) {
    final hp = calculateHp(vit);
    return hp >= 2;
  }

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