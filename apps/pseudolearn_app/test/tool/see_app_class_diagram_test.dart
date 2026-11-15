import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/diagram/class_diagram_metrics.dart';
import '../../tool/see_app_class_diagram.dart';
import '../fakes/native_test_engine.dart';

const String _invalidProgram = '''
Interfaz Legible
Metodo obtener() Como Entero;
FinInterfaz
Clase Lector Realiza Legible
Metodo obtener(extra Como Entero) Como Entero
Retornar extra;
FinMetodo
FinClase
Algoritmo Principal
FinAlgoritmo
''';

void main() {
  tearDownAll(closeTestEngine);

  test(
    'the scene exposes invalid accessible relations with source and hit bounds',
    () async {
      final result = await runClassDiagramScenario(testTransport, {
        'program': _invalidProgram,
        'profile': 'es',
      });
      final relations = (result['invalid_accessible_relations'] as List)
          .cast<Map<String, Object?>>();

      expect(relations, hasLength(1));
      expect(relations.single['kind'], 'realization');
      expect(relations.single['from'], 'Lector');
      expect(relations.single['to'], 'Legible');
      expect(relations.single['diagnostics'], [
        'interfaceMethodSignatureMismatch',
      ]);
      expect(relations.single['has_source_range'], isTrue);
      expect(
        relations.single['hit_target_width'],
        ClassDiagramMetrics.relationHitSize,
      );
      expect(
        relations.single['hit_target_height'],
        ClassDiagramMetrics.relationHitSize,
      );
    },
  );

  test('a valid scene has no invalid accessible relations', () async {
    final result = await runClassDiagramScenario(testTransport, {
      'program': 'Algoritmo Principal\nFinAlgoritmo\n',
      'profile': 'es',
    });

    expect(result['invalid_accessible_relations'], isEmpty);
  });
}
