import 'package:material_ui/material_ui.dart';
import '../../../domain/model/analysis/highlight_span.dart';
import '../../../domain/model/help/help_form.dart';
import '../../theme/tokens/syntax_colors.dart';
import '../syntax_category_color.dart';

const String helpIndentUnit = '  ';

List<InlineSpan> highlightedCodeSpans(
  String source,
  List<HighlightSpan> spans,
  AppSyntaxColors colors,
) {
  final children = <InlineSpan>[];
  var cursor = 0;
  for (final span in spans) {
    final start = span.range.startOffset.clamp(cursor, source.length);
    final end = span.range.endOffset.clamp(start, source.length);
    if (start > cursor) {
      children.add(TextSpan(text: source.substring(cursor, start)));
    }
    if (end > start) {
      children.add(
        TextSpan(
          text: source.substring(start, end),
          style: TextStyle(color: syntaxCategoryColor(span.category, colors)),
        ),
      );
    }
    cursor = end;
  }
  if (cursor < source.length) {
    children.add(TextSpan(text: source.substring(cursor)));
  }
  return children;
}

List<InlineSpan> formLineSpans(
  HelpFormLine line,
  AppSyntaxColors colors,
  InlineSpan Function(String label) slot,
) {
  final children = <InlineSpan>[
    TextSpan(text: helpIndentUnit * line.indent),
  ];
  for (final (position, segment) in line.segments.indexed) {
    if (position > 0 && !segment.joined) {
      children.add(const TextSpan(text: ' '));
    }
    children.add(switch (segment.kind) {
      HelpFormSegmentKind.slot => slot(segment.text),
      HelpFormSegmentKind.word => TextSpan(
        text: segment.text,
        style: TextStyle(color: colors.keywordStructured),
      ),
      HelpFormSegmentKind.symbol => TextSpan(
        text: segment.text,
        style: TextStyle(color: colors.ink),
      ),
      HelpFormSegmentKind.ellipsis => TextSpan(
        text: segment.text,
        style: TextStyle(color: colors.comment),
      ),
    });
  }
  return children;
}
