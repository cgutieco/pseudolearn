import 'exercise_publication.dart';
import 'user_exercise.dart';

sealed class UserExerciseCommandResult {
  const UserExerciseCommandResult();
}

final class UserExerciseSaved extends UserExerciseCommandResult {
  final UserExercise exercise;

  const UserExerciseSaved(this.exercise);
}

final class UserExerciseInvalid extends UserExerciseCommandResult {
  final ExercisePublication publication;

  const UserExerciseInvalid(this.publication);
}

final class UserExerciseMissing extends UserExerciseCommandResult {
  const UserExerciseMissing();
}

final class UserExerciseStorageFailed extends UserExerciseCommandResult {
  const UserExerciseStorageFailed();
}
