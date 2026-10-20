import 'package:pseudolearn_app/engine/rust/rust_analysis_api.dart';
import 'package:pseudolearn_app/engine/rust/rust_execution_api.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';
import 'package:pseudolearn_app/engine/rust/rust_wire_models.dart';

import 'see_app_failure_history.dart';

Future<Map<String, Object?>> runDirectExecution(
  RustTransport transport,
  Map<String, Object?> input, {
  bool stopForInput = false,
  List<String> inputs = const [],
}) async {
  final analysis = RustAnalysisApi(transport);
  final handle = analysis.open(
    source: input['program'] as String,
    profile: input['profile'] == 'en' ? 'en' : 'es',
    locale: 'es',
  );
  int? execution;
  try {
    final failure = _analysisFailure(analysis.report(handle));
    if (failure != null) return failure;
    final statementLimit = input['statement_limit'] as int? ?? 0;
    execution = RustExecutionApi(
      transport,
    ).start(handle, statementLimit: statementLimit);
    return {
      ..._DirectRun(
        transport,
        execution,
      ).record(inputs: inputs, stopForInput: stopForInput),
      if (statementLimit > 0) 'statement_limit': statementLimit,
    };
  } finally {
    if (execution != null) transport.call('release', {'resource': execution});
    analysis.release(handle);
  }
}

Map<String, Object?>? _analysisFailure(Map<String, Object?> report) {
  final diagnostics = (report['diagnostics'] as List<Object?>)
      .cast<Map<String, Object?>>();
  final errors = diagnostics.where((item) => item['severity'] == 'error');
  if (report['tree'] == true && errors.isEmpty) return null;
  return {
    'termination': 'failed',
    'output': '',
    'code': errors.isEmpty ? 'analysisFailed' : errors.first['code'],
  };
}

final class _DirectRun {
  final RustTransport transport;
  final int execution;
  final List<RustEvent> events = [];
  final StringBuffer output = StringBuffer();
  RustTerminationKind termination = RustTerminationKind.running;
  String? failureCode;
  Object? preservedFrame;

  _DirectRun(this.transport, this.execution);

  Map<String, Object?> record({
    required List<String> inputs,
    required bool stopForInput,
  }) {
    var inputIndex = 0;
    while (termination == RustTerminationKind.running ||
        termination == RustTerminationKind.awaitingInput) {
      if (termination == RustTerminationKind.awaitingInput) {
        if (stopForInput || inputIndex >= inputs.length) break;
        RustExecutionApi(
          transport,
        ).provideInput(execution, inputs[inputIndex++]);
      }
      _advance();
    }
    return {
      'termination': _terminationName(termination),
      'output': output.toString(),
      if (termination == RustTerminationKind.failed)
        'code': failureCode ?? 'unknown',
      if (stopForInput) 'first_stop': _terminationName(termination),
      if (termination == RustTerminationKind.failed)
        ...failureHistory(transport, execution, events, before: preservedFrame),
    };
  }

  void _advance() {
    final batch = RustExecutionApi(transport).advance(execution, 1);
    events.addAll(batch.events);
    for (final event in batch.events) {
      if (event.eventClass == 'output') output.write(event.data['texto']);
    }
    if (preservedFrame == null &&
        events.isNotEmpty &&
        batch.termination == RustTerminationKind.running) {
      preservedFrame = transport.call('query_frame', {
        'resource': execution,
        'event': 0,
        'frame': 0,
      });
    }
    termination = batch.termination;
    failureCode = batch.failureCode;
  }
}

String _terminationName(RustTerminationKind kind) => switch (kind) {
  RustTerminationKind.completed => 'completed',
  RustTerminationKind.failed => 'failed',
  RustTerminationKind.cancelled => 'cancelled',
  RustTerminationKind.awaitingInput => 'awaiting_input',
  RustTerminationKind.limitReached => 'limit_reached',
  RustTerminationKind.running => 'running',
};
