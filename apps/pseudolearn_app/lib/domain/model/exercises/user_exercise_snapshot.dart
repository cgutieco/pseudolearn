import 'user_exercise.dart';

final class UserExerciseSnapshot {
  final String id;
  final UserExercise? exercise;
  final DateTime updatedAt;
  final int serverRevision;

  const UserExerciseSnapshot({
    required this.id,
    required this.exercise,
    required this.updatedAt,
    this.serverRevision = 0,
  });

  bool get isDeleted => exercise == null;
}
