import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_view.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_view_source.dart';
import 'package:pseudolearn_app/engine/rust/rust_type_parameter_text.dart';

import '../../fakes/native_test_engine.dart';

const String _generics = '''
Interfaz Imprimible
Metodo describir() Como Cadena;
FinInterfaz
Interfaz Medible<T>
Metodo medir() Como T;
FinInterfaz
Registro Punto
Definir x Como Entero;
FinRegistro
Clase Base<T>
Definir dato Como T;
Definir origen Como Punto;
FinClase
Clase Hija<T: Imprimible> Hereda De Base<T> Realiza Medible<T>
Metodo medir() Como T
Retornar Este.dato;
FinMetodo
FinClase
Clase Plana
Definir total Como Entero;
FinClase
Algoritmo Main
FinAlgoritmo
''';

DiagramScene _scene() => nativeTestEngine.classDiagramBuilder.buildDiagram(
  sourceCode: _generics,
  profileId: SyntaxProfileId.classicSpanish,
);

RustProgramView _view() => RustProgramViewSource(testTransport).loadStructure(
  sourceCode: _generics,
  profileId: SyntaxProfileId.classicSpanish,
)!;

RustViewNode _classNode(RustProgramView view, String name) => view.nodeById(
  view.units.singleWhere((unit) => unit.name == name).nodeId,
)!;

List<String> _headerNames(DiagramScene scene) => [
  for (final node in scene.nodes)
    if (node.shape == DiagramShape.classHeader) node.lines.last,
];

void main() {
  group('type parameters are written in the header', () {
    test('a generic class shows its parameters and constraints', () {
      expect(
        _headerNames(_scene()),
        containsAll(['Base<T>', 'Hija<T: Imprimible>', 'Medible<T>', 'Plana']),
      );
    });

    test('a class without type parameters keeps its bare name', () {
      final view = _view();

      expect(RustTypeParameterText(view).of(_classNode(view, 'Plana')), '');
      expect(RustTypeParameterText(view).of(null), '');
    });

    test('a record field of a class is a typed row without association', () {
      final scene = _scene();

      expect(
        scene.nodes.any((node) => node.lines.contains('+ origen: Punto')),
        isTrue,
      );
      expect(
        scene.edges.where((edge) => edge.kind == DiagramEdgeKind.association),
        isEmpty,
      );
    });
  });

  group('relations towards generic types carry the written arguments', () {
    test('inheritance and realization are labelled with <T>', () {
      final edges = _scene().edges;

      expect(
        edges
            .singleWhere((edge) => edge.kind == DiagramEdgeKind.generalization)
            .label,
        '<T>',
      );
      expect(
        edges
            .singleWhere((edge) => edge.kind == DiagramEdgeKind.realization)
            .label,
        '<T>',
      );
    });

    test('an unknown target name yields no arguments', () {
      final view = _view();
      final texts = RustTypeParameterText(view);

      expect(texts.argumentsAfter(_classNode(view, 'Hija'), 'Base'), '<T>');
      expect(texts.argumentsAfter(_classNode(view, 'Hija'), 'Otra'), '');
      expect(texts.argumentsAfter(null, 'Base'), '');
    });
  });
}
