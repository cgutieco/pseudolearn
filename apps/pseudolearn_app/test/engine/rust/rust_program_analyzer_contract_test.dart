import '../../fakes/native_test_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/app_diagnostic.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';

void main() {
  group('RustProgramAnalyzer', () {
    final analyzer = nativeTestEngine.analyzer;

    test('analyzes valid program successfully', () {
      const source = '''
Algoritmo Test
  Definir Mutable x Como Entero <- 0
  x <- 42
  Escribir x
FinAlgoritmo
''';
      final report = analyzer.analyze(
        sourceCode: source,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      expect(report.isExecutable, isTrue);
      expect(report.hasErrors, isFalse);
      expect(report.highlightSpans, isNotEmpty);
    });

    test('reports syntax errors and marks isExecutable false', () {
      const badSource = '''
Algoritmo Test
  Si 5 > 3
FinAlgoritmo
''';
      final report = analyzer.analyze(
        sourceCode: badSource,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      expect(report.isExecutable, isFalse);
      expect(report.hasErrors, isTrue);
      expect(
        report.diagnostics.any((d) => d.severity == AppSeverity.error),
        isTrue,
      );
    });
  });
}
