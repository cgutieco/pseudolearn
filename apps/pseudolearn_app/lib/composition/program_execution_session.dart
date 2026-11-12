import '../domain/ports/program_execution.dart';
import '../domain/ports/program_execution_observer.dart';

final class ProgramExecutionSession {
  final ProgramExecution execution;
  final ProgramExecutionObserver observer;

  const ProgramExecutionSession({
    required this.execution,
    required this.observer,
  });
}
