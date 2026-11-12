import 'exercise_reference.dart';

final class ActiveExercise {
  final ExerciseReference reference;
  final String title;
  final List<String> hints;
  final String? solution;
  final int failedAttempts;
  final bool solved;

  const ActiveExercise({
    required this.reference,
    required this.title,
    required this.hints,
    required this.solution,
    required this.failedAttempts,
    required this.solved,
  });
}
