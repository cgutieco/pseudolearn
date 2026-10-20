import 'dart:async';
import 'dart:convert';

import 'package:pseudolearn_app/application/execution/execution_cubit.dart';
import 'package:pseudolearn_app/application/execution/step_pace.dart';
import 'package:pseudolearn_app/application/execution/step_batch_runner.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_execution.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

final class BridgeBenchmarkScript {
  final RustTransport _transport;
  final Map<String, Object?> _bindings = {};
  ExecutionCubit? _model;
  String _source = '';
  final StringBuffer _output = StringBuffer();
  int _eventIndex = -1;

  BridgeBenchmarkScript(this._transport);

  Future<List<Map<String, Object?>>> run(Map<String, Object?> scenario) async {
    await _sequence(scenario['setup'], []);
    final measurements = <Map<String, Object?>>[];
    await _sequence(scenario['timed'], measurements);
    if (measurements.isEmpty) {
      throw const FormatException('No timed bridge requests');
    }
    await _sequence(scenario['verify'], []);
    final expected = scenario['expected'] as Map<String, Object?>;
    if (expected.isEmpty ||
        !expected.entries.every(
          (entry) => jsonEncode(_lookup(entry.key)) == jsonEncode(entry.value),
        )) {
      throw FormatException(
        'Bridge scenario did not satisfy its independent expectations: ${expected.keys.map((key) => '$key=${jsonEncode(_lookup(key))}').join(', ')}',
      );
    }
    return measurements;
  }

  Future<void> _sequence(
    Object? sequence,
    List<Map<String, Object?>> measurements,
  ) async {
    for (final step
        in (sequence as List<Object?>? ?? const [])
            .cast<Map<String, Object?>>()) {
      final until = step['until'] as Map<String, Object?>?;
      final limit = until == null ? 1 : step['limit'] as int;
      if (limit <= 0) throw const FormatException('Invalid repetition limit');
      var completed = false;
      for (var attempt = 0; attempt < limit; attempt++) {
        final arguments = _resolve(step['arguments']) as Map<String, Object?>;
        final clock = Stopwatch()..start();
        final invocation = _call(step['operation'] as String, arguments);
        final result = invocation is Future<Object?>
            ? await invocation
            : invocation;
        clock.stop();
        measurements.add({
          'operation': step['label'] ?? step['operation'],
          'nanoseconds': clock.elapsedTicks * 1000000000 / clock.frequency,
          'clock_frequency': clock.frequency,
          'request': measurements.length,
        });
        _bindings[step['save'] as String? ?? 'last'] = result;
        _recordOutput(result);
        completed =
            until == null ||
            until.entries.every(
              (entry) =>
                  jsonEncode(_lookup(entry.key)) == jsonEncode(entry.value),
            );
        if (completed) break;
      }
      if (!completed) {
        throw const FormatException(
          'Bridge scenario exceeded its repetition limit',
        );
      }
    }
  }

  FutureOr<Object?> _call(String operation, Map<String, Object?> arguments) {
    if (operation == 'model_start') {
      _source = arguments['program'] as String;
      _model = ExecutionCubit(
        execution: RustProgramExecution(_transport),
        runner: StepBatchRunner(
          maxSteps:
              arguments['step_limit'] as int? ?? StepBatchRunner.maxTotalSteps,
        ),
      );
      return <String, Object?>{'ready': true};
    }
    if (operation == 'model_advance') return _advance(arguments);
    return _transport.call(operation, arguments);
  }

  Future<Object?> _advance(Map<String, Object?> arguments) async {
    final model = _model;
    if (model == null) throw const FormatException('Model not initialized');
    await model.advance(
      pace: StepPace.values.byName(arguments['pace'] as String),
      sourceCode: _source,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
    );
    return {
      'finished': model.state.currentStep.isFinished,
      'halted': model.state.currentStep.isHalted,
      'output': model.state.outputLines.map((line) => line.text).toList(),
      'line': model.state.currentStep.focus?.startLine,
    };
  }

  void _recordOutput(Object? result) {
    if (result is! Map<String, Object?>) return;
    final events = result['events'];
    if (events is! List<Object?>) return;
    _eventIndex += events.length;
    for (final event in events.cast<Map<String, Object?>>()) {
      if (event['class'] != 'output') continue;
      final payload = event['data'] as Map<String, Object?>;
      _output.write(payload['texto']);
    }
    _bindings['output'] = _output.toString();
    _bindings['event_index'] = _eventIndex;
  }

  Object? _resolve(Object? value) => switch (value) {
    final String text when text.startsWith(r'$') => _lookup(text.substring(1)),
    final Map<String, Object?> object => {
      for (final entry in object.entries) entry.key: _resolve(entry.value),
    },
    final List<Object?> values => values.map(_resolve).toList(),
    _ => value,
  };

  Object? _lookup(String path) {
    Object? value = _bindings;
    for (final component in path.split('.')) {
      if (value is! Map<String, Object?> || !value.containsKey(component)) {
        throw FormatException('Unresolved bridge binding: $path');
      }
      value = value[component];
    }
    return value;
  }

  Future<void> close() async {
    await _model?.close();
    _transport.close();
  }
}
