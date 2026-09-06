import 'package:bloc/bloc.dart';
import '../../../domain/model/knowledge/content_load_result.dart';
import '../../../domain/model/knowledge/exercise.dart';
import '../../../domain/model/knowledge/exercise_case_failure.dart';
import '../../../domain/model/knowledge/exercise_check_result.dart';
import '../../../domain/model/knowledge/knowledge_entry.dart';
import '../../../domain/model/knowledge/knowledge_entry_type.dart';
import '../../../domain/model/profiles/syntax_profile_id.dart';
import '../../../domain/model/settings/ui_language_id.dart';
import '../../../domain/ports/exercise_checker.dart';
import '../../../domain/ports/knowledge_repository.dart';
import '../../../domain/ports/local_progress_store.dart';
import 'exercise_session_state.dart';

final class ExerciseSessionCubit extends Cubit<ExerciseSessionState> {
  final KnowledgeRepository _repository;
  final ExerciseChecker _checker;
  final LocalProgressStore _progressStore;

  String? _loadedRequest;
  UiLanguageId? _loadedLanguageId;

  ExerciseSessionCubit({
    required KnowledgeRepository repository,
    required ExerciseChecker checker,
    required LocalProgressStore progressStore,
  })  : _repository = repository,
        _checker = checker,
        _progressStore = progressStore,
        super(const ExerciseSessionState());

  Future<void> loadExercise({
    required String exerciseIdOrPath,
    required UiLanguageId languageId,
  }) async {
    if (_alreadyHolds(exerciseIdOrPath, languageId)) return;
    emit(state.copyWith(status: ExerciseSessionStatus.loading));
    try {
      final path = await _resolveExercisePath(exerciseIdOrPath, languageId);
      if (path == null) {
        emit(state.copyWith(
          status: ExerciseSessionStatus.exerciseNotFound,
          exercise: () => null,
        ));
        return;
      }
      final result = await _repository.getExercise(path);
      if (result is ContentLoadFailed<Exercise>) {
        emit(state.copyWith(
          status: ExerciseSessionStatus.error,
          errorMessage: () => result.detail,
        ));
        return;
      }
      final exercise = (result as ContentLoaded<Exercise>).value;
      final isCompleted = await _progressStore.isExerciseCompleted(exercise.id);
      _loadedRequest = exerciseIdOrPath;
      _loadedLanguageId = languageId;
      _emitLoadedExercise(exercise, isCompleted: isCompleted);
    } catch (e) {
      emit(state.copyWith(
        status: ExerciseSessionStatus.error,
        errorMessage: () => e.toString(),
      ));
    }
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

  bool _alreadyHolds(String exerciseIdOrPath, UiLanguageId languageId) =>
      _loadedRequest == exerciseIdOrPath &&
      _loadedLanguageId == languageId &&
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
      await _progressStore.markExerciseCompleted(exercise.id);
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

  Future<String?> _resolveExercisePath(
    String exerciseIdOrPath,
    UiLanguageId languageId,
  ) async {
    if (exerciseIdOrPath.endsWith('.json')) {
      return exerciseIdOrPath;
    }
    final entriesResult = await _repository.getEntries(languageId);
    if (entriesResult is! ContentLoaded<List<KnowledgeEntry>>) {
      return null;
    }
    final entry = entriesResult.value.cast<KnowledgeEntry?>().firstWhere(
          (e) =>
              e?.id == exerciseIdOrPath &&
              e?.type == KnowledgeEntryType.exercise,
          orElse: () => null,
        );
    return entry?.path;
  }
}
