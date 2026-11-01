import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';

import '../../fakes/native_test_engine.dart';
import '../classdiagram/diagram_scene_validators.dart';

const String _contractOnly = '''
interface Readable
method readValue() as integer;
endInterface
algorithm Main
endAlgorithm
''';

const String _oneRealization = '''
interface Readable
method readValue() as integer;
endInterface
class Reader implements Readable
method readValue() as integer
return 7;
endMethod
endClass
algorithm Main
endAlgorithm
''';

const String _twoRealizations = '''
interface Readable
method readValue() as integer;
endInterface
class Reader implements Readable
method readValue() as integer
return 7;
endMethod
endClass
class Writer implements Readable
method readValue() as integer
return 8;
endMethod
endClass
algorithm Main
endAlgorithm
''';

const String _twoContracts = '''
interface Readable
method readValue() as integer;
endInterface
interface Closable
method close();
endInterface
class File implements Readable, Closable
method readValue() as integer
return 1;
endMethod
method close()
endMethod
endClass
algorithm Main
endAlgorithm
''';

const String _inheritanceAndRealization = '''
interface Readable
method readValue() as integer;
endInterface
class Reader implements Readable
method readValue() as integer
return 7;
endMethod
endClass
class Child extends Reader
endClass
algorithm Main
endAlgorithm
''';

const String _missingMethod = '''
interface Needed
method run() as integer;
endInterface
class Broken implements Needed
endClass
algorithm Main
endAlgorithm
''';

const String _unknownTarget = '''
class Missing implements Absent
endClass
algorithm Main
endAlgorithm
''';

const String _constraint = '''
interface Readable
method readValue() as integer;
endInterface
subroutine readOnce<T: Readable>(value as T) as integer
return value.readValue();
endSubroutine
algorithm Main
endAlgorithm
''';

const String _spanishRealization = '''
Interfaz Legible
Metodo obtener() Como Entero;
FinInterfaz
Clase Lector Realiza Legible
Metodo obtener() Como Entero
Retornar 1;
FinMetodo
FinClase
Algoritmo Principal
FinAlgoritmo
''';

DiagramScene _sceneOf(
  String source, {
  SyntaxProfileId profile = SyntaxProfileId.english,
}) => nativeTestEngine.classDiagramBuilder.buildDiagram(
  sourceCode: source,
  profileId: profile,
);

List<DiagramNode> _headers(DiagramScene scene) => [
  for (final node in scene.nodes)
    if (node.shape == DiagramShape.classHeader) node,
];

List<DiagramEdge> _edges(DiagramScene scene, DiagramEdgeKind kind) => [
  for (final edge in scene.edges)
    if (edge.kind == kind) edge,
];

DiagramNode _frameOf(DiagramScene scene, String id) =>
    scene.nodes.firstWhere((node) => node.id == id);

void main() {
  group('interface contracts in the class diagram', () {
    test('a contract without implementations stays visible with its operations', () {
      final scene = _sceneOf(_contractOnly);

      expect(_headers(scene).single.lines, ['«interface»', 'Readable']);
      expect(scene.edges, isEmpty);
      final rows = [
        for (final node in scene.nodes)
          if (node.shape == DiagramShape.classRow) node.lines.single,
      ];
      expect(rows, ['+ readValue(): integer']);
    });

    test('one realization is a dashed relation ending at the contract', () {
      final scene = _sceneOf(_oneRealization);

      final edge = _edges(scene, DiagramEdgeKind.realization).single;
      final contract = _frameOf(scene, edge.toId);
      final implementation = _frameOf(scene, edge.fromId);
      expect(edge.isValid, isTrue);
      expect(edge.points.last.y, contract.y + contract.height);
      expect(edge.points.first.y, implementation.y);
      expect(contract.y, lessThan(implementation.y));
      expect(_edges(scene, DiagramEdgeKind.generalization), isEmpty);
    });

    test('two implementations realize the same contract', () {
      final scene = _sceneOf(_twoRealizations);

      final edges = _edges(scene, DiagramEdgeKind.realization);
      expect(edges, hasLength(2));
      expect({for (final edge in edges) edge.toId}, hasLength(1));
      expect({for (final edge in edges) edge.fromId}, hasLength(2));
    });

    test('a class implementing two contracts draws one relation per contract', () {
      final scene = _sceneOf(_twoContracts);

      final edges = _edges(scene, DiagramEdgeKind.realization);
      expect(edges, hasLength(2));
      expect({for (final edge in edges) edge.fromId}, hasLength(1));
      expect({for (final edge in edges) edge.toId}, hasLength(2));
    });

    test('inheritance stays continuous and inherited realization is not redrawn', () {
      final scene = _sceneOf(_inheritanceAndRealization);

      expect(_edges(scene, DiagramEdgeKind.generalization), hasLength(1));
      expect(_edges(scene, DiagramEdgeKind.realization), hasLength(1));
    });

    test('an incomplete implementation is an invalid relation with diagnostic and origin', () {
      final scene = _sceneOf(_missingMethod);

      final edge = _edges(scene, DiagramEdgeKind.realization).single;
      expect(edge.isValid, isFalse);
      expect(edge.diagnostics, ['interfaceMethodMissing']);
      expect(edge.label, startsWith('!'));
      expect(edge.originNodeId, isNotNull);
    });

    test('an unknown contract is a navigable issue row, never a relation', () {
      final scene = _sceneOf(_unknownTarget);

      expect(scene.edges, isEmpty);
      final issue = scene.nodes.firstWhere(
        (node) =>
            node.shape == DiagramShape.classRow &&
            node.lines.single.startsWith('!'),
      );
      expect(issue.lines.single, contains('Absent'));
      expect(issue.lines.single, contains('unknownInterface'));
      expect(issue.nodeId, isNotNull);
      expect(issue.sourceLine, 1);
    });

    test('a generic constraint draws a usage relation from the subprogram', () {
      final scene = _sceneOf(_constraint);

      final edge = _edges(scene, DiagramEdgeKind.usage).single;
      expect(edge.isValid, isTrue);
      expect(edge.label, 'T');
      expect(_headers(scene).map((node) => node.lines.first), contains('«subprogram»'));
      final signature = scene.nodes.lastWhere((node) => node.shape == DiagramShape.classRow);
      expect(signature.lines.single, '+ readOnce<T: Readable>(value: T): integer');
    });

    test('contract scenes keep boxes, lines and text clear of each other', () {
      for (final source in [_twoRealizations, _twoContracts, _missingMethod, _constraint]) {
        final scene = _sceneOf(source);

        expect(countLineBoxCrossings(scene), 0, reason: "crossings");
        expect(countTotalLabelCollisions(scene), 0, reason: "labels");
      }
    });

    test('the Spanish profile projects the same contract relation', () {
      final scene = _sceneOf(
        _spanishRealization,
        profile: SyntaxProfileId.classicSpanish,
      );

      expect(_edges(scene, DiagramEdgeKind.realization), hasLength(1));
      expect(_headers(scene).first.lines.first, '«interface»');
    });

    test('a source that does not parse produces no contract boxes', () {
      expect(_sceneOf('interface').isEmpty, isTrue);
    });
  });
}
