import '../../../domain/model/exercises/user_exercise_command_result.dart';
import '../../../domain/model/exercises/user_exercise_draft.dart';
import '../../../domain/ports/clock.dart';
import '../../../domain/ports/user_exercise_repository.dart';
import 'validate_user_exercise.dart';

final class UpdateUserExercise {
  final UserExerciseRepository _repository;
  final ValidateUserExercise _validate;
  final Clock _clock;

  const UpdateUserExercise({
    required this._repository,
    required this._validate,
    required this._clock,
  });

  Future<UserExerciseCommandResult> call({
    required String exerciseId,
    required UserExerciseDraft draft,
  }) async {
    final publication = _validate(draft);
    if (!publication.isPublishable) return UserExerciseInvalid(publication);
    try {
      final current = await _repository.loadExercise(exerciseId);
      if (current == null) return const UserExerciseMissing();
      final saved = await _repository.saveExercise(
        current.revised(draft, _clock.now()),
      );
      return UserExerciseSaved(saved);
    } catch (_) {
      return const UserExerciseStorageFailed();
    }
  }
}
