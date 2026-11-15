import '../../domain/model/reference/reference_program.dart';
import '../../domain/model/route/route_exercise.dart';
import '../../domain/model/route/route_kinds.dart';
import '../../domain/model/route/route_verdict.dart';

enum RouteExerciseStatus { initial, loading, ready, checking, notFound }

final class RouteExerciseState {
  final RouteExerciseStatus status;
  final RouteExercise? exercise;
  final RouteVerdict? verdict;
  final int hintsShown;
  final bool answerRevealed;
  final bool completed;

  const RouteExerciseState({
    this.status = RouteExerciseStatus.initial,
    this.exercise,
    this.verdict,
    this.hintsShown = 0,
    this.answerRevealed = false,
    this.completed = false,
  });

  bool get isOpen => answerRevealed || (verdict?.solved ?? false);

  ReferenceProgram? get shownProgram {
    final program = exercise?.program;
    if (program == null) return null;
    final hidesRun = exercise?.kind == RouteExerciseKind.predict && !isOpen;
    return hidesRun || !program.executed ? program.withoutRun() : program;
  }

  bool get canShowHint =>
      exercise != null && hintsShown < (exercise?.hints.length ?? 0);

  RouteExerciseState copyWith({
    RouteExerciseStatus? status,
    RouteVerdict? Function()? verdict,
    int? hintsShown,
    bool? answerRevealed,
    bool? completed,
  }) {
    return RouteExerciseState(
      status: status ?? this.status,
      exercise: exercise,
      verdict: verdict != null ? verdict() : this.verdict,
      hintsShown: hintsShown ?? this.hintsShown,
      answerRevealed: answerRevealed ?? this.answerRevealed,
      completed: completed ?? this.completed,
    );
  }
}
