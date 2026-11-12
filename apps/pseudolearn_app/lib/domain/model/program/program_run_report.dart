enum ProgramRunOutcome {
  finished,
  notExecutable,
  halted,
  stepLimitReached,
  inputsExhausted,
}

final class ProgramRunReport {
  final ProgramRunOutcome outcome;
  final List<String> outputs;
  final List<String> errors;

  const ProgramRunReport({
    required this.outcome,
    required this.outputs,
    this.errors = const [],
  });

  bool get finished => outcome == ProgramRunOutcome.finished;
}
