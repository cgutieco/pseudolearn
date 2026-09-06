import 'package:pseudolearn_core/pseudolearn_core.dart';
import 'package:test/test.dart';

import 'interpreter_test_harness.dart';

void main() {
  test('runs a program with no input requests to completion', () {
    const src = '''
Proceso Principal
    Escribir "hola"
FinProceso
''';
    final interpreter = readyInterpreter(src);
    final outcome = const ProgramRunner().runToCompletion(interpreter);
    expect(outcome, isA<StepFinished>());
  });

  test('feeds input through the provider callback as the program asks for it',
      () {
    const src = '''
Proceso Principal
    Definir x Como Entero
    Leer x
    Escribir x
FinProceso
''';
    final interpreter = readyInterpreter(src);
    final outcome = const ProgramRunner().runToCompletion(
      interpreter,
      provideInput: (_) => '99',
    );
    expect(outcome, isA<StepFinished>());
  });

  test(
      'a program that requests input without a provider throws instead of hanging',
      () {
    const src = '''
Proceso Principal
    Definir x Como Entero
    Leer x
FinProceso
''';
    final interpreter = readyInterpreter(src);
    expect(() => const ProgramRunner().runToCompletion(interpreter),
        throwsStateError);
  });

  test('stops at a halting diagnostic instead of looping', () {
    const src = '''
Proceso Principal
    Escribir 1 / 0
FinProceso
''';
    final interpreter = readyInterpreter(src);
    final outcome = const ProgramRunner().runToCompletion(interpreter);
    expect(outcome, isA<StepHalted>());
  });
}
