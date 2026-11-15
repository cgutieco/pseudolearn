import 'package:bloc/bloc.dart';
import '../../domain/model/exercises/user_exercise_command_result.dart';
import '../../domain/model/exercises/user_exercise_draft.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/ports/user_exercise_repository.dart';
import 'use_cases/create_user_exercise.dart';
import 'use_cases/update_user_exercise.dart';
import 'user_exercise_editor_state.dart';
import 'user_exercise_form.dart';

final class UserExerciseEditorCubit extends Cubit<UserExerciseEditorState> {
  final UserExerciseRepository _repository;
  final CreateUserExercise _create;
  final UpdateUserExercise _update;

  UserExerciseEditorCubit({
    required this._repository,
    required this._create,
    required this._update,
  }) : super(UserExerciseEditorState.blank(SyntaxProfileId.classicSpanish));

  Future<void> open(String? exerciseId, {required SyntaxProfileId profileId}) async {
    if (exerciseId == null) {
      emit(UserExerciseEditorState.blank(profileId));
      return;
    }
    emit(UserExerciseEditorState(draft: state.draft, status: UserExerciseEditorStatus.loading));
    final exercise = await _repository.loadExercise(exerciseId);
    if (isClosed) return;
    emit(exercise == null
        ? UserExerciseEditorState(draft: state.draft, status: UserExerciseEditorStatus.missing)
        : UserExerciseEditorState(exerciseId: exercise.id, draft: exercise.draft));
  }

  Future<void> submit(UserExerciseForm form) async {
    final (draft, malformed) = form.toDraft();
    if (draft == null) {
      emit(UserExerciseEditorState(
        exerciseId: state.exerciseId,
        draft: state.draft,
        status: UserExerciseEditorStatus.formatError,
        malformedField: malformed,
      ));
      return;
    }
    emit(UserExerciseEditorState(
      exerciseId: state.exerciseId,
      draft: draft,
      status: UserExerciseEditorStatus.saving,
    ));
    _emitResult(draft, await _save(draft));
  }

  Future<UserExerciseCommandResult> _save(UserExerciseDraft draft) {
    final id = state.exerciseId;
    return id == null ? _create(draft) : _update(exerciseId: id, draft: draft);
  }

  void _emitResult(UserExerciseDraft draft, UserExerciseCommandResult result) {
    if (isClosed) return;
    emit(switch (result) {
      UserExerciseSaved(:final exercise) => UserExerciseEditorState(
        exerciseId: exercise.id,
        draft: exercise.draft,
        status: UserExerciseEditorStatus.saved,
      ),
      UserExerciseInvalid(:final publication) => UserExerciseEditorState(
        exerciseId: state.exerciseId,
        draft: draft,
        publication: publication,
      ),
      UserExerciseMissing() => UserExerciseEditorState(
        draft: draft,
        status: UserExerciseEditorStatus.missing,
      ),
      UserExerciseStorageFailed() => UserExerciseEditorState(
        exerciseId: state.exerciseId,
        draft: draft,
        status: UserExerciseEditorStatus.storageError,
      ),
    });
  }
}
