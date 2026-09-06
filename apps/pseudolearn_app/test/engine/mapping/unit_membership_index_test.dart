import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/engine/analysis/program_analysis.dart';
import 'package:pseudolearn_app/engine/mapping/unit_membership_index.dart';
import 'package:pseudolearn_core/pseudolearn_core.dart';

const String _referenceOOP = '''
Clase Vehiculo
    Publico Definir marca Como Cadena
    Publico Definir velocidad Como Entero

    Metodo Constructor(m Como Cadena)
        Este.marca <- m
        Este.velocidad <- 0
    FinMetodo

    Metodo Acelerar(delta Como Entero)
        Este.velocidad <- Este.velocidad + delta
    FinMetodo

    Metodo Describir()
        Escribir Este.marca, " a ", Este.velocidad, " km/h"
    FinMetodo
FinClase

Proceso PruebaVehiculos
    Definir v Como Vehiculo
    v <- Nuevo Vehiculo("Honda")
    v.Acelerar(75)
FinProceso
''';

void main() {
  group('UnitMembershipIndex', () {
    test('indexes statements to their containing executable units', () {
      final analysis = ProgramAnalysis.of(
        _referenceOOP,
        SyntaxProfileId.classicSpanish,
      );
      final unit = analysis.sourceUnit!;
      final index = UnitMembershipIndex.of(unit);

      final algo = unit.algorithm!;
      for (final stmt in algo.body) {
        expect(index.unitIdOf(stmt.id), 'alg_PruebaVehiculos');
        expect(
          index.unitIdOfProgramNodeId(ProgramNodeId(stmt.id.value)),
          'alg_PruebaVehiculos',
        );
      }

      final vehiculo = unit.classes.first;
      final ctor =
          vehiculo.members.whereType<ConstructorDeclarationNode>().first;
      for (final stmt in ctor.body) {
        expect(index.unitIdOf(stmt.id), 'ctor_Vehiculo');
      }

      final acelerar =
          vehiculo.members.whereType<MethodDeclarationNode>().first;
      for (final stmt in acelerar.body) {
        expect(index.unitIdOf(stmt.id), 'method_Vehiculo_Acelerar');
      }
    });

    test('returns null for orphan or unknown NodeId', () {
      const index = UnitMembershipIndex.empty();
      expect(index.unitIdOf(const NodeId(99999)), isNull);
      expect(
        index.unitIdOfProgramNodeId(const ProgramNodeId(99999)),
        isNull,
      );
    });
  });
}
