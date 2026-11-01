import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_view_source.dart';

import '../../fakes/native_test_engine.dart';
import '../classdiagram/diagram_scene_validators.dart';

const String _valueTypes = '''
Enumerado Color
Rojo, Verde
FinEnumerado
Registro Punto
Definir x, z Como Entero;
FinRegistro
SubProceso identity<T>(value Como T) Como T
Retornar value;
FinSubProceso
Algoritmo Main
FinAlgoritmo
''';

const String _enumOnly = '''
enum Level
low, high
endEnum
algorithm Main
endAlgorithm
''';

const String _plainSubprogram = '''
subroutine twice(value as integer) as integer
return value * 2;
endSubroutine
algorithm Main
endAlgorithm
''';

DiagramScene _sceneOf(
  String source, {
  SyntaxProfileId profile = SyntaxProfileId.classicSpanish,
}) => nativeTestEngine.classDiagramBuilder.buildDiagram(
  sourceCode: source,
  profileId: profile,
);

List<DiagramNode> _headers(DiagramScene scene) => [
  for (final node in scene.nodes)
    if (node.shape == DiagramShape.classHeader) node,
];

List<DiagramNode> _rowsOf(DiagramScene scene, DiagramNode header) => [
  for (final node in scene.nodes)
    if (node.shape == DiagramShape.classRow &&
        node.id.startsWith('${header.id.replaceFirst('_header', '')}_'))
      node,
];

DiagramNode _header(DiagramScene scene, String name) =>
    _headers(scene).singleWhere((node) => node.lines.last == name);

void main() {
  group('value types and type parameters are visible boxes', () {
    test('records, enumerations and generic subprograms carry stereotypes', () {
      final scene = _sceneOf(_valueTypes);

      expect([for (final header in _headers(scene)) header.lines], [
        ['«enumeration»', 'Color'],
        ['«record»', 'Punto'],
        ['«subprogram»', 'identity'],
      ]);
      expect(scene.edges, isEmpty);
    });

    test('an enumeration lists its members without visibility', () {
      final scene = _sceneOf(_valueTypes);

      expect(
        [for (final row in _rowsOf(scene, _header(scene, 'Color'))) row.lines.single],
        ['Rojo', 'Verde'],
      );
    });

    test('a record lists one typed row per declared field', () {
      final scene = _sceneOf(_valueTypes);

      expect(
        [for (final row in _rowsOf(scene, _header(scene, 'Punto'))) row.lines.single],
        ['+ x: Entero', '+ z: Entero'],
      );
    });

    test('a generic subprogram without constraints shows its type parameter', () {
      final scene = _sceneOf(_valueTypes);

      expect(
        _rowsOf(scene, _header(scene, 'identity')).single.lines.single,
        '+ identity<T>(value: T): T',
      );
    });

    test('a document with only an enumeration still has a diagram', () {
      final scene = _sceneOf(_enumOnly, profile: SyntaxProfileId.english);

      expect(_headers(scene).single.lines, ['«enumeration»', 'Level']);
    });

    test('a subprogram without type parameters gets no box', () {
      expect(_sceneOf(_plainSubprogram, profile: SyntaxProfileId.english).isEmpty, isTrue);
    });

    test('the boxes keep a valid geometry', () {
      final scene = _sceneOf(_valueTypes);

      expectZeroEllipsizedTexts(scene);
      expectZeroOverlappingLabels(scene);
    });
  });

  group('every row navigates to its own declaration', () {
    test('rows carry the node of the member or field they show', () {
      final scene = _sceneOf(_valueTypes);
      final view = RustProgramViewSource(testTransport).loadStructure(
        sourceCode: _valueTypes,
        profileId: SyntaxProfileId.classicSpanish,
      )!;
      for (final name in ['Color', 'Punto']) {
        for (final row in _rowsOf(scene, _header(scene, name))) {
          final declared = view.nodeById(row.nodeId!)!;
          expect(row.lines.single, contains(declared.text));
          expect(row.sourceLine, declared.range.startLine);
        }
      }
    });

    test('the header of a value type navigates to the whole declaration', () {
      final scene = _sceneOf(_valueTypes);
      final view = RustProgramViewSource(testTransport).loadStructure(
        sourceCode: _valueTypes,
        profileId: SyntaxProfileId.classicSpanish,
      )!;
      final record = view.nodeById(_header(scene, 'Punto').nodeId!)!;

      expect(record.syntaxKind, 'record_unit');
      expect(record.range.startLine, 4);
      expect(record.range.endLine, 6);
    });
  });
}
