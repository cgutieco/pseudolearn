import '../../../domain/model/agent/flowchart.dart';

final class MermaidShapeSyntax {
  final String opener;
  final String closer;
  final FlowchartShape shape;

  const MermaidShapeSyntax(this.opener, this.closer, this.shape);
}

const List<MermaidShapeSyntax> mermaidShapeSyntaxes = [
  MermaidShapeSyntax('(((', ')))', FlowchartShape.circle),
  MermaidShapeSyntax('((', '))', FlowchartShape.circle),
  MermaidShapeSyntax('([', '])', FlowchartShape.stadium),
  MermaidShapeSyntax('[[', ']]', FlowchartShape.subroutine),
  MermaidShapeSyntax('[(', ')]', FlowchartShape.cylinder),
  MermaidShapeSyntax('{{', '}}', FlowchartShape.hexagon),
  MermaidShapeSyntax('[/', '/]', FlowchartShape.parallelogram),
  MermaidShapeSyntax('[/', r'\]', FlowchartShape.trapezoid),
  MermaidShapeSyntax(r'[\', r'\]', FlowchartShape.parallelogram),
  MermaidShapeSyntax(r'[\', '/]', FlowchartShape.trapezoid),
  MermaidShapeSyntax('>', ']', FlowchartShape.flag),
  MermaidShapeSyntax('[', ']', FlowchartShape.rectangle),
  MermaidShapeSyntax('(', ')', FlowchartShape.rounded),
  MermaidShapeSyntax('{', '}', FlowchartShape.diamond),
];

final class MermaidShapeMatch {
  final FlowchartShape shape;
  final String label;
  final int end;

  const MermaidShapeMatch({required this.shape, required this.label, required this.end});
}

MermaidShapeMatch? matchMermaidShape(String text, int position) {
  MermaidShapeMatch? best;
  var bestOpener = 0;
  for (final syntax in mermaidShapeSyntaxes) {
    if (syntax.opener.length < bestOpener || !text.startsWith(syntax.opener, position)) continue;
    final match = _closed(text, position + syntax.opener.length, syntax);
    if (match == null) continue;
    final longer = syntax.opener.length > bestOpener;
    if (longer || best == null || match.end < best.end) best = match;
    bestOpener = syntax.opener.length;
  }
  return best;
}

MermaidShapeMatch? _closed(String text, int labelStart, MermaidShapeSyntax syntax) {
  var searchFrom = labelStart;
  final trimmedStart = _skipSpaces(text, labelStart);
  if (trimmedStart < text.length && text[trimmedStart] == '"') {
    final quoteEnd = text.indexOf('"', trimmedStart + 1);
    if (quoteEnd < 0) return null;
    searchFrom = quoteEnd + 1;
  }
  final closerAt = text.indexOf(syntax.closer, searchFrom);
  if (closerAt < 0) return null;
  return MermaidShapeMatch(
    shape: syntax.shape,
    label: text.substring(labelStart, closerAt),
    end: closerAt + syntax.closer.length,
  );
}

int _skipSpaces(String text, int position) {
  var cursor = position;
  while (cursor < text.length && text[cursor] == ' ') {
    cursor += 1;
  }
  return cursor;
}
