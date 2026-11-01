import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/diagram/class_diagram_accessibility.dart';
import 'package:pseudolearn_app/application/diagram/diagram_state.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_accessible_element.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_notation.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_program.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';

import '../../fakes/native_test_engine.dart';

const String _invalid = '''
Interfaz Legible
Metodo obtener() Como Entero;
FinInterfaz
Clase Base
FinClase
Clase Lector Hereda De Base Realiza Legible
Metodo obtener(extra Como Entero) Como Entero
Retornar extra;
FinMetodo
FinClase
Algoritmo Principal
FinAlgoritmo
''';

DiagramScene _scene(String source) =>
    nativeTestEngine.classDiagramBuilder.buildDiagram(
      sourceCode: source,
      profileId: SyntaxProfileId.classicSpanish,
    );

List<DiagramAccessibleElement> _elements(String source) =>
    ClassDiagramAccessibility(_scene(source)).elements();

DiagramAccessibleElement _relation(
  List<DiagramAccessibleElement> elements,
  DiagramEdgeKind kind,
) => elements.singleWhere((element) => element.relationKind == kind);

void main() {
  group('class diagram accessibility', () {
    test('every box, row and relation has an accessible element', () {
      final elements = _elements(_invalid);

      int count(DiagramAccessibleRole role) =>
          elements.where((element) => element.role == role).length;

      expect(count(DiagramAccessibleRole.box), 3);
      expect(count(DiagramAccessibleRole.row), 2);
      expect(count(DiagramAccessibleRole.relation), 2);
    });

    test('an invalid realization keeps its diagnostics apart from any color', () {
      final realization = _relation(_elements(_invalid), DiagramEdgeKind.realization);

      expect(realization.isValid, isFalse);
      expect(realization.diagnostics, ['interfaceMethodSignatureMismatch']);
      expect(realization.fromName, 'Lector');
      expect(realization.toName, 'Legible');
    });

    test('a realization navigates to its origin declaration', () {
      final realization = _relation(_elements(_invalid), DiagramEdgeKind.realization);

      expect(_invalid.substring(realization.range!.startOffset).startsWith('Clase Lector'), isTrue);
    });

    test('a relation without origin navigates to the box it starts from', () {
      final generalization = _relation(
        _elements(_invalid),
        DiagramEdgeKind.generalization,
      );

      expect(generalization.isValid, isTrue);
      expect(_invalid.substring(generalization.range!.startOffset).startsWith('Clase Lector'), isTrue);
    });

    test('a row navigates to the exact text of its signature', () {
      final row = _elements(_invalid).firstWhere(
        (element) => element.role == DiagramAccessibleRole.row,
      );
      final range = row.range!;

      expect(row.text, '+ obtener(): Entero');
      expect(
        _invalid.substring(range.startOffset, range.endOffset),
        'Metodo obtener() Como Entero;',
      );
    });

    test('an empty scene has no accessible elements', () {
      expect(ClassDiagramAccessibility(const DiagramScene.empty()).elements(), isEmpty);
    });

    test('only the class notation exposes the elements', () {
      final state = DiagramState(
        flowchart: const DiagramProgram.empty(),
        structogram: const DiagramProgram.empty(),
        classDiagram: _scene(_invalid),
        hasValidAst: true,
      );

      expect(state.accessibleElements, isEmpty);
      expect(
        state.copyWith(notation: DiagramNotation.classDiagram).accessibleElements,
        hasLength(7),
      );
    });
  });
}
