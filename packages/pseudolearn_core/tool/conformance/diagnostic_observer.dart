import 'package:pseudolearn_core/pseudolearn_core.dart';

import 'wire.dart';

final class ReferenceDiagnosticObserver implements ExecutionObserver {
  final List<Map<String, Object?>> diagnostics;

  ReferenceDiagnosticObserver(this.diagnostics);

  @override
  void onEvent(ExecutionEvent event) {
    if (event is DiagnosticEmittedEvent) {
      diagnostics.add(diagnosticWire(event.diagnostic, 'runtime'));
    }
  }
}
