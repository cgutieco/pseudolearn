import '../../../domain/model/exercises/user_exercise.dart';
import '../../../domain/model/exercises/user_exercise_command_result.dart';
import '../../../domain/model/exercises/user_exercise_draft.dart';
import '../../../domain/ports/clock.dart';
import '../../../domain/ports/identifier_generator.dart';
import '../../../domain/ports/user_exercise_repository.dart';
import 'validate_user_exercise.dart';

final class CreateUserExercise {
  final UserExerciseRepository _repository;
  final ValidateUserExercise _validate;
  final IdentifierGenerator _identifiers;
  final Clock _clock;

  const CreateUserExercise({
    required this._repository,
    required this._validate,
    required this._identifiers,
    required this._clock,
  });

  Future<UserExerciseCommandResult> call(UserExerciseDraft draft) async {
    final publication = _validate(draft);
    if (!publication.isPublishable) return UserExerciseInvalid(publication);
    final now = _clock.now();
    try {
      final saved = await _repository.saveExercise(
        UserExercise(
          id: _identifiers.generate(),
          draft: draft,
          revision: 1,
          createdAt: now,
          updatedAt: now,
        ),
      );
      return UserExerciseSaved(saved);
    } catch (_) {
      return const UserExerciseStorageFailed();
    }
  }
}
