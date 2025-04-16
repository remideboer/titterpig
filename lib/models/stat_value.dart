class StatValue {
  final int current;
  final int max;

  const StatValue({
    required this.current,
    required this.max,
  });

  @override
  String toString() => current.toString();

  String get maxString => max.toString();

  /// Creates a StatValue with the same current and max values
  factory StatValue.full(int value) {
    return StatValue(current: value, max: value);
  }

  /// Creates a copy of this StatValue with a new current value
  StatValue copyWithCurrent(int newCurrent) {
    return StatValue(
      current: newCurrent.clamp(0, max),
      max: max,
    );
  }

  /// Returns true if current equals max
  bool get isFull => current >= max;

  /// Returns true if current is 0
  bool get isEmpty => current <= 0;

  /// Returns the percentage of current compared to max (0.0 to 1.0)
  double get percentage => current / max;
} 