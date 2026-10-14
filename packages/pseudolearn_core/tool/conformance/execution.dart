import 'package:pseudolearn_core/pseudolearn_core.dart';

import 'analysis.dart';
import 'host_observer.dart';
import 'run_control.dart';
import 'source_lines.dart';
import 'state_view.dart';
import 'trace_recorder.dart';

Map<String, Object?> execute(
    Map<String, Object?> request, ReferenceAnalysis analysis) {
  final program = analysis.program;
  final response = <String, Object?>{
    'kind': 'execute',
    ...analysis.response,
    'output': '',
    'termination': {'kind': 'failed', 'code': 'analysisFailed'},
    'events': <Object?>[],
    'states': <Object?>[],
  };
  if (program == null || program.hasErrors) return response;
  final control = RunControl.fromRequest(request);
  final host = ReferenceHostObserver(
      control,
      TraceRecorder(nodeLines(program.sourceUnit)),
      response['diagnostics']! as List<Map<String, Object?>>);
  final start = Interpreter.start(
      program: program,
      random: SeededRandomSource(control.seed),
      observer: host);
  if (start is! ExecutionReady) return response;
  final termination = run(start.interpreter, host);
  return finish(response, host, termination, program.profile);
}

Map<String, Object?> run(Interpreter interpreter, ReferenceHostObserver host) {
  final inputs = host.control.inputs.iterator;
  for (var steps = 0; steps < host.control.microSteps; steps++) {
    final outcome = interpreter.step();
    final stop = host.stop;
    if (stop != null) return stop;
    switch (outcome) {
      case StepAwaitingInput():
        if (!inputs.moveNext()) return const {'kind': 'awaiting_input'};
        interpreter.provideInput(inputs.current);
      case StepHalted(:final diagnostic):
        host.recorder.fail(diagnostic);
        return {'kind': 'failed', 'code': diagnostic.code.name};
      case StepFinished():
        return const {'kind': 'completed'};
      case StepAdvanced():
        break;
    }
  }
  return const {'kind': 'limit_reached', 'limit': 'micro_steps'};
}

Map<String, Object?> finish(
    Map<String, Object?> response,
    ReferenceHostObserver host,
    Map<String, Object?> termination,
    LanguageProfile profile) {
  final stateAt = host.control.stateAt;
  final snapshots = host.recorder.snapshots;
  return {
    ...response,
    'output': host.output.toString(),
    'termination': termination,
    'events': host.control.observing ? host.recorder.events : const <Object?>[],
    if (stateAt != null && stateAt >= 0 && stateAt < snapshots.length)
      'state_at': stateView(snapshots[stateAt], profile),
  };
}
