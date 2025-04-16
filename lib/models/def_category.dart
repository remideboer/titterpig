enum DefCategory {
  none,
  light,
  medium,
  heavy;

  int get defValue {
    switch (this) {
      case DefCategory.none:
        return 0;
      case DefCategory.light:
        return 1;
      case DefCategory.medium:
        return 2;
      case DefCategory.heavy:
        return 3;
    }
  }
} 