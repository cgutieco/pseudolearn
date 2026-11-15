import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_program.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';

import '../../fakes/native_test_engine.dart';

const String _nestedBreak = '''
algorithm Main
define values as vector<integer> <- vector();
for each outer in values do
for each inner in values do
defer
write inner;
endDefer
break;
endFor
write outer;
endFor
endAlgorithm
''';

const String _plainBreak = '''
Algoritmo Main
Definir values Como Vector<Entero> <- Vector();
Para Cada value En values Hacer
Salir;
FinPara
FinAlgoritmo
''';

const String _orphanBreak = '''
Algoritmo Main
Salir;
FinAlgoritmo
''';

const String _cleanups = '''
algorithm Main
defer
write 1;
endDefer
defer
endDefer
write 3;
endAlgorithm
''';

const String _returns = '''
subroutine Pick(flag as boolean) as integer
defer
write 0;
endDefer
if flag then
return 1;
else
return 2;
endIf
endSubroutine
subroutine Plain() as integer
return 5;
endSubroutine
algorithm Main
endAlgorithm
''';

const String _propagation = '''
SubProceso First() Como Resultado<Entero, Cadena>
Retornar Error("fallo");
FinSubProceso
SubProceso Second() Como Resultado<Entero, Cadena>
Definir value Como Entero <- Propagar First();
Retornar Exito(value + 1);
FinSubProceso
Algoritmo Main
FinAlgoritmo
''';

DiagramProgram _flowchart(String source, {bool english = true}) =>
    nativeTestEngine.flowchartBuilder.buildDiagram(
      sourceCode: source,
      profileId: english
          ? SyntaxProfileId.english
          : SyntaxProfileId.classicSpanish,
      languageId: english ? UiLanguageId.english : UiLanguageId.spanish,
    );

DiagramProgram _structogram(String source, {bool english = true}) =>
    nativeTestEngine.structogramBuilder.buildDiagram(
      sourceCode: source,
      profileId: english
          ? SyntaxProfileId.english
          : SyntaxProfileId.classicSpanish,
      languageId: english ? UiLanguageId.english : UiLanguageId.spanish,
    );

DiagramScene _scene(DiagramProgram program, String unit) => program.sceneFor(
  program.units.singleWhere((candidate) => candidate.name == unit).id,
);

List<String> _texts(DiagramScene scene, DiagramShape shape) => [
  for (final node in scene.nodes)
    if (node.shape == shape) node.lines.join(' '),
];

DiagramNode _node(DiagramScene scene, String id) =>
    scene.nodes.singleWhere((node) => node.id == id);

bool _overlaps(DiagramNode first, DiagramNode second) =>
    first.x < second.x + second.width &&
    second.x < first.x + first.width &&
    first.y < second.y + second.height &&
    second.y < first.y + first.height;

void main() {
  group('a break leaves through a paired loop end connector', () {
    test('the break reaches the connector of its inner loop only', () {
      final scene = _scene(_flowchart(_nestedBreak), 'Main');

      expect(_texts(scene, DiagramShape.exitConnector), [
        'Loop end (line 4)',
        'Loop end (line 4)',
      ]);
      final breakEdge = scene.edges.singleWhere(
        (edge) => edge.kind == DiagramEdgeKind.breakExit,
      );
      expect(_node(scene, breakEdge.fromId).lines.join(' '), 'break — cleanups: line 5');
      expect(_node(scene, breakEdge.toId).shape, DiagramShape.exitConnector);
    });

    test('a break without pending cleanups keeps its own caption', () {
      final scene = _scene(_flowchart(_plainBreak, english: false), 'Main');

      expect(_texts(scene, DiagramShape.process), contains('Salir'));
      expect(_texts(scene, DiagramShape.exitConnector), [
        'Fin del bucle (línea 3)',
        'Fin del bucle (línea 3)',
      ]);
    });

    test('a loop whose body always breaks draws no back edge', () {
      final scene = _scene(_flowchart(_plainBreak, english: false), 'Main');

      expect(
        scene.edges.where((edge) => edge.kind == DiagramEdgeKind.loopBack),
        isEmpty,
      );
    });

    test('a break outside a loop has no connector and no exit edge', () {
      final scene = _scene(_flowchart(_orphanBreak, english: false), 'Main');

      expect(_texts(scene, DiagramShape.exitConnector), isEmpty);
      expect(
        scene.edges.where((edge) => edge.kind == DiagramEdgeKind.breakExit),
        isEmpty,
      );
    });

    test('the structogram marks the break as an exit cell with its cleanups', () {
      final scene = _scene(_structogram(_nestedBreak), 'Main');

      expect(_texts(scene, DiagramShape.cellExit), ['break — cleanups: line 5']);
    });
  });

  group('a deferred body is drawn beside its registration', () {
    test('the registration links to its body without entering the flow', () {
      final scene = _scene(_flowchart(_cleanups), 'Main');
      final links = scene.edges
          .where((edge) => edge.kind == DiagramEdgeKind.cleanupRegistration)
          .toList();

      expect(links, hasLength(2));
      expect(_node(scene, links.first.toId).lines.join(' '), 'write 1');
      expect(_node(scene, links.last.toId).shape, DiagramShape.connector);
      expect(
        scene.edges.where(
          (edge) =>
              edge.kind == DiagramEdgeKind.normal &&
              edge.toId == links.first.toId,
        ),
        isEmpty,
      );
    });

    test('the normal end runs the cleanups in reverse registration', () {
      final scene = _scene(_flowchart(_cleanups), 'Main');

      expect(_texts(scene, DiagramShape.subprogram), [
        'Cleanups at end: lines 5, 2',
      ]);
    });

    test('side bodies never overlap the main flow', () {
      final scene = _scene(_flowchart(_cleanups), 'Main');

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

    test('the structogram nests the body under a header and ends with the cleanups', () {
      final scene = _scene(_structogram(_cleanups), 'Main');

      expect(_texts(scene, DiagramShape.cellLoopHeader), ['defer', 'defer']);
      expect(_texts(scene, DiagramShape.cellCall), [
        'Cleanups at end: lines 5, 2',
      ]);
    });
  });

  group('returns and propagations name the cleanups that run first', () {
    test('each return of a scope with cleanups lists them', () {
      final scene = _scene(_flowchart(_returns), 'Pick');

      expect(_texts(scene, DiagramShape.startEnd), [
        'Start',
        'return 1 — cleanups: line 2',
        'return 2 — cleanups: line 2',
        'End',
      ]);
    });

    test('an unreachable normal end draws no cleanup step', () {
      expect(_texts(_scene(_flowchart(_returns), 'Pick'), DiagramShape.subprogram), isEmpty);
      expect(_texts(_scene(_structogram(_returns), 'Pick'), DiagramShape.cellCall), isEmpty);
    });

    test('a return without cleanups is unchanged', () {
      expect(_texts(_scene(_flowchart(_returns), 'Plain'), DiagramShape.startEnd), [
        'Start',
        'return 5',
        'End',
      ]);
    });

    test('a propagation adds a side exit and keeps the normal flow', () {
      final scene = _scene(_flowchart(_propagation, english: false), 'Second');
      final exit = scene.edges.singleWhere(
        (edge) => edge.kind == DiagramEdgeKind.propagationExit,
      );

      expect(_node(scene, exit.fromId).lines.join(' '), 'Definir value Como Entero <- Propagar First()');
      expect(_node(scene, exit.toId).lines.join(' '), 'Propaga el fallo');
      expect(
        scene.edges.where((edge) => edge.fromId == exit.fromId),
        hasLength(2),
      );
    });

    test('the structogram annotates the propagating statement', () {
      final scene = _scene(_structogram(_propagation, english: false), 'Second');

      expect(
        _texts(scene, DiagramShape.cellProcess),
        contains('Definir value Como Entero <- Propagar First() — si falla, propaga'),
      );
    });
  });
}
