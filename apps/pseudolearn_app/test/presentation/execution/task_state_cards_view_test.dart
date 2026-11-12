import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart' show GlobalCupertinoLocalizations;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart' show GlobalWidgetsLocalizations;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/execution/execution_history_cubit.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';
import 'package:pseudolearn_app/domain/model/execution/block_position.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_history_event.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_history_window.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_observation_result.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_observation_state.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_step.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_task_context.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_value_page.dart';
import 'package:pseudolearn_app/domain/ports/program_execution_observer.dart';
import 'package:pseudolearn_app/engine/execution/task_flow_projection.dart';
import 'package:pseudolearn_app/engine/execution/task_structure_projection.dart';
import 'package:pseudolearn_app/presentation/execution/task_state_cards_view.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

void main() {
  testWidgets('labels recoverable error and cooperative cancellation', (
    tester,
  ) async {
    final states = StreamController<ExecutionState>.broadcast(sync: true);
    final cubit = ExecutionHistoryCubit(
      executionStates: states.stream,
      observer: _Observer(),
      flowProjector: const TaskFlowProjection(),
      structureProjector: const TaskStructureProjection(),
    );
    states.add(_terminalState());

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          locale: const Locale('es'),
        theme: AppTheme.light(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        home: DesignCanvas(
          child: Scaffold(body: TaskStateCardsView(state: cubit.state)),
        ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('es'));
    expect(find.text(l10n.executionTaskOutcomeError), findsOneWidget);
    expect(find.text(l10n.executionTaskOutcomeCancelled), findsOneWidget);
    expect(find.text('error'), findsNothing);
    expect(find.text('cancelled'), findsNothing);
    expect(tester.takeException(), isNull);

    await cubit.close();
    await states.close();
  });
}

ExecutionState _terminalState() => ExecutionState(
  status: ExecutionStatus.finishedSuccess,
  currentStep: ExecutionStep(
    stepNumber: 8,
    eventIndex: 3,
    taskContexts: [
      _context(0, ExecutionTaskStatus.completed, 'success'),
      _context(1, ExecutionTaskStatus.completed, 'error'),
      _context(2, ExecutionTaskStatus.cancelled, 'cancelled'),
    ],
    scopeName: 'global',
    scopeDepth: 1,
    isFinished: true,
  ),
  outputLines: const [],
  runId: 1,
);

ExecutionTaskContext _context(
  int taskId,
  ExecutionTaskStatus status, [
  String? outcome,
]) => ExecutionTaskContext(
  taskId: taskId,
  status: status,
  completionOutcome: outcome,
  lastEventIndex: 3,
  focus: null,
  focusRevision: 0,
  blockPosition: const BlockPosition.outermost(),
  frames: const [],
  scopeName: 'global',
  scopeDepth: taskId == 0 ? 1 : 0,
  variables: const [],
);

final class _Observer implements ProgramExecutionObserver {
  final List<ExecutionHistoryEvent> _events = [
    _event(0, 0, 'task_spawned', {'task': 1, 'parent': 0, 'scope': 2}),
    _event(1, 1, 'task_completed', {'task': 1, 'outcome': 'error'}),
    _event(2, 0, 'task_spawned', {'task': 2, 'parent': 0, 'scope': 2}),
    _event(3, 2, 'task_completed', {'task': 2, 'outcome': 'cancelled'}),
  ];

  @override
  ExecutionObservationResult<ExecutionHistoryWindow> historyWindow({
    required int start,
    required int count,
  }) {
    final events = [
      for (final event in _events)
        if (event.index >= start && event.index < start + count) event,
    ];
    return ExecutionObservationValue(
      ExecutionHistoryWindow(
        first: start,
        count: events.length,
        horizonFirst: 0,
        horizonLast: 3,
        events: events,
      ),
    );
  }

  @override
  ExecutionObservationResult<ExecutionObservationState> stateAt({
    required int event,
    required int taskId,
    required int startFrame,
    required int frameCount,
  }) => const ExecutionObservationFailure('unused');

  @override
  ExecutionObservationResult<ExecutionValuePage> valuePage({
    required int event,
    required int taskId,
    required int frame,
    required int pageSize,
    String? cursor,
  }) => const ExecutionObservationFailure('unused');
}

ExecutionHistoryEvent _event(
  int index,
  int taskId,
  String eventClass,
  Map<String, Object?> data,
) => ExecutionHistoryEvent(
  index: index,
  taskId: taskId,
  eventClass: eventClass,
  line: index + 1,
  depth: 0,
  data: data,
  revisionId: 'revision',
  nodeId: null,
  sourceRange: null,
);
