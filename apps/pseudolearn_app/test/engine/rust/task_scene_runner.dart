import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_history_event.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_history_window.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_observation_result.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_step.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_task_context.dart';
import 'package:pseudolearn_app/domain/model/execution/simulated_capabilities.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';
import 'package:pseudolearn_app/engine/rust/rust_execution_resource.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_execution.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_execution_observer.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

const String sceneFixtureDirectory = 'test/fixtures/task_scenes';
const int sceneStepBound = 600;

enum SceneLanguage {
  spanish('es', SyntaxProfileId.classicSpanish, UiLanguageId.spanish),
  english('en', SyntaxProfileId.english, UiLanguageId.english);

  final String suffix;
  final SyntaxProfileId profile;
  final UiLanguageId interfaceLanguage;

  const SceneLanguage(this.suffix, this.profile, this.interfaceLanguage);
}

String sceneSource(String scene, SceneLanguage language) => File(
  '$sceneFixtureDirectory/${scene}_${language.suffix}.pseudo',
).readAsStringSync();

final class TaskSceneRun {
  final RustTransport transport;
  final RustProgramExecution execution;
  final RustProgramExecutionObserver observer;
  final RustExecutionResource resource;

  TaskSceneRun._(this.transport, this.execution, this.observer, this.resource);

  factory TaskSceneRun.open({bool timerPermitted = true}) {
    final transport = openNativeTransport();
    addTearDown(transport.close);
    final resource = RustExecutionResource();
    final execution = RustProgramExecution(
      transport,
      capabilities: SimulatedCapabilities(
        permissions: timerPermitted ? const {'temporizador'} : const {},
      ),
      autoResolveEffects: false,
      observationResource: resource,
    );
    return TaskSceneRun._(
      transport,
      execution,
      RustProgramExecutionObserver(transport, resource),
      resource,
    );
  }

  ExecutionStep start(String source, SceneLanguage language) =>
      execution.startExecution(
        sourceCode: source,
        profileId: language.profile,
        languageId: language.interfaceLanguage,
      );

  ExecutionStep until(
    ExecutionStep from,
    bool Function(ExecutionStep step) reached, {
    int bound = sceneStepBound,
  }) {
    var step = from;
    for (var count = 0; count < bound; count++) {
      if (reached(step) || step.isTerminal) return step;
      step = execution.step();
    }
    fail('the condition was not reached within $bound steps');
  }

  List<String> get lines =>
      execution.outputLines.map((line) => line.text).toList();

  List<ExecutionHistoryEvent> get events {
    final window = observer.historyWindow(start: 0, count: 4096);
    return (window as ExecutionObservationValue<ExecutionHistoryWindow>)
        .value
        .events;
  }
}

ExecutionTaskContext taskOf(ExecutionStep step, int taskId) =>
    step.taskContexts.singleWhere((task) => task.taskId == taskId);

List<ExecutionHistoryEvent> eventsOf(
  List<ExecutionHistoryEvent> events,
  String eventClass,
  int taskId,
) => events
    .where(
      (event) =>
          event.eventClass == eventClass && event.data['task'] == taskId,
    )
    .toList();
