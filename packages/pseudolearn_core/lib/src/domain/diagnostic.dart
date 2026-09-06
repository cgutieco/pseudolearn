import 'diagnostic_argument.dart';
import 'diagnostic_code.dart';
import 'severity.dart';
import 'span.dart';

final class Diagnostic {
  final DiagnosticCode code;
  final Severity severity;
  final Span span;
  final List<Span> relatedSpans;
  final Map<String, DiagnosticArgument> arguments;

  Diagnostic({
    required this.code,
    required this.severity,
    required this.span,
    this.relatedSpans = const <Span>[],
    this.arguments = const <String, DiagnosticArgument>{},
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Diagnostic || runtimeType != other.runtimeType) return false;
    if (code != other.code ||
        severity != other.severity ||
        span != other.span) {
      return false;
    }
    if (relatedSpans.length != other.relatedSpans.length) return false;
    for (var index = 0; index < relatedSpans.length; index++) {
      if (relatedSpans[index] != other.relatedSpans[index]) return false;
    }
    if (arguments.length != other.arguments.length) return false;
    for (final entry in arguments.entries) {
      if (other.arguments[entry.key] != entry.value) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    var argumentsHash = 0;
    for (final entry in arguments.entries) {
      argumentsHash = Object.hash(argumentsHash, entry.key, entry.value);
    }
    return Object.hash(
      code,
      severity,
      span,
      Object.hashAll(relatedSpans),
      argumentsHash,
    );
  }

  @override
  String toString() =>
      'Diagnostic($code, $severity, $span, related: $relatedSpans, args: $arguments)';
}
