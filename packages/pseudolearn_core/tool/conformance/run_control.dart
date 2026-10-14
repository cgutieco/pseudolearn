final class RunControl {
  final int seed;
  final List<String> inputs;
  final int microSteps;
  final int? statements;
  final int? cancelAtStatement;
  final int? stateAt;
  final bool observing;

  const RunControl({
    required this.seed,
    required this.inputs,
    required this.microSteps,
    required this.statements,
    required this.cancelAtStatement,
    required this.stateAt,
    required this.observing,
  });

  factory RunControl.fromRequest(Map<String, Object?> request) {
    final seed = request['seed'];
    final inputs = request['inputs'];
    final limits = request['limits'];
    final observe = request['observe'];
    if (seed is! int ||
        inputs is! List<Object?> ||
        inputs.any((input) => input is! String) ||
        limits is! Map<String, Object?> ||
        (observe != 'none' && observe != 'events')) {
      throw const FormatException('Invalid execution arguments');
    }
    return RunControl(
      seed: seed,
      inputs: inputs.cast<String>(),
      microSteps: _microSteps(limits['micro_steps']),
      statements: _optionalPositive(limits['statements']),
      cancelAtStatement: _optionalPositive(request['cancel_at_statement']),
      stateAt: _optionalIndex(request['state_at']),
      observing: observe == 'events',
    );
  }
}

int _microSteps(Object? value) {
  if (value is! int || value < 1 || value > 1000000) {
    throw const FormatException('Invalid micro-step limit');
  }
  return value;
}

int? _optionalPositive(Object? value) {
  if (value == null) return null;
  if (value is! int || value < 1) {
    throw const FormatException('Invalid positive limit');
  }
  return value;
}

int? _optionalIndex(Object? value) {
  if (value == null) return null;
  if (value is! int || value < 0) {
    throw const FormatException('Invalid event index');
  }
  return value;
}
