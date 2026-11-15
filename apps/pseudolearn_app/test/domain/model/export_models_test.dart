import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/export/export_result.dart';
import 'package:pseudolearn_app/domain/model/export/exported_program.dart';
import 'package:pseudolearn_app/domain/model/export/target_language_id.dart';

void main() {
  group('TargetLanguageId Domain Model', () {
    test('resolves known language ids correctly', () {
      expect(TargetLanguageId.fromId('python'), equals(TargetLanguageId.python));
      expect(TargetLanguageId.fromId('rust'), equals(TargetLanguageId.rust));
      expect(TargetLanguageId.fromId('unknown'), equals(TargetLanguageId.python));
    });

    test('exposes correct display names', () {
      expect(TargetLanguageId.python.displayName, equals('Python'));
      expect(TargetLanguageId.rust.displayName, equals('Rust'));
    });
  });

  group('ExportResult & ExportedProgram Domain Models', () {
    test('ExportSuccess contains exported program and supports value equality', () {
      const program1 = ExportedProgram(
        targetLanguage: TargetLanguageId.python,
        sourceCode: 'print("hello")',
        notes: ['Note 1'],
      );
      const program2 = ExportedProgram(
        targetLanguage: TargetLanguageId.python,
        sourceCode: 'print("hello")',
        notes: ['Note 1'],
      );

      expect(program1, equals(program2));
      expect(const ExportSuccess(program1), equals(const ExportSuccess(program2)));
    });

    test('ExportUnavailable and ExportAnalysisError support value equality', () {
      expect(
        const ExportUnavailable('Engine not available'),
        equals(const ExportUnavailable('Engine not available')),
      );
      expect(
        const ExportAnalysisError(),
        equals(const ExportAnalysisError()),
      );
    });
  });
}
