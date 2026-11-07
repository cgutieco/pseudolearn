import '../../../domain/model/knowledge/exercise.dart';
import '../../../domain/model/knowledge/exercise_case_failure.dart';
import '../../../domain/model/knowledge/exercise_check_result.dart';

enum ExerciseSessionStatus {
  initial,
  loading,
  ready,
  checking,
  success,
  error,
  exerciseNotFound,
}

final class ExerciseSessionState {
  final ExerciseSessionStatus status;
  final Exercise? exercise;
  final bool isCompleted;
  final ExerciseCheckResult? lastResult;
  final ExerciseCaseFailure? revealedHiddenFailure;
  final String? errorMessage;

  const ExerciseSessionState({
    this.status = ExerciseSessionStatus.initial,
    this.exercise,
    this.isCompleted = false,
    this.lastResult,
    this.revealedHiddenFailure,
    this.errorMessage,
  });

  bool get isSolved => lastResult?.isSolved ?? false;

  ExerciseSessionState copyWith({
    ExerciseSessionStatus? status,
    Exercise? Function()? exercise,
    bool? isCompleted,
    ExerciseCheckResult? Function()? lastResult,
    ExerciseCaseFailure? Function()? revealedHiddenFailure,
    String? Function()? errorMessage,
  }) {
    return ExerciseSessionState(
      status: status ?? this.status,
      exercise: exercise != null ? exercise() : this.exercise,
      isCompleted: isCompleted ?? this.isCompleted,
      lastResult: lastResult != null ? lastResult() : this.lastResult,
      revealedHiddenFailure: revealedHiddenFailure != null
          ? revealedHiddenFailure()
          : this.revealedHiddenFailure,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}
