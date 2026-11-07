import 'package:bloc/bloc.dart';
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
import 'exercise_session_state.dart';

final class ExerciseSessionCubit extends Cubit<ExerciseSessionState> {
  final RouteRepository _repository;
  final ExerciseChecker _checker;
  final LocalProgressStore _progressStore;

  String? _loadedRequest;
  ReferenceEdition? _loadedEdition;

  ExerciseSessionCubit({
    required RouteRepository repository,
    required ExerciseChecker checker,
    required LocalProgressStore progressStore,
  })  : _repository = repository,
        _checker = checker,
        _progressStore = progressStore,
        super(const ExerciseSessionState());

  Future<void> loadExercise({
    required String exerciseId,
    required ReferenceEdition edition,
  }) async {
    if (_alreadyHolds(exerciseId, edition)) return;
    emit(state.copyWith(status: ExerciseSessionStatus.loading));
    final result = await _repository.loadExercise(edition, exerciseId);
    if (result is! ContentLoaded<RouteExercise>) {
      emit(state.copyWith(
        status: ExerciseSessionStatus.exerciseNotFound,
        exercise: () => null,
      ));
      return;
    }
    final exercise = editorExerciseOf(result.value);
    final isCompleted = await _progressStore.isExerciseCompleted(
      routeExerciseProgressId(exercise.id),
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
      await _progressStore.markExerciseCompleted(
        routeExerciseProgressId(exercise.id),
      );
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
