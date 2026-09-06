import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/engine/classdiagram/core_class_diagram_builder.dart';

const String _vehicles = '''
Clase Vehiculo
    Publico Definir marca Como Cadena
    Privado Definir velocidad Como Entero

    Metodo Constructor(m Como Cadena)
        Este.marca <- m
    FinMetodo

    Publico Metodo Acelerar(delta Como Entero)
        Este.velocidad <- Este.velocidad + delta
    FinMetodo
FinClase

Clase Motocicleta Hereda De Vehiculo
    Publico Definir cilindrada Como Entero

    Metodo Describir()
        Escribir Este.cilindrada
    FinMetodo
FinClase

Proceso Principal
    Definir moto Como Motocicleta
    moto <- Nuevo Motocicleta("Honda")
FinProceso
''';

const String _noClasses = '''
Proceso Principal
    Definir n Como Entero
    n <- 1
    Escribir n
FinProceso
''';

DiagramScene _sceneOf(String source) => CoreClassDiagramBuilder().buildDiagram(
      sourceCode: source,
      profileId: SyntaxProfileId.classicSpanish,
    );

void main() {
  group('CoreClassDiagramBuilder', () {
    test('builds a scene with one frame per declared class', () {
      final scene = _sceneOf(_vehicles);
      final frames = [
        for (final node in scene.nodes)
          if (node.shape == DiagramShape.classFrame) node,
      ];

      expect(frames.length, 2);
      expect(scene.width, greaterThan(0));
      expect(scene.height, greaterThan(0));
    });

    test('draws the generalization between the two classes', () {
      final scene = _sceneOf(_vehicles);

      expect(scene.edges.single.kind, DiagramEdgeKind.generalization);
    });

    test('a document without classes produces an empty scene', () {
      expect(_sceneOf(_noClasses).isEmpty, isTrue);
    });

    test('a document that does not parse produces an empty scene', () {
      expect(_sceneOf('Clase').isEmpty, isTrue);
    });

    test('an empty document produces an empty scene', () {
      expect(_sceneOf('').isEmpty, isTrue);
    });

    test('two builds of the same source give the same scene size', () {
      expect(_sceneOf(_vehicles).width, _sceneOf(_vehicles).width);
      expect(_sceneOf(_vehicles).height, _sceneOf(_vehicles).height);
    });
  });
}
