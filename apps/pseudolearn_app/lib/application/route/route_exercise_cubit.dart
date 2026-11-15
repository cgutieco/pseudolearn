import 'package:bloc/bloc.dart';
import '../../domain/model/knowledge/content_load_result.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/reference/reference_edition.dart';
import '../../domain/model/route/route_answer.dart';
import '../../domain/model/route/route_exercise.dart';
import '../../domain/model/route/route_kinds.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/local_progress_store.dart';
import '../../domain/ports/route_answer_evaluator.dart';
import '../../domain/ports/route_repository.dart';
import 'route_exercise_state.dart';

final class RouteExerciseCubit extends Cubit<RouteExerciseState> {
  final RouteRepository _repository;
  final LocalProgressStore _progressStore;
  final Map<RouteExerciseKind, RouteAnswerEvaluator> _evaluators;

  RouteExerciseCubit({
    required this._repository,
    required this._progressStore,
    required this._evaluators,
  }) : super(const RouteExerciseState());

  Future<void> load(ReferenceEdition edition, String exerciseId) async {
    emit(const RouteExerciseState(status: RouteExerciseStatus.loading));
    final loaded = await _repository.loadExercise(edition, exerciseId);
    if (isClosed) return;
    if (loaded is! ContentLoaded<RouteExercise>) {
      emit(const RouteExerciseState(status: RouteExerciseStatus.notFound));
      return;
    }
    final completed = await _progressStore.isExerciseCompleted(
      routeExerciseProgressId(exerciseId),
    );
    if (isClosed) return;
    emit(
      RouteExerciseState(
        status: RouteExerciseStatus.ready,
        exercise: loaded.value,
        completed: completed,
      ),
    );
  }

  Future<void> submit({
    required RouteAnswer answer,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) async {
    final exercise = state.exercise;
    final evaluator = exercise == null ? null : _evaluators[exercise.kind];
    if (exercise == null || evaluator == null) return;
    emit(state.copyWith(status: RouteExerciseStatus.checking));
    final verdict = evaluator.evaluate(
      exercise: exercise,
      answer: answer,
      profileId: profileId,
      languageId: languageId,
    );
    if (verdict.solved) {
      await _progressStore.markExerciseCompleted(
        routeExerciseProgressId(exercise.id),
      );
    }
    if (isClosed) return;
    emit(
      state.copyWith(
        status: RouteExerciseStatus.ready,
        verdict: () => verdict,
        completed: state.completed || verdict.solved,
      ),
    );
  }

  void showNextHint() {
    if (!state.canShowHint) return;
    emit(state.copyWith(hintsShown: state.hintsShown + 1));
  }

  void revealAnswer() => emit(state.copyWith(answerRevealed: true));

  void clearVerdict() => emit(state.copyWith(verdict: () => null));
}
