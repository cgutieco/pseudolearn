import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/diagram/flowchart_layout.dart';

final FlowchartLayout _layout = FlowchartLayout();

const String _factorial = '''
Proceso Factorial
    Definir n Como Entero;
    Definir f Como Entero;
    Definir i Como Entero;
    n <- 5;
    f <- 1;
    Para i <- 1 Hasta n Con Paso 1 Hacer
        f <- f * i;
    FinPara
    Escribir "Factorial: ", f;
FinProceso
''';

DiagramScene _sceneOf(String source, {UiLanguageId language = UiLanguageId.spanish}) {
  return _layout
      .buildDiagram(
        sourceCode: source,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: language,
      )
      .sceneFor(null);
}

String _program(String body) => 'Proceso P\n$body\nFinProceso\n';

Iterable<DiagramNode> _shaped(DiagramScene scene, DiagramShape shape) =>
    scene.nodes.where((node) => node.shape == shape);

Iterable<DiagramEdge> _kinded(DiagramScene scene, DiagramEdgeKind kind) =>
    scene.edges.where((edge) => edge.kind == kind);

bool _hasNodeSaying(DiagramScene scene, String text) =>
    scene.nodes.any((node) => node.lines.join(' ').contains(text));

bool _overlaps(DiagramNode a, DiagramNode b) =>
    a.x < b.x + b.width && b.x < a.x + a.width && a.y < b.y + b.height && b.y < a.y + a.height;

void main() {
  group('the reference factorial program', () {
    final scene = _sceneOf(_factorial);

    test('opens and closes with terminal nodes', () {
      expect(scene.nodes.first.shape, DiagramShape.startEnd);
      expect(scene.nodes.first.lines, ['Inicio']);
      expect(_hasNodeSaying(scene, 'Fin'), isTrue);
    });

    test('shows the loop header as a preparation symbol carrying its range', () {
      final headers = _shaped(scene, DiagramShape.preparation).toList();
      expect(headers, hasLength(1));
      expect(headers.single.lines.join(' '), contains('Hasta n'));
    });

    test('draws the loop body, which the flat layout never reached', () {
      expect(_hasNodeSaying(scene, 'f <- f * i'), isTrue);
    });

    test('closes the loop with exactly one back edge', () {
      expect(_kinded(scene, DiagramEdgeKind.loopBack), hasLength(1));
    });

    test('writes the output statement in an input/output symbol', () {
      final io = _shaped(scene, DiagramShape.inputOutput).toList();
      expect(io, hasLength(1));
      expect(io.single.lines.join(' '), contains('Factorial'));
    });

    test('never labels a node with the name of its family', () {
      expect(_hasNodeSaying(scene, 'Operación'), isFalse);
    });

    test('names every declaration and assignment with its own text', () {
      expect(_hasNodeSaying(scene, 'Definir n Como Entero'), isTrue);
      expect(_hasNodeSaying(scene, 'n <- 5'), isTrue);
      expect(_hasNodeSaying(scene, 'f <- 1'), isTrue);
    });

    test('no two nodes overlap', () {
      for (var first = 0; first < scene.nodes.length; first++) {
        for (var second = first + 1; second < scene.nodes.length; second++) {
          expect(
            _overlaps(scene.nodes[first], scene.nodes[second]),
            isFalse,
            reason: '${scene.nodes[first].id} overlaps ${scene.nodes[second].id}',
          );
        }
      }
    });

    test('every node lies inside the declared canvas', () {
      for (final node in scene.nodes) {
        expect(node.x, greaterThanOrEqualTo(0));
        expect(node.y, greaterThanOrEqualTo(0));
        expect(node.x + node.width, lessThanOrEqualTo(scene.width));
        expect(node.y + node.height, lessThanOrEqualTo(scene.height));
      }
    });
  });

  group('conditional', () {
    test('with an else branch draws two labelled exits and one junction', () {
      final scene = _sceneOf(_program('Si 1 > 2 Entonces\na <- 1;\nSiNo\na <- 2;\nFinSi'));
      expect(_shaped(scene, DiagramShape.decision), hasLength(1));
      expect(_shaped(scene, DiagramShape.connector), hasLength(1));
      expect(_kinded(scene, DiagramEdgeKind.branchTrue), hasLength(1));
      expect(_kinded(scene, DiagramEdgeKind.branchFalse), hasLength(1));
    });

    test('puts the true branch to the left of the false branch', () {
      final scene = _sceneOf(_program('Si 1 > 2 Entonces\na <- 1;\nSiNo\na <- 2;\nFinSi'));
      final trueEdge = _kinded(scene, DiagramEdgeKind.branchTrue).single;
      final falseEdge = _kinded(scene, DiagramEdgeKind.branchFalse).single;
      expect(trueEdge.points.last.x, lessThan(falseEdge.points.last.x));
    });

    test('labels the exits with the interface vocabulary', () {
      final scene = _sceneOf(_program('Si 1 > 2 Entonces\na <- 1;\nFinSi'));
      expect(_kinded(scene, DiagramEdgeKind.branchTrue).single.label, 'SÍ');
      expect(_kinded(scene, DiagramEdgeKind.branchFalse).single.label, 'NO');
    });

    test('without an else branch routes the false exit straight to the junction', () {
      final scene = _sceneOf(_program('Si 1 > 2 Entonces\na <- 1;\nFinSi'));
      final junction = _shaped(scene, DiagramShape.connector).single;
      expect(_kinded(scene, DiagramEdgeKind.branchFalse).single.toId, junction.id);
    });

    test('nested conditionals produce one junction each', () {
      final scene = _sceneOf(_program(
        'Si 1 > 2 Entonces\nSi 3 > 4 Entonces\na <- 1;\nFinSi\nFinSi',
      ));
      expect(_shaped(scene, DiagramShape.connector), hasLength(2));
    });
  });

  group('loops', () {
    test('a while draws its decision above the body with one back edge', () {
      final scene = _sceneOf(_program('Mientras 1 > 2 Hacer\na <- 1;\nFinMientras'));
      final decision = _shaped(scene, DiagramShape.decision).single;
      final body = scene.nodes.firstWhere((node) => node.lines.join().contains('a <- 1'));
      expect(decision.y, lessThan(body.y));
      expect(_kinded(scene, DiagramEdgeKind.loopBack), hasLength(1));
    });

    test('a repeat draws its decision below the body', () {
      final scene = _sceneOf(_program('Repetir\na <- 1;\nHasta Que 1 > 2'));
      final decision = _shaped(scene, DiagramShape.decision).single;
      final body = scene.nodes.firstWhere((node) => node.lines.join().contains('a <- 1'));
      expect(decision.y, greaterThan(body.y));
      expect(_kinded(scene, DiagramEdgeKind.loopBack), hasLength(1));
    });

    test('the back edge of a multi statement body does not cross a node', () {
      final scene = _sceneOf(_program(
        'Mientras 1 > 2 Hacer\na <- 1;\nb <- 2;\nc <- 3;\nFinMientras',
      ));
      final back = _kinded(scene, DiagramEdgeKind.loopBack).single;
      final laneX = back.points[2].x;
      for (final node in scene.nodes) {
        expect(laneX < node.x || laneX > node.x + node.width, isTrue, reason: node.id);
      }
    });

    test('an empty loop body still draws a passing node', () {
      final scene = _sceneOf(_program('Mientras 1 > 2 Hacer\nFinMientras'));
      expect(_kinded(scene, DiagramEdgeKind.loopBack), hasLength(1));
    });

    test('a for loop carries no yes or no label on its preparation symbol', () {
      final scene = _sceneOf(_program('Para i <- 1 Hasta 3 Hacer\na <- 1;\nFinPara'));
      expect(_kinded(scene, DiagramEdgeKind.branchTrue).single.label, isNull);
      expect(_kinded(scene, DiagramEdgeKind.branchFalse).single.label, isNull);
    });
  });

  group('selection', () {
    const source = '''
Proceso P
    Definir opcion Como Entero;
    opcion <- 1;
    Segun opcion Hacer
        1:
            a <- 1;
        2:
            a <- 2;
        3:
            a <- 3;
        De Otro Modo:
            a <- 0;
    FinSegun
FinProceso
''';

    test('draws one labelled exit per case plus the default', () {
      final scene = _sceneOf(source);
      final caseEdges = _kinded(scene, DiagramEdgeKind.branchCase).toList();
      expect(caseEdges, hasLength(4));
      expect(caseEdges.last.label, 'De Otro Modo');
    });

    test('converges every case into a single junction', () {
      final scene = _sceneOf(source);
      expect(_shaped(scene, DiagramShape.connector), hasLength(1));
    });
  });

  group('subprograms', () {
    test('a call uses the predefined process symbol', () {
      const source = '''
SubProceso saludar(x)
    Escribir x;
FinSubProceso

Proceso P
    saludar(1);
FinProceso
''';
      final scene = _sceneOf(source);
      expect(_shaped(scene, DiagramShape.subprogram), hasLength(1));
    });
  });

  group('edge cases', () {
    test('a program with no statements is a minimal, non empty diagram', () {
      final scene = _sceneOf('Proceso P\nFinProceso\n');
      expect(scene.nodes, hasLength(2));
      expect(scene.edges, hasLength(1));
    });

    test('a program that does not parse yields no scene', () {
      final scene = _sceneOf('Proceso Bad Si 1 > 2 FinProceso');
      expect(scene.nodes, isEmpty);
      expect(scene.edges, isEmpty);
    });

    test('deep nesting grows the scene instead of dropping statements', () {
      final scene = _sceneOf(_program(
        'Para i <- 1 Hasta 3 Hacer\n'
        'Mientras 1 > 2 Hacer\n'
        'Si 3 > 4 Entonces\n'
        'a <- 1;\n'
        'FinSi\n'
        'FinMientras\n'
        'FinPara',
      ));
      expect(_hasNodeSaying(scene, 'a <- 1'), isTrue);
      expect(_kinded(scene, DiagramEdgeKind.loopBack), hasLength(2));
    });

    test('every edge carries at least two points', () {
      final scene = _sceneOf(_factorial);
      for (final edge in scene.edges) {
        expect(edge.points.length, greaterThanOrEqualTo(2));
      }
    });

    test('the same program yields the same scene twice', () {
      final first = _sceneOf(_factorial);
      final second = _sceneOf(_factorial);
      expect(first.width, second.width);
      expect(first.height, second.height);
      for (var index = 0; index < first.nodes.length; index++) {
        expect(first.nodes[index].id, second.nodes[index].id);
        expect(first.nodes[index].x, second.nodes[index].x);
        expect(first.nodes[index].y, second.nodes[index].y);
        expect(first.nodes[index].lines, second.nodes[index].lines);
      }
    });

    test('the interface language changes the terminal wording', () {
      final english = _sceneOf(_factorial, language: UiLanguageId.english);
      expect(english.nodes.first.lines, ['Start']);
    });
  });
}
