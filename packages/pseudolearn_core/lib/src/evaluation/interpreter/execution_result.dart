import 'interpreter.dart';

enum NotExecutableReason {
  analysisHasErrors,
  containsClassDeclaration,
}

sealed class ExecutionStartResult {
  const ExecutionStartResult();
}

final class ExecutionReady extends ExecutionStartResult {
  final Interpreter interpreter;

  const ExecutionReady(this.interpreter);
}

final class ExecutionNotExecutable extends ExecutionStartResult {
  final NotExecutableReason reason;

  const ExecutionNotExecutable(this.reason);
}
