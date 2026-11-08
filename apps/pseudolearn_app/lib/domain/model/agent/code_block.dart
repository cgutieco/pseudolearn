enum CodeBlockVerdict { verified, withErrors, notPseudoLearn }

final class CodeBlock {
  final String language;
  final String source;
  final int start;
  final int end;

  const CodeBlock({
    required this.language,
    required this.source,
    required this.start,
    required this.end,
  });

  bool get isPseudoLearn =>
      language.isEmpty || language == 'pseudolearn' || language == 'pseudo';
}

final class CheckedCodeBlock {
  final CodeBlock block;
  final CodeBlockVerdict verdict;
  final List<String> problems;

  const CheckedCodeBlock({
    required this.block,
    required this.verdict,
    this.problems = const [],
  });

  bool get canInsert => verdict == CodeBlockVerdict.verified;
}
