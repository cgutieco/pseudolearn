import 'package:equatable/equatable.dart';
import '../analysis/highlight_span.dart';

final class HelpProgram extends Equatable {
  final String source;
  final String? output;
  final List<HighlightSpan> highlightSpans;

  const HelpProgram({
    required this.source,
    this.output,
    this.highlightSpans = const [],
  });

  HelpProgram highlighted(List<HighlightSpan> spans) =>
      HelpProgram(source: source, output: output, highlightSpans: spans);

  @override
  List<Object?> get props => [source, output, highlightSpans];
}

enum HelpExampleKind { executable, accepted, diagnostic }

final class HelpExample extends Equatable {
  final HelpExampleKind kind;
  final String note;
  final HelpProgram program;

  const HelpExample({
    required this.kind,
    required this.note,
    required this.program,
  });

  HelpExample withProgram(HelpProgram value) =>
      HelpExample(kind: kind, note: note, program: value);

  @override
  List<Object?> get props => [kind, note, program];
}

final class HelpCommonError extends Equatable {
  final String text;
  final HelpProgram? program;

  const HelpCommonError({required this.text, this.program});

  HelpCommonError withProgram(HelpProgram? value) =>
      HelpCommonError(text: text, program: value);

  @override
  List<Object?> get props => [text, program];
}
