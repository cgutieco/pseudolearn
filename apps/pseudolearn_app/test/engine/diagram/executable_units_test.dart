import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_unit.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/analysis/program_analysis.dart';
import 'package:pseudolearn_app/engine/diagram/diagram_vocabulary.dart';
import 'package:pseudolearn_app/engine/diagram/executable_units.dart';

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

Clase Motocicleta Hereda De Vehiculo
    Publico Definir cilindrada Como Entero

    Metodo Constructor(m Como Cadena, cc Como Entero)
        Super.Constructor(m)
        Este.cilindrada <- cc
    FinMetodo

    Metodo Describir()
        Super.Describir()
        Escribir "(", Este.cilindrada, "cc)"
    FinMetodo
FinClase

Proceso PruebaVehiculos
    Definir moto Como Motocicleta
    moto <- Nuevo Motocicleta("Honda", 250)
    moto.Acelerar(75)
    moto.Describir()
FinProceso
''';

void main() {
  group('ExecutableUnits', () {
    final vocab = DiagramVocabulary.forLanguage(UiLanguageId.spanish);

    test('extracts all executable units from OOP reference program', () {
      final analysis = ProgramAnalysis.of(
        _referenceOOP,
        SyntaxProfileId.classicSpanish,
      );
      final unit = analysis.sourceUnit;
      expect(unit, isNotNull);

      final entries = ExecutableUnits.fromAst(unit, vocabulary: vocab);
      expect(entries, hasLength(6));

      expect(entries[0].unit.id, 'alg_PruebaVehiculos');
      expect(entries[0].unit.kind, DiagramUnitKind.algorithm);
      expect(entries[0].unit.displayName, 'Algoritmo PruebaVehiculos');

      expect(entries[1].unit.id, 'ctor_Vehiculo');
      expect(entries[1].unit.kind, DiagramUnitKind.constructor);
      expect(entries[1].unit.className, 'Vehiculo');
      expect(entries[1].unit.displayName, 'Constructor Vehiculo');

      expect(entries[2].unit.id, 'method_Vehiculo_Acelerar');
      expect(entries[2].unit.kind, DiagramUnitKind.method);
      expect(entries[2].unit.className, 'Vehiculo');
      expect(entries[2].unit.displayName, 'Método Vehiculo.Acelerar');

      expect(entries[3].unit.id, 'method_Vehiculo_Describir');
      expect(entries[3].unit.kind, DiagramUnitKind.method);
      expect(entries[3].unit.className, 'Vehiculo');

      expect(entries[4].unit.id, 'ctor_Motocicleta');
      expect(entries[4].unit.kind, DiagramUnitKind.constructor);
      expect(entries[4].unit.className, 'Motocicleta');

      expect(entries[5].unit.id, 'method_Motocicleta_Describir');
      expect(entries[5].unit.kind, DiagramUnitKind.method);
      expect(entries[5].unit.className, 'Motocicleta');
    });

    test('extracts single unit for procedural program without classes', () {
      const source = '''
Algoritmo SoloAlgo
    Escribir "Hola"
FinAlgoritmo
''';
      final analysis = ProgramAnalysis.of(
        source,
        SyntaxProfileId.classicSpanish,
      );
      final entries = ExecutableUnits.fromAst(
        analysis.sourceUnit,
        vocabulary: vocab,
      );
      expect(entries, hasLength(1));
      expect(entries.single.unit.kind, DiagramUnitKind.algorithm);
    });

    test('handles class with no methods or empty body', () {
      const source = '''
Clase Vacia
    Publico Definir x Como Entero
FinClase

Proceso Main
FinProceso
''';
      final analysis = ProgramAnalysis.of(
        source,
        SyntaxProfileId.classicSpanish,
      );
      final entries = ExecutableUnits.fromAst(
        analysis.sourceUnit,
        vocabulary: vocab,
      );
      expect(entries, hasLength(1));
      expect(entries.single.unit.id, 'alg_Main');
    });

    test('returns empty list for null AST', () {
      final entries = ExecutableUnits.fromAst(null, vocabulary: vocab);
      expect(entries, isEmpty);
    });
  });
}
