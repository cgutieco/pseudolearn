import '../../domain/primitive_type.dart';
import 'interpreter.dart';
import 'step_outcome.dart';

typedef InputProvider = String Function(PrimitiveType? expectedType);

final class ProgramRunner {
  const ProgramRunner();

  StepOutcome runToCompletion(Interpreter interpreter,
      {InputProvider? provideInput}) {
    while (true) {
      final outcome = interpreter.step();
      switch (outcome) {
        case StepFinished():
          return outcome;
        case StepHalted():
          return outcome;
        case StepAwaitingInput():
          if (provideInput == null) {
            throw StateError(
                'Program requested input but no input provider was given.');
          }
          interpreter.provideInput(provideInput(outcome.expectedType));
        case StepAdvanced():
          break;
      }
    }
  }
}
