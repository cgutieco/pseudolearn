import 'reference_token.dart';

final class ReferenceDiagnostic {
  final String code;
  final String severity;
  final int line;
  final int column;
  final String message;

  const ReferenceDiagnostic({
    required this.code,
    required this.severity,
    required this.line,
    required this.column,
    required this.message,
  });
}

final class ReferenceProgram {
  final String id;
  final String title;
  final String source;
  final List<List<ReferenceToken>> lines;
  final bool executed;
  final List<String> inputs;
  final String output;
  final String termination;
  final List<ReferenceDiagnostic> diagnostics;

  const ReferenceProgram({
    required this.id,
    required this.title,
    required this.source,
    required this.lines,
    required this.executed,
    this.inputs = const [],
    this.output = '',
    this.termination = '',
    this.diagnostics = const [],
  });

  bool get completed => termination == 'completed';
}
