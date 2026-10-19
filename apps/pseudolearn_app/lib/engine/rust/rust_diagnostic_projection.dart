import '../../domain/model/analysis/app_diagnostic.dart';
import '../../domain/model/analysis/source_range.dart';
import 'rust_related_label.dart';
import 'source_offset_index.dart';

final class RustDiagnosticProjection {
  final SourceOffsetIndex _offsets;
  final String _profile;

  const RustDiagnosticProjection(this._offsets, this._profile);

  AppDiagnostic project(Map<String, Object?> diagnostic) {
    return AppDiagnostic(
      code: diagnostic['code'] as String,
      message: diagnostic['message'] as String,
      severity: _severityOf(diagnostic['severity'] as String),
      primaryRange: _rangeOf(diagnostic['span'] as Map<String, Object?>),
      relatedRanges: [
        for (final related in diagnostic['related'] as List<Object?>)
          _relatedOf(related as Map<String, Object?>),
      ],
    );
  }

  RelatedRange _relatedOf(Map<String, Object?> span) {
    final start = span['start'] as Map<String, Object?>;
    return RelatedRange(
      label: relatedLocationLabel(
        profile: _profile,
        line: start['line'] as int,
        column: start['column'] as int,
      ),
      range: _rangeOf(span),
    );
  }

  SourceRange _rangeOf(Map<String, Object?> span) {
    final start = span['start'] as Map<String, Object?>;
    final end = span['end'] as Map<String, Object?>;
    return _offsets.rangeOf(
      startLine: start['line'] as int,
      startColumn: start['column'] as int,
      endLine: end['line'] as int,
      endColumn: end['column'] as int,
    );
  }

  AppSeverity _severityOf(String severity) => switch (severity) {
    'error' => AppSeverity.error,
    'warning' => AppSeverity.warning,
    _ => AppSeverity.info,
  };
}
