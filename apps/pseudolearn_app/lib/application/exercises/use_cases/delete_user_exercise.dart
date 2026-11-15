import '../../../domain/ports/user_exercise_repository.dart';

final class DeleteUserExercise {
  final UserExerciseRepository _repository;

  const DeleteUserExercise({required this._repository});

  Future<bool> call(String exerciseId) async {
    try {
      await _repository.deleteExercise(exerciseId);
      return true;
    } catch (_) {
      return false;
    }
  }
}
