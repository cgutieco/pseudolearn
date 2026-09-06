import '../../domain/diagnostic.dart';
import '../../domain/node_id.dart';
import '../../domain/primitive_type.dart';
import '../../domain/span.dart';
import 'environment_snapshot.dart';

sealed class ExecutionEvent {
  const ExecutionEvent();
}

final class StatementEnteredEvent extends ExecutionEvent {
  final NodeId statementId;
  final EnvironmentSnapshot? snapshot;

  const StatementEnteredEvent({required this.statementId, this.snapshot});
}

final class StatementExitedEvent extends ExecutionEvent {
  final NodeId statementId;
  final EnvironmentSnapshot? snapshot;

  const StatementExitedEvent({required this.statementId, this.snapshot});
}

enum DecisionBranch { affirmative, negative, selectedCase, defaultCase }

final class DecisionEvaluatedEvent extends ExecutionEvent {
  final NodeId decisionId;
  final Span decisionSpan;
  final DecisionBranch branch;
  final int? caseIndex;
  final EnvironmentSnapshot? snapshot;

  const DecisionEvaluatedEvent({
    required this.decisionId,
    required this.decisionSpan,
    required this.branch,
    this.caseIndex,
    this.snapshot,
  });
}

final class OutputProducedEvent extends ExecutionEvent {
  final String text;

  const OutputProducedEvent(this.text);
}

final class InputRequestedEvent extends ExecutionEvent {
  final NodeId designatorId;
  final PrimitiveType expectedType;

  const InputRequestedEvent({
    required this.designatorId,
    required this.expectedType,
  });
}

final class InputAcceptedEvent extends ExecutionEvent {
  final String rawText;

  const InputAcceptedEvent(this.rawText);
}

final class SubroutineEnteredEvent extends ExecutionEvent {
  final String subroutineName;
  final Span callSpan;
  final EnvironmentSnapshot? snapshot;

  const SubroutineEnteredEvent({
    required this.subroutineName,
    required this.callSpan,
    this.snapshot,
  });
}

final class SubroutineExitedEvent extends ExecutionEvent {
  final String subroutineName;
  final EnvironmentSnapshot? snapshot;

  const SubroutineExitedEvent({required this.subroutineName, this.snapshot});
}

final class DiagnosticEmittedEvent extends ExecutionEvent {
  final Diagnostic diagnostic;

  const DiagnosticEmittedEvent(this.diagnostic);
}

final class ExecutionFinishedEvent extends ExecutionEvent {
  const ExecutionFinishedEvent();
}

final class ExecutionHaltedEvent extends ExecutionEvent {
  final Diagnostic diagnostic;

  const ExecutionHaltedEvent(this.diagnostic);
}
