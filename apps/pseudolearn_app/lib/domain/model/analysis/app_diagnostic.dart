import 'source_range.dart';

enum AppSeverity {
  error,
  warning,
  info,
  hint,
  success,
}

final class RelatedRange {
  final String label;
  final SourceRange range;

  const RelatedRange({
    required this.label,
    required this.range,
  });
}

final class AppDiagnostic {
  final String code;
  final String message;
  final AppSeverity severity;
  final SourceRange primaryRange;
  final List<RelatedRange> relatedRanges;

  const AppDiagnostic({
    required this.code,
    required this.message,
    required this.severity,
    required this.primaryRange,
    this.relatedRanges = const [],
  });
}
