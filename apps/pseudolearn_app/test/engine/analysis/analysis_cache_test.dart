import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/engine/analysis/analysis_cache.dart';

const _valid = '''
Algoritmo Valido
  Definir x Como Entero
  x <- 1
FinAlgoritmo
''';

const _invalid = '''
Algoritmo Invalido
  x <-
FinAlgoritmo
''';

void main() {
  group('AnalysisCache', () {
    test('the same source and profile yield the very same analysis', () {
      final cache = AnalysisCache();

      final first = cache.of(_valid, SyntaxProfileId.classicSpanish);
      final second = cache.of(_valid, SyntaxProfileId.classicSpanish);

      expect(identical(first, second), isTrue);
    });

    test('node identity is shared, which is what the cache exists for', () {
      final cache = AnalysisCache();

      final statements = cache.of(_valid, SyntaxProfileId.classicSpanish).sourceUnit!.algorithm!.body;
      final again = cache.of(_valid, SyntaxProfileId.classicSpanish).sourceUnit!.algorithm!.body;

      expect(statements.first.id, again.first.id);
      expect(identical(statements.first, again.first), isTrue);
    });

    test('a different source re-analyses', () {
      final cache = AnalysisCache();

      final first = cache.of(_valid, SyntaxProfileId.classicSpanish);
      final second = cache.of('$_valid\n', SyntaxProfileId.classicSpanish);

      expect(identical(first, second), isFalse);
    });

    test('a different profile re-analyses', () {
      final cache = AnalysisCache();

      final first = cache.of(_valid, SyntaxProfileId.classicSpanish);
      final second = cache.of(_valid, SyntaxProfileId.english);

      expect(identical(first, second), isFalse);
    });

    test('a source with syntax errors has no unit and is not executable', () {
      final analysis = AnalysisCache().of(_invalid, SyntaxProfileId.classicSpanish);

      expect(analysis.sourceUnit, isNull);
      expect(analysis.isExecutable, isFalse);
      expect(analysis.executableProgram, isNull);
      expect(analysis.diagnostics, isNotEmpty);
    });

    test('an empty source analyses without throwing', () {
      final analysis = AnalysisCache().of('', SyntaxProfileId.classicSpanish);

      expect(analysis.isExecutable, isFalse);
      expect(analysis.tokens, isNotEmpty);
    });

    test('a valid source is executable and yields a program', () {
      final analysis = AnalysisCache().of(_valid, SyntaxProfileId.classicSpanish);

      expect(analysis.isExecutable, isTrue);
      expect(analysis.executableProgram, isNotNull);
    });
  });
}
