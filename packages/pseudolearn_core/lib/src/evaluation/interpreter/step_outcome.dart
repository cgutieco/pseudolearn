import '../../domain/diagnostic.dart';
import '../../domain/node_id.dart';
import '../../domain/primitive_type.dart';
import '../events/execution_event.dart';

sealed class StepOutcome {
  const StepOutcome();
}

final class StepAdvanced extends StepOutcome {
  final List<ExecutionEvent> events;

  const StepAdvanced(this.events);
}

final class StepAwaitingInput extends StepOutcome {
  final NodeId designatorId;
  final PrimitiveType? expectedType;

  const StepAwaitingInput(
      {required this.designatorId, required this.expectedType});
}

final class StepHalted extends StepOutcome {
  final Diagnostic diagnostic;

  const StepHalted(this.diagnostic);
}

final class StepFinished extends StepOutcome {
  const StepFinished();
}
