import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/app_diagnostic.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_notation.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_block.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_marker.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_marker_kind.dart';

void main() {
  group('ContentBlock value equality', () {
    test('two diagram blocks with the same program and notation are equal', () {
      const one = DiagramBlock(code: 'Proceso P\nFinProceso', notation: DiagramNotation.flowchart);
      const other = DiagramBlock(code: 'Proceso P\nFinProceso', notation: DiagramNotation.flowchart);

      expect(one, other);
      expect(one.hashCode, other.hashCode);
    });

    test('the same program under another notation is another block', () {
      const flowchart = DiagramBlock(code: 'Proceso P\nFinProceso', notation: DiagramNotation.flowchart);
      const structogram = DiagramBlock(code: 'Proceso P\nFinProceso', notation: DiagramNotation.structogram);

      expect(flowchart, isNot(structogram));
    });

    test('the resolved scene is a cached rendering artifact, not part of identity', () {
      const unresolved = DiagramBlock(code: 'Proceso P\nFinProceso', notation: DiagramNotation.flowchart);
      const resolved = DiagramBlock(
        code: 'Proceso P\nFinProceso',
        notation: DiagramNotation.flowchart,
        scene: DiagramScene(nodes: [
          DiagramNode(id: 'n1', shape: DiagramShape.startEnd, lines: ['Inicio'], x: 0, y: 0, width: 10, height: 10),
        ], edges: [], width: 10, height: 10),
      );

      expect(unresolved, resolved);
      expect(unresolved.hashCode, resolved.hashCode);
      expect(resolved.scene.isNotEmpty, isTrue);
    });

    test('figure blocks compare by illustration and caption', () {
      const one = FigureBlock(illustrationId: 'memory-boxes', caption: 'Cajas');
      const same = FigureBlock(illustrationId: 'memory-boxes', caption: 'Cajas');
      const other = FigureBlock(illustrationId: 'memory-boxes', caption: 'Casillas');

      expect(one, same);
      expect(one, isNot(other));
    });

    test('marker blocks compare by marker and resolved text', () {
      const marker = ContentMarker(kind: ContentMarkerKind.lexeme, argument: 'mientras');
      const one = MarkerBlock(marker: marker, resolvedText: 'Mientras');
      const same = MarkerBlock(marker: marker, resolvedText: 'Mientras');
      const other = MarkerBlock(marker: marker, resolvedText: 'While');

      expect(one, same);
      expect(one, isNot(other));
    });

    test('table blocks compare row by row', () {
      const one = TableBlock(headers: ['Tipo'], rows: [['entero'], ['real']]);
      const same = TableBlock(headers: ['Tipo'], rows: [['entero'], ['real']]);
      const swapped = TableBlock(headers: ['Tipo'], rows: [['real'], ['entero']]);
      const shorter = TableBlock(headers: ['Tipo'], rows: [['entero']]);

      expect(one, same);
      expect(one, isNot(swapped));
      expect(one, isNot(shorter));
    });

    test('an empty table and an empty list block are their own values', () {
      const emptyTable = TableBlock(headers: [], rows: []);
      const emptyList = ListBlock(items: []);

      expect(emptyTable, const TableBlock(headers: [], rows: []));
      expect(emptyList, const ListBlock(items: []));
    });

    test('a marker renders its own source text', () {
      const marker = ContentMarker(kind: ContentMarkerKind.table, argument: 'precedencia');

      expect(marker.text, '{{tabla:precedencia}}');
    });

    test('diagnostic blocks compare by code, message, and severity', () {
      const one = DiagnosticBlock(
        code: 'expectedAlgorithmStart',
        message: 'Se esperaba el inicio del algoritmo',
        severity: AppSeverity.error,
      );
      const same = DiagnosticBlock(
        code: 'expectedAlgorithmStart',
        message: 'Se esperaba el inicio del algoritmo',
        severity: AppSeverity.error,
      );
      const differentMessage = DiagnosticBlock(
        code: 'expectedAlgorithmStart',
        message: 'Expected algorithm start',
        severity: AppSeverity.error,
      );
      const differentSeverity = DiagnosticBlock(
        code: 'expectedAlgorithmStart',
        message: 'Se esperaba el inicio del algoritmo',
        severity: AppSeverity.warning,
      );

      expect(one, same);
      expect(one.hashCode, same.hashCode);
      expect(one, isNot(differentMessage));
      expect(one, isNot(differentSeverity));
    });

    test('two blocks of different variants with the same text are not equal', () {
      const paragraph = ParagraphBlock(text: 'x');
      const quote = QuoteBlock(text: 'x');

      expect(paragraph, isNot(quote));
    });
  });
}
