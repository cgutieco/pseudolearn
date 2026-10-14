import 'package:pseudolearn_core/pseudolearn_core.dart';

import 'run_control.dart';
import 'trace_recorder.dart';
import 'wire.dart';

final class ReferenceHostObserver implements ExecutionObserver {
  final RunControl control;
  final TraceRecorder recorder;
  final List<Map<String, Object?>> diagnostics;
  final StringBuffer output = StringBuffer();
  Map<String, Object?>? stop;
  int _entries = 0;

  ReferenceHostObserver(this.control, this.recorder, this.diagnostics);

  @override
  void onEvent(ExecutionEvent event) {
    if (stop != null) return;
    if (event is DiagnosticEmittedEvent) {
      diagnostics.add(diagnosticWire(event.diagnostic, 'runtime'));
      return;
    }
    stop = _boundary(event);
    if (stop != null) return;
    if (event is OutputProducedEvent) output.write(event.text);
    recorder.record(event);
  }

  Map<String, Object?>? _boundary(ExecutionEvent event) {
    if (event is! StatementEnteredEvent) return null;
    _entries++;
    if (control.cancelAtStatement == _entries) {
      return const {'kind': 'cancelled'};
    }
    final budget = control.statements;
    if (budget != null && _entries > budget) {
      return const {'kind': 'limit_reached', 'limit': 'statements'};
    }
    return null;
  }
}
