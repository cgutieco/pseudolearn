import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/app_diagnostic.dart';
import 'package:pseudolearn_app/engine/rust/rust_diagnostic_projection.dart';
import 'package:pseudolearn_app/engine/rust/source_offset_index.dart';

Map<String, Object?> span(int line, int column, int endColumn) => {
  'start': {'line': line, 'column': column},
  'end': {'line': line, 'column': endColumn},
};

void main() {
  final projection = RustDiagnosticProjection(
    SourceOffsetIndex('a\nbcd\n'),
    'es',
  );

  group('RustDiagnosticProjection', () {
    test('keeps code, message, severity and range', () {
      final diagnostic = projection.project({
        'code': 'unrecognizedCharacter',
        'message': 'm',
        'severity': 'warning',
        'span': span(2, 1, 3),
        'arguments': {'lexeme': '@'},
        'related': <Object?>[],
      });
      expect(diagnostic.arguments, {'lexeme': '@'});
      expect(diagnostic.code, 'unrecognizedCharacter');
      expect(diagnostic.severity, AppSeverity.warning);
      expect(diagnostic.primaryRange.startOffset, 2);
      expect(diagnostic.primaryRange.endOffset, 4);
    });

    test('labels related ranges in the profile language', () {
      final related = projection.project({
        'code': 'c',
        'message': 'm',
        'severity': 'error',
        'span': span(1, 1, 2),
        'related': [span(2, 2, 3)],
      }).relatedRanges;
      expect(related.single.label, contains('línea 2'));
      final english =
          RustDiagnosticProjection(SourceOffsetIndex('a\nbcd\n'), 'en').project(
            {
              'code': 'c',
              'message': 'm',
              'severity': 'error',
              'span': span(1, 1, 2),
              'related': [span(2, 2, 3)],
            },
          );
      expect(english.relatedRanges.single.label, contains('line 2'));
    });

    test('maps unknown severities to information', () {
      final diagnostic = projection.project({
        'code': 'c',
        'message': 'm',
        'severity': 'other',
        'span': span(1, 1, 1),
        'related': <Object?>[],
      });
      expect(diagnostic.severity, AppSeverity.info);
    });
  });
}
