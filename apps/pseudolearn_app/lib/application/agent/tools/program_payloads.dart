import '../../../domain/model/analysis/analysis_report.dart';
import '../../../domain/model/documents/document.dart';

Map<String, Object?> diagnosticsPayload(AnalysisReport report) => {
  'executable': report.isExecutable && !report.hasErrors,
  'diagnostics': [
    for (final diagnostic in report.diagnostics)
      {
        'code': diagnostic.code,
        'severity': diagnostic.severity.name,
        'message': diagnostic.message,
        'line': diagnostic.primaryRange.startLine,
        'column': diagnostic.primaryRange.startColumn,
        'offset': diagnostic.primaryRange.startOffset,
      },
  ],
};

Map<String, Object?> summaryPayload(DocumentSummary summary) => {
  'id': summary.id,
  'title': summary.title,
  'profile': summary.profileId.name,
  'revision': summary.revision,
  'exercise': summary.exerciseId,
  'updated_at': summary.updatedAt.toIso8601String(),
};

Map<String, Object?> documentPayload(Document document) => {
  ...summaryPayload(document.toSummary()),
  'arguments': document.executionArguments,
  'content': document.content,
};
