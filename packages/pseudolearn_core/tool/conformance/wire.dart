import 'package:pseudolearn_core/pseudolearn_core.dart';

Map<String, Object?> diagnosticWire(
        Diagnostic diagnostic, String classification) =>
    {
      'code': diagnostic.code.name,
      'class': classification,
      'severity': diagnostic.severity.name,
      'span': spanWire(diagnostic.span),
      'related': diagnostic.relatedSpans.map(spanWire).toList(),
      'arguments': diagnostic.arguments
          .map((name, argument) => MapEntry(name, argumentWire(argument))),
    };

Map<String, Object?> spanWire(Span span) => {
      'start': {'line': span.start.line, 'column': span.start.column},
      'end': {'line': span.end.line, 'column': span.end.column},
    };

Object argumentWire(DiagnosticArgument argument) => switch (argument) {
      TokenDiagnosticArgument(:final tokenType) => tokenType.name,
      TypeDiagnosticArgument(:final type) => type.name,
      TermDiagnosticArgument(:final term) => term.name,
      LexemeDiagnosticArgument(:final lexeme) => lexeme,
      NumberDiagnosticArgument(:final value) => value,
      IntegerValueDiagnosticArgument(:final value) => value.toString(),
    };
