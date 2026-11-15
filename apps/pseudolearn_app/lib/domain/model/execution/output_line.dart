enum OutputLineKind {
  programOutput,
  userInputEcho,
  programError,
}

final class OutputLine {
  final String text;
  final OutputLineKind kind;

  const OutputLine({
    required this.text,
    required this.kind,
  });
}
