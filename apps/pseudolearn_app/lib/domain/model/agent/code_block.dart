import '../analysis/highlight_span.dart';

enum CodeBlockVerdict { verified, withErrors, notPseudoLearn }

final class CodeBlock {
  final String language;
  final String source;

  const CodeBlock({required this.language, required this.source});

  bool get isPseudoLearn =>
      language.isEmpty || language == 'pseudolearn' || language == 'pseudo';
}

final class CheckedCodeBlock {
  final CodeBlock block;
  final CodeBlockVerdict verdict;
  final List<String> problems;
  final List<HighlightSpan> highlightSpans;

  const CheckedCodeBlock({
    required this.block,
    required this.verdict,
    this.problems = const [],
    this.highlightSpans = const [],
  });

  bool get canInsert => verdict == CodeBlockVerdict.verified;
}
