import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

import 'interpreter_test_harness.dart';

void main() {
  group('Leer, declared target type', () {
    test('a valid value is accepted and stored', () {
      const src = '''
Proceso Principal
    Definir x Como Entero
    Leer x
    Escribir x
FinProceso
''';
      final result = runProgram(src, inputs: ['42']);
      expect(result.output, equals('42\n'));
    });

    test('several designators are read one at a time, in order', () {
      const src = '''
Proceso Principal
    Definir a Como Entero
    Definir b Como Entero
    Leer a, b
    Escribir a, ",", b
FinProceso
''';
      final result = runProgram(src, inputs: ['1', '2']);
      expect(result.output, equals('1,2\n'));
    });

    test('an integer widens when the target is real', () {
      const src = '''
Proceso Principal
    Definir x Como Real
    Leer x
    Escribir x
FinProceso
''';
      final result = runProgram(src, inputs: ['5']);
      expect(result.output, equals('5.0\n'));
    });
  });

  group('The pause is not requesting the next step (D3)', () {
    test(
        'three steps in, the machine is paused waiting, nothing lost by inspecting state',
        () {
      const src = '''
Proceso Principal
    Definir x Como Entero
    Leer x
    Escribir x
FinProceso
''';
      final interpreter = readyInterpreter(src);

      final outcomes = <StepOutcome>[];
      for (var i = 0; i < 10 && outcomes.length < 10; i++) {
        final outcome = interpreter.step();
        outcomes.add(outcome);
        if (outcome is StepAwaitingInput) break;
      }

      expect(outcomes.last, isA<StepAwaitingInput>());
      final again = interpreter.step();
      expect(again, isA<StepAwaitingInput>());
    });
  });

  group('A value that does not convert: retries, exactly', () {
    test(
        'the wrong type re-prompts for the same designator without changing state',
        () {
      const src = '''
Proceso Principal
    Definir x Como Entero
    Leer x
    Escribir x
FinProceso
''';
      final interpreter = readyInterpreter(src);
      StepOutcome outcome = interpreter.step();
      while (outcome is! StepAwaitingInput) {
        outcome = interpreter.step();
      }
      final designatorBeforeRetry = (outcome).designatorId;

      interpreter.provideInput('no-es-un-numero');
      final afterBadInput = interpreter.step();
      expect(afterBadInput, isA<StepAwaitingInput>());
      expect((afterBadInput as StepAwaitingInput).designatorId,
          equals(designatorBeforeRetry));

      interpreter.provideInput('7');
      final advanced = interpreter.step();
      expect(advanced, isNot(isA<StepAwaitingInput>()));
    });
  });

  group('Inference from a read, indeterminate target', () {
    test('the four classification forms, deterministic order', () {
      const cases = {
        '42': '42\n',
        '3.14': '3.14\n',
        'Verdadero': 'Verdadero\n',
        'hola': 'hola\n',
      };
      for (final entry in cases.entries) {
        const src = '''
Proceso Principal
    Leer x
    Escribir x
FinProceso
''';
        final result = runProgram(src, inputs: [entry.key]);
        expect(result.output, equals(entry.value),
            reason: 'input: ${entry.key}');
      }
    });

    test('a single character classifies as cadena, never as caracter', () {
      const src = '''
Proceso Principal
    Leer x
    Escribir x
FinProceso
''';
      final result = runProgram(src, inputs: ['a']);
      expect(result.output, equals('a\n'));
    });
  });
}
