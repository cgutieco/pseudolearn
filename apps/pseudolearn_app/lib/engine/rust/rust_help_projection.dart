import '../../domain/model/editor/caret_range.dart';
import '../../domain/model/help/help_query_result.dart';
import '../../domain/model/help/help_form.dart';
import '../../domain/model/help/help_part.dart';
import '../../domain/model/help/help_program.dart';
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
    category: _category(value['category']),
    form: _list(value['form']).map(_formLine).toList(),
    parts: _list(value['parts']).map(_part).toList(),
    result: value['result'] as String?,
    rules: _strings(value['rules']),
    commonErrors: _list(value['common_errors']).map(_commonError).toList(),
    examples: _list(value['examples']).map(_example).toList(),
  );
}

HelpCategory? _category(Object? value) => switch (value) {
  'block' => HelpCategory.block,
  'instruction' => HelpCategory.instruction,
  'symbol' => HelpCategory.symbol,
  'function' => HelpCategory.function,
  'type' => HelpCategory.type,
  'value' => HelpCategory.value,
  _ => null,
};

HelpFormLine _formLine(Map<String, Object?> value) => HelpFormLine(
  indent: value['indent'] as int? ?? 0,
  segments: _list(value['segments']).map(_segment).toList(),
);

HelpFormSegment _segment(Map<String, Object?> value) {
  final text = '${value['text']}';
  return HelpFormSegment(
    kind: switch (value['kind']) {
      'slot' => HelpFormSegmentKind.slot,
      'ellipsis' => HelpFormSegmentKind.ellipsis,
      'word' => HelpFormSegmentKind.word,
      _ => HelpFormSegmentKind.symbol,
    },
    text: text,
    joined: value['joined'] == true,
  );
}

HelpPart _part(Map<String, Object?> value) => HelpPart(
  kind: value['kind'] == 'slot' ? HelpPartKind.slot : HelpPartKind.word,
  name: '${value['name']}',
  text: '${value['text']}',
);

HelpCommonError _commonError(Map<String, Object?> value) => HelpCommonError(
  text: '${value['text']}',
  program: _program(value['program']),
);

HelpExample _example(Map<String, Object?> value) => HelpExample(
  kind: switch (value['kind']) {
    'executable' => HelpExampleKind.executable,
    'accepted' => HelpExampleKind.accepted,
    _ => HelpExampleKind.diagnostic,
  },
  note: '${value['note']}',
  program: _program(value['program']) ?? const HelpProgram(source: ''),
);

HelpProgram? _program(Object? value) {
  if (value is! Map<String, Object?>) return null;
  return HelpProgram(
    source: '${value['source']}',
    output: value['output'] as String?,
  );
}

List<Map<String, Object?>> _list(Object? value) =>
    value is List<Object?> ? value.cast<Map<String, Object?>>() : const [];

List<String> _strings(Object? value) =>
    value is List<Object?> ? value.map((item) => '$item').toList() : const [];
