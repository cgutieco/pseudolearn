import '../../domain/model/editor/caret_range.dart';
import '../../domain/model/help/help_query_result.dart';
import '../../domain/model/help/syntax_help.dart';
import 'utf16_line_index.dart';

HelpQueryResult projectHelpResponse(
  Map<String, Object?> response,
  Utf16LineIndex lines,
  int revision,
) {
  final resolution = response['resolution'];
  if (resolution is! Map<String, Object?>) {
    return HelpQueryResult.noHelp(revision: revision);
  }
  final range = _range(resolution['lexical_range'], lines);
  if (range == null) return HelpQueryResult.failure(revision: revision);
  final entry = response['help'];
  final help = SyntaxHelp(
    headline: _headline(entry, resolution),
    description: entry is Map<String, Object?>
        ? entry['description'] as String?
        : null,
    card: _card(response['card']),
    range: range,
    isPartial: resolution['certainty'] == 'partial',
  );
  return resolution['symbol'] is Map<String, Object?>
      ? HelpQueryResult.symbol(help, revision: revision)
      : HelpQueryResult.help(help, revision: revision);
}

CaretRange? _range(Object? bounds, Utf16LineIndex lines) {
  if (bounds is! Map<String, Object?>) return null;
  final start = _offset(bounds['start'], lines);
  final end = _offset(bounds['end'], lines);
  if (start == null || end == null) return null;
  return CaretRange(start: start, end: end);
}

int? _offset(Object? point, Utf16LineIndex lines) {
  if (point is! Map<String, Object?>) return null;
  final line = point['line'];
  final column = point['column'];
  if (line is! int || column is! int) return null;
  return lines.offsetAtScalarColumn(line: line, column: column);
}

String _headline(Object? entry, Map<String, Object?> resolution) {
  if (entry is! Map<String, Object?>) {
    final identity = resolution['identity'];
    return identity is Map<String, Object?> ? '${identity['id']}' : '';
  }
  final signature = entry['signature'] as String?;
  if (signature != null) return signature;
  final typeName = entry['type_name'] as String? ?? '';
  final identifier = '${entry['identifier']}';
  return typeName.isEmpty ? identifier : '$identifier: $typeName';
}

HelpCardSections? _card(Object? value) {
  if (value is! Map<String, Object?>) return null;
  return HelpCardSections(
    id: '${value['id']}',
    title: '${value['title']}',
    summary: '${value['summary']}',
    purpose: value['purpose'] as String? ?? '',
    parts: _list(value['parts'])
        .map(
          (part) => HelpPart(
            identity: '${part['identity']}',
            text: '${part['text']}',
          ),
        )
        .toList(),
    constraints: _strings(value['constraints']),
    commonErrors: _strings(value['common_errors']),
    examples: _list(value['examples']).map(_example).toList(),
  );
}

HelpExampleLink _example(Map<String, Object?> value) => HelpExampleLink(
  specification: '${value['specification']}',
  version: '${value['version']}',
  caseId: '${value['case']}',
  profile: '${value['profile']}',
  strictness: '${value['strictness']}',
  kind: '${value['kind']}',
  label: '${value['label']}',
);

List<Map<String, Object?>> _list(Object? value) =>
    value is List<Object?> ? value.cast<Map<String, Object?>>() : const [];

List<String> _strings(Object? value) =>
    value is List<Object?> ? value.map((item) => '$item').toList() : const [];
