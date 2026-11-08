import '../../../domain/model/agent/flowchart.dart';
import 'mermaid_label.dart';

final RegExp _labeledLink = RegExp(
  r'\s*(<?)(--|==|-\.)\s*([^\s>\-=.|].*?)\s*(-{2,}>|={2,}>|\.-+>|-{3,}|={3,}|\.-+)',
);
final RegExp _plainLink = RegExp(r'\s*(<?)(-{2,}|={2,}|-\.+-|~{3,})(>|o|x)?(\s*\|([^|]*)\|)?');

final class MermaidLink {
  final String label;
  final FlowchartStroke stroke;
  final bool arrowAtStart;
  final bool arrowAtEnd;
  final int end;

  const MermaidLink({
    required this.label,
    required this.stroke,
    required this.arrowAtStart,
    required this.arrowAtEnd,
    required this.end,
  });

  FlowchartEdge between(String from, String to) => FlowchartEdge(
    from: from,
    to: to,
    label: label,
    stroke: stroke,
    arrowAtStart: arrowAtStart,
    arrowAtEnd: arrowAtEnd,
  );
}

MermaidLink? matchMermaidLink(String text, int position) {
  final labeled = _labeledLink.matchAsPrefix(text, position);
  if (labeled != null) {
    final operator = '${labeled.group(2)}${labeled.group(4)}';
    return MermaidLink(
      label: cleanMermaidLabel(labeled.group(3) ?? ''),
      stroke: _strokeOf(operator),
      arrowAtStart: (labeled.group(1) ?? '').isNotEmpty,
      arrowAtEnd: operator.endsWith('>'),
      end: labeled.end,
    );
  }
  final plain = _plainLink.matchAsPrefix(text, position);
  if (plain == null) return null;
  return MermaidLink(
    label: cleanMermaidLabel(plain.group(5) ?? ''),
    stroke: _strokeOf(plain.group(2) ?? ''),
    arrowAtStart: (plain.group(1) ?? '').isNotEmpty,
    arrowAtEnd: plain.group(3) != null,
    end: plain.end,
  );
}

FlowchartStroke _strokeOf(String operator) {
  if (operator.contains('~')) return FlowchartStroke.invisible;
  if (operator.contains('=')) return FlowchartStroke.thick;
  if (operator.contains('.')) return FlowchartStroke.dotted;
  return FlowchartStroke.solid;
}
