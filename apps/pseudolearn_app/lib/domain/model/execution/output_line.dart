enum OutputLineKind {
  programOutput,
  userInputEcho,
  rejectedInput,
  programError,
}

final class OutputLine {
  final String text;
  final OutputLineKind kind;
  final String? target;
  final int? sourceLine;

  const OutputLine({
    required this.text,
    required this.kind,
    this.target,
    this.sourceLine,
  });
}
