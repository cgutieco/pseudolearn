import '../../domain/model/reference/reference_form.dart';
import '../../domain/model/reference/reference_program.dart';
import 'reference_json.dart';
import 'reference_run_parser.dart';

ReferenceProgram parseProgram(Map<String, Object?> source) {
  return ReferenceProgram(
    id: textOf(source, 'id'),
    title: textOf(source, 'title'),
    source: textOf(source, 'source'),
    lines: mappedList(source['lines'], parseTokens),
    executed: flagOf(source, 'executed'),
    inputs: source['inputs'] == null
        ? const []
        : mappedList(source['inputs'], (line) => '$line'),
    output: optionalTextOf(source, 'output'),
    termination: optionalTextOf(source, 'termination'),
    diagnostics: mappedList(source['diagnostics'], parseDiagnostic),
  );
}

ReferenceDiagnostic parseDiagnostic(Object? value) {
  final source = objectOf(value);
  return ReferenceDiagnostic(
    code: textOf(source, 'code'),
    severity: textOf(source, 'severity'),
    line: numberOf(source, 'line'),
    column: numberOf(source, 'column'),
    message: textOf(source, 'message'),
  );
}

List<ReferenceFormSegment> parseFormLine(Object? value) =>
    mappedList(value, _segment);

ReferenceFormSegment _segment(Object? value) {
  final source = objectOf(value);
  return switch (textOf(source, 'type')) {
    'token' => ReferenceFormToken(parseToken(source['token'])),
    'slot' => ReferenceFormSlot(textOf(source, 'text')),
    'optional' => ReferenceFormOptional(textOf(source, 'text')),
    final other => throw FormatException('unknown form segment $other'),
  };
}
