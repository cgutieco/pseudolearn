enum ExerciseLevel {
  reproduce(1),
  compose(2),
  design(3);

  final int number;

  const ExerciseLevel(this.number);

  static ExerciseLevel? fromNumber(int number) {
    for (final level in values) {
      if (level.number == number) return level;
    }
    return null;
  }
}
