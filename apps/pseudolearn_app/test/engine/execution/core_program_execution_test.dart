import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/execution/core_program_execution.dart';

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
        Escribir Este.marca, "a", Este.velocidad, "km/h"
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
  group('CoreProgramExecution', () {
    test('executes a program and produces output lines', () {
      final execution = CoreProgramExecution();
      const source = '''
Algoritmo Test
  Definir x Como Entero
  x <- 5
  Escribir x
FinAlgoritmo
''';

      final initialStep = execution.startExecution(
        sourceCode: source,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      expect(initialStep.isHalted, isFalse);

      var step = initialStep;
      while (!step.isFinished && !step.isHalted) {
        step = execution.step();
      }

      expect(step.isFinished, isTrue);
      expect(execution.outputLines, isNotEmpty);
      expect(
        execution.outputLines.any((line) => line.text.contains('5')),
        isTrue,
      );
    });

    test('executes complete OOP reference program with method calls and super',
        () {
      final execution = CoreProgramExecution();

      final initialStep = execution.startExecution(
        sourceCode: _referenceOOP,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      expect(initialStep.isHalted, isFalse);

      var step = initialStep;
      final visitedUnits = <String>{};

      while (!step.isFinished && !step.isHalted) {
        step = execution.step();
        final unitId = step.focus?.unitId;
        if (unitId != null) {
          visitedUnits.add(unitId);
        }
      }

      expect(step.isFinished, isTrue);
      expect(step.isHalted, isFalse);

      expect(
        visitedUnits,
        containsAll([
          'alg_PruebaVehiculos',
          'ctor_Motocicleta',
          'ctor_Vehiculo',
          'method_Vehiculo_Acelerar',
          'method_Motocicleta_Describir',
          'method_Vehiculo_Describir',
        ]),
      );

      final outputs = execution.outputLines.map((l) => l.text).join(' ');
      expect(outputs, contains('Hondaa75km/h'));
      expect(outputs, contains('250'));
    });
  });
}
