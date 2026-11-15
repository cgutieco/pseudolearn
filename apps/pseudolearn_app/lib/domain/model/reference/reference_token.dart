import '../analysis/highlight_span.dart';

final class ReferenceToken {
  final String text;
  final HighlightCategory? category;

  const ReferenceToken({required this.text, this.category});
}
