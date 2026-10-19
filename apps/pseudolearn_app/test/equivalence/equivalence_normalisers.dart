import 'package:pseudolearn_app/domain/model/analysis/analysis_report.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_program.dart';
import 'package:pseudolearn_app/domain/model/knowledge/marker_resolution.dart';

const Map<String, String> _accents = {
  'á': 'a',
  'é': 'e',
  'í': 'i',
  'ó': 'o',
  'ú': 'u',
};

String fold(String text) {
  final buffer = StringBuffer();
  for (final rune in text.toLowerCase().runes) {
    final character = String.fromCharCode(rune);
    buffer.write(_accents[character] ?? character);
  }
  return buffer.toString();
}

Set<String> diagnosticKeys(AnalysisReport report) => {
  for (final diagnostic in report.diagnostics)
    '${diagnostic.code}/${diagnostic.severity.name}'
        '@${diagnostic.primaryRange.startLine}:${diagnostic.primaryRange.startColumn}',
};

String diagramShapes(DiagramProgram program) => [
  for (final unit in program.units)
    '${unit.displayName}[${[for (final node in program.sceneFor(unit.id).nodes) node.shape.name].join(',')}]',
].join(' ');

String markerFingerprint(MarkerResolution? resolution) => switch (resolution) {
  null => 'null',
  ResolvedMarkerText(:final text) => fold(text),
  ResolvedMarkerTable(:final headers, :final rows) =>
    '${headers.join('|')}#${(rows.map((row) => fold(row.join('|'))).toList()..sort()).join(';')}',
  ResolvedMarkerDiagnostic(:final code, :final severity, :final message) =>
    '$code/${severity.name}/$message',
};
