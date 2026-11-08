import '../../domain/model/knowledge/exercise_check_outcome.dart';

final class ProgramRun {
  final ExerciseCheckOutcome? anomaly;
  final List<String> outputs;
  final List<String> errors;

  const ProgramRun({
    required this.anomaly,
    required this.outputs,
    this.errors = const [],
  });
}
