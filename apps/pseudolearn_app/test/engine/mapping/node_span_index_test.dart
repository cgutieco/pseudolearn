import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/engine/analysis/analysis_cache.dart';
import 'package:pseudolearn_app/engine/mapping/node_span_index.dart';
import 'package:pseudolearn_core/pseudolearn_core.dart';

const _program = '''
Algoritmo Indexado
  Definir x Como Entero
  x <- 1
  Si x > 0 Entonces
    Escribir x
  FinSi
FinAlgoritmo
''';

void main() {
  group('NodeSpanIndex', () {
    test('indexes every node reachable from the unit', () {
      final unit = AnalysisCache().of(_program, SyntaxProfileId.classicSpanish).sourceUnit!;
      final index = NodeSpanIndex.of(unit);

      expect(index.length, greaterThan(unit.algorithm!.body.length));
      expect(index.spanOf(unit.id), isNotNull);
    });

    test('resolves a nested statement to its own span', () {
      final unit = AnalysisCache().of(_program, SyntaxProfileId.classicSpanish).sourceUnit!;
      final index = NodeSpanIndex.of(unit);
      final assignment = unit.algorithm!.body[1];

      final span = index.spanOf(assignment.id);

      expect(span, isNotNull);
      expect(span!.start.line, 3);
    });

    test('an unknown identifier resolves to nothing', () {
      final unit = AnalysisCache().of(_program, SyntaxProfileId.classicSpanish).sourceUnit!;
      final index = NodeSpanIndex.of(unit);

      expect(index.spanOf(const NodeId(999999)), isNull);
    });

    test('the empty index resolves nothing without throwing', () {
      const index = NodeSpanIndex.empty();

      expect(index.length, 0);
      expect(index.spanOf(const NodeId(999999)), isNull);
    });
  });
}
