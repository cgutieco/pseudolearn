import 'package:bloc/bloc.dart';
import '../../../domain/model/exercises/exercise_reference.dart';
import '../../../domain/model/exercises/user_exercise_projection.dart';
import '../../../domain/model/knowledge/content_load_result.dart';
import '../../../domain/model/knowledge/exercise.dart';
import '../../../domain/model/knowledge/exercise_case_failure.dart';
import '../../../domain/model/knowledge/exercise_check_result.dart';
import '../../../domain/model/profiles/syntax_profile_id.dart';
import '../../../domain/model/reference/reference_edition.dart';
import '../../../domain/model/route/route_exercise.dart';
import '../../../domain/model/route/route_exercise_projection.dart';
import '../../../domain/model/route/route_kinds.dart';
import '../../../domain/model/settings/ui_language_id.dart';
import '../../../domain/ports/exercise_checker.dart';
import '../../../domain/ports/local_progress_store.dart';
import '../../../domain/ports/route_repository.dart';
import '../../../domain/ports/user_exercise_repository.dart';
import 'exercise_session_state.dart';

final class ExerciseSessionCubit extends Cubit<ExerciseSessionState> {
  final RouteRepository _repository;
  final ExerciseChecker _checker;
  final LocalProgressStore _progressStore;
  final UserExerciseRepository _userExercises;

  String? _loadedRequest;
  ReferenceEdition? _loadedEdition;

  ExerciseSessionCubit({
    required RouteRepository repository,
    required ExerciseChecker checker,
    required LocalProgressStore progressStore,
    required UserExerciseRepository userExercises,
  })  : _repository = repository,
        _checker = checker,
        _progressStore = progressStore,
        _userExercises = userExercises,
        super(const ExerciseSessionState());

  Future<void> loadExercise({
    required String exerciseId,
    required ReferenceEdition edition,
  }) async {
    if (_alreadyHolds(exerciseId, edition)) return;
    emit(state.copyWith(status: ExerciseSessionStatus.loading));
    final exercise = await _resolve(ExerciseReference.parse(exerciseId), edition);
    if (exercise == null) {
      emit(state.copyWith(
        status: ExerciseSessionStatus.exerciseNotFound,
        exercise: () => null,
      ));
      return;
    }
    final isCompleted = await _progressStore.isExerciseCompleted(
      _progressIdOf(exercise),
    );
    _loadedRequest = exerciseId;
    _loadedEdition = edition;
    _emitLoadedExercise(exercise, isCompleted: isCompleted);
  }

  Future<void> checkSolution({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) async {
    final exercise = state.exercise;
    if (exercise == null) return;

    emit(state.copyWith(status: ExerciseSessionStatus.checking));
    try {
      final result = _checker.check(
        sourceCode: sourceCode,
        profileId: profileId,
        languageId: languageId,
        visibleCases: exercise.visibleCases,
        hiddenCases: exercise.hiddenCases,
        assertions: exercise.assertions,
      );
      await _emitCheckSuccess(exercise, result);
    } catch (e) {
      emit(state.copyWith(
        status: ExerciseSessionStatus.error,
        errorMessage: () => e.toString(),
      ));
    }
  }

  Future<Exercise?> _resolve(
    ExerciseReference reference,
    ReferenceEdition edition,
  ) async {
    if (reference.origin == ExerciseOrigin.user) {
      final exercise = await _userExercises.loadExercise(reference.id);
      return exercise == null ? null : exerciseOfUser(exercise);
    }
    final result = await _repository.loadExercise(edition, reference.id);
    return result is ContentLoaded<RouteExercise>
        ? editorExerciseOf(result.value)
        : null;
  }

  String _progressIdOf(Exercise exercise) =>
      exercise.origin == ExerciseOrigin.user
      ? userExerciseProgressId(exercise.id)
      : routeExerciseProgressId(exercise.id);

  bool _alreadyHolds(String exerciseId, ReferenceEdition edition) =>
      _loadedRequest == exerciseId &&
      _loadedEdition == edition &&
      state.exercise != null;

  void resetResult() {
    emit(state.copyWith(
      lastResult: () => null,
      revealedHiddenFailure: () => null,
    ));
  }

  void _emitLoadedExercise(Exercise exercise, {required bool isCompleted}) {
    emit(state.copyWith(
      status: ExerciseSessionStatus.ready,
      exercise: () => exercise,
      isCompleted: isCompleted,
      lastResult: () => null,
      revealedHiddenFailure: () => null,
      errorMessage: () => null,
    ));
  }

  Future<void> _emitCheckSuccess(
    Exercise exercise,
    ExerciseCheckResult result,
  ) async {
    var isCompleted = state.isCompleted;
    ExerciseCaseFailure? revealedHiddenFailure;
    if (result.isSolved) {
      await _progressStore.markExerciseCompleted(_progressIdOf(exercise));
      isCompleted = true;
    } else if (result.firstFailure != null && result.firstFailure!.isHidden) {
      revealedHiddenFailure = result.firstFailure;
    }
    emit(state.copyWith(
      status: ExerciseSessionStatus.success,
      lastResult: () => result,
      isCompleted: isCompleted,
      revealedHiddenFailure: () => revealedHiddenFailure,
      errorMessage: () => null,
    ));
  }
}
