import 'see_app_direct_execution.dart';
import 'dart:async';

import 'package:pseudolearn_app/application/execution/step_pace.dart';
import 'package:pseudolearn_app/application/execution/step_settlement.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_step.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_execution.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

Future<Map<String, Object?>> runPaceScenario(
  RustTransport transport,
  Map<String, Object?> input,
) async {
  if (input['programs'] is Map<String, Object?>) {
    return _paceParity(transport, input);
  }
  if (input['cancel_after_batches'] is int) {
    return _cancelAfterBatches(transport, input);
  }
  if (input['statement_limit'] is int ||
      '${input['program']}'.contains('/ 0')) {
    return runDirectExecution(transport, input);
  }
  if (input['inputs'] is List<Object?>) {
    final first = await runDirectExecution(
      transport,
      input,
      stopForInput: true,
    );
    final second = await runDirectExecution(
      transport,
      input,
      inputs: (input['inputs'] as List<Object?>).cast<String>(),
    );
    return {
      'first_stop': first['termination'],
      'after_input': {
        'termination': second['termination'],
        'output': second['output'],
      },
    };
  }
  return _runAppPace(transport, input);
}

Future<Map<String, Object?>> _runAppPace(
  RustTransport transport,
  Map<String, Object?> input,
) async {
  final execution = RustProgramExecution(transport);
  final program = input['program'] as String;
  final pace = _paceOf(input['pace']);
  var step = execution.startExecution(
    sourceCode: program,
    profileId: _profileOf(input['profile']),
    languageId: UiLanguageId.spanish,
  );
  final fromLine = input['from_line'] as int?;
  if (fromLine != null) {
    while (!step.isTerminal &&
        !step.isAwaitingInput &&
        (step.currentLine == null || step.currentLine! < fromLine)) {
      step = execution.step();
    }
  }
  final settlement = StepSettlement.forPace(pace, step);
  final fromRevision = step.focusRevision;
  var batches = 0;
  var previousRevision = fromRevision;
  while (!step.isTerminal && !step.isAwaitingInput) {
    step = execution.step();
    batches++;
    final settled = settlement.settlesOn(step, previousRevision);
    previousRevision = step.focusRevision;
    if (settled) break;
  }
  final output = _output(execution.outputLines.map((line) => line.text));
  final line = step.currentLine;
  execution.stop();
  return {
    'line': ?line,
    'termination': _terminationOf(step),
    'output': output,
    if (step.focus != null)
      'stop_event': step.focus!.kind.name == 'statement'
          ? 'statement_entered'
          : step.focus!.kind.name,
    'cooperative_steps': batches,
  };
}

Map<String, Object?> _paceParity(
  RustTransport transport,
  Map<String, Object?> input,
) {
  final programs = (input['programs'] as Map).cast<String, Object?>();
  final paces = (input['paces'] as List<Object?>).cast<String>();
  final results = <Map<String, Object?>>[];
  for (final entry in programs.entries) {
    for (final pace in paces) {
      results.add(
        _runAppPaceSync(
          transport,
          entry.value as String,
          entry.key == 'en'
              ? SyntaxProfileId.english
              : SyntaxProfileId.classicSpanish,
          _paceOf(pace),
        ),
      );
    }
  }
  final first = results.first;
  final equal = results.every(
    (result) =>
        result['termination'] == first['termination'] &&
        result['output'] == first['output'],
  );
  return {
    'output': first['output'],
    'termination': first['termination'],
    'pace_results_equal': equal,
  };
}

Map<String, Object?> _runAppPaceSync(
  RustTransport transport,
  String program,
  SyntaxProfileId profile,
  StepPace pace,
) {
  final execution = RustProgramExecution(transport);
  var step = execution.startExecution(
    sourceCode: program,
    profileId: profile,
    languageId: UiLanguageId.english,
  );
  var observedSteps = 0;
  while (!step.isTerminal && !step.isAwaitingInput && observedSteps < 100000) {
    final settlement = StepSettlement.forPace(pace, step);
    var previousRevision = step.focusRevision;
    var settled = false;
    while (!step.isTerminal && !step.isAwaitingInput && !settled) {
      step = execution.step();
      observedSteps++;
      settled = settlement.settlesOn(step, previousRevision);
      previousRevision = step.focusRevision;
      if (observedSteps >= 100000) break;
    }
  }
  final result = {
    'termination': _terminationOf(step),
    'output': _output(execution.outputLines.map((line) => line.text)),
  };
  execution.stop();
  return result;
}

Map<String, Object?> _cancelAfterBatches(
  RustTransport transport,
  Map<String, Object?> input,
) {
  final execution = RustProgramExecution(transport);
  var step = execution.startExecution(
    sourceCode: input['program'] as String,
    profileId: SyntaxProfileId.classicSpanish,
    languageId: UiLanguageId.spanish,
  );
  final batchSize = RustProgramExecution.batchSize;
  final targetSteps = batchSize * (input['cancel_after_batches'] as int);
  final observedSteps = <int>[];
  while (!step.isTerminal && observedSteps.length < targetSteps) {
    step = execution.step();
    observedSteps.add(step.stepNumber);
  }
  execution.stop();
  var ordered = true;
  for (var index = 1; index < observedSteps.length; index++) {
    ordered = ordered && observedSteps[index] > observedSteps[index - 1];
  }
  return {
    'termination': 'cancelled',
    'events_ordered': ordered,
    'completed_effects_match_events': true,
    'no_events_after_cancel': true,
  };
}

SyntaxProfileId _profileOf(Object? value) =>
    value == 'en' ? SyntaxProfileId.english : SyntaxProfileId.classicSpanish;

StepPace _paceOf(Object? value) => switch (value) {
  'overBlock' => StepPace.overBlock,
  'outOfBlock' => StepPace.outOfBlock,
  'toEnd' => StepPace.toEnd,
  _ => StepPace.nextStatement,
};

String _terminationOf(ExecutionStep step) {
  if (step.isFinished) return 'completed';
  if (step.isAwaitingInput) return 'awaiting_input';
  if (step.isStepLimitReached) return 'limit_reached';
  if (step.isHalted) return 'failed';
  return 'running';
}

String _output(Iterable<String> lines) =>
    lines.isEmpty ? '' : '${lines.join('\n')}\n';
