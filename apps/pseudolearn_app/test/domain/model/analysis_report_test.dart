import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/analysis_report.dart';
import 'package:pseudolearn_app/domain/model/analysis/app_diagnostic.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';

void main() {
  group('AnalysisReport Domain Model', () {
    test('empty report is executable with no errors', () {
      const report = AnalysisReport.empty();
      expect(report.isExecutable, isTrue);
      expect(report.hasErrors, isFalse);
      expect(report.diagnostics, isEmpty);
      expect(report.highlightSpans, isEmpty);
    });

    test('report with error diagnostic reports hasErrors true', () {
      const diagnostic = AppDiagnostic(
        code: 'syntax_error',
        message: 'Syntax error',
        severity: AppSeverity.error,
        primaryRange: SourceRange(
          startOffset: 0,
          endOffset: 5,
          startLine: 1,
          startColumn: 1,
          endLine: 1,
          endColumn: 6,
        ),
      );
      const report = AnalysisReport(
        isExecutable: false,
        diagnostics: [diagnostic],
        highlightSpans: [],
      );

      expect(report.isExecutable, isFalse);
      expect(report.hasErrors, isTrue);
    });
  });
}
