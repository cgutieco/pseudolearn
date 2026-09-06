enum OutputLineKind {
  programOutput,
  userInputEcho,
}

final class OutputLine {
  final String text;
  final OutputLineKind kind;

  const OutputLine({
    required this.text,
    required this.kind,
  });
}
