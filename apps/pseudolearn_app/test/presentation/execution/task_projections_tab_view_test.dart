import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/execution/execution_history_cubit.dart';
import 'package:pseudolearn_app/application/execution/execution_history_state.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_history_event.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_history_window.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_observation_result.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_observation_state.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_step.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_value_page.dart';
import 'package:pseudolearn_app/domain/ports/program_execution_observer.dart';
import 'package:pseudolearn_app/engine/execution/task_flow_projection.dart';
import 'package:pseudolearn_app/engine/execution/task_structure_projection.dart';
import 'package:pseudolearn_app/presentation/execution/task_projections_tab_view.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

void main() {
  testWidgets('keeps all three projections accessible on a compact screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final states = StreamController<ExecutionState>.broadcast(sync: true);
    final cubit = ExecutionHistoryCubit(
      executionStates: states.stream,
      observer: _WidgetObserver(),
      flowProjector: const TaskFlowProjection(),
      structureProjector: const TaskStructureProjection(),
    );
    states.add(_executionState());

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('es'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: DesignCanvas(
              child: BlocBuilder<ExecutionHistoryCubit, ExecutionHistoryState>(
                builder: (context, state) =>
                    TaskProjectionsTabView(state: state),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('es'));
    expect(find.text(l10n.executionProjectionFlow), findsOneWidget);
    expect(find.text(l10n.executionProjectionStructure), findsOneWidget);
    expect(find.text(l10n.executionProjectionEvents), findsOneWidget);
    expect(
      find.bySemanticsLabel(l10n.executionEventSemantics(0, 0, 'statement', 1)),
      findsWidgets,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.text(l10n.executionProjectionStructure));
    await tester.pumpAndSettle();
    expect(find.text(l10n.executionStructureRoot), findsOneWidget);

    await tester.tap(find.text(l10n.executionProjectionEvents));
    await tester.pumpAndSettle();
    expect(find.text(l10n.executionTaskSelector), findsOneWidget);
    expect(find.text(l10n.executionFrameSelector), findsOneWidget);
    expect(tester.takeException(), isNull);

    await cubit.close();
    await states.close();
  });
}

ExecutionState _executionState() => const ExecutionState(
  status: ExecutionStatus.pausedAtStatement,
  currentStep: ExecutionStep(
    stepNumber: 1,
    scopeName: 'global',
    scopeDepth: 1,
    eventIndex: 0,
  ),
  outputLines: [],
  runId: 1,
);

final class _WidgetObserver implements ProgramExecutionObserver {
  final ExecutionHistoryEvent _event = ExecutionHistoryEvent(
    index: 0,
    taskId: 0,
    eventClass: 'statement',
    line: 1,
    depth: 0,
    data: const {},
    revisionId: 'revision',
    nodeId: 'node',
    sourceRange: null,
  );

  @override
  ExecutionObservationResult<ExecutionHistoryWindow> historyWindow({
    required int start,
    required int count,
  }) => ExecutionObservationValue(
    ExecutionHistoryWindow(
      first: start,
      count: 1,
      horizonFirst: 0,
      horizonLast: 0,
      events: [_event],
    ),
  );

  @override
  ExecutionObservationResult<ExecutionObservationState> stateAt({
    required int event,
    required int taskId,
    required int startFrame,
    required int frameCount,
  }) => ExecutionObservationValue(
    ExecutionObservationState(
      event: event,
      taskId: taskId,
      totalFrames: 0,
      frames: const [],
      tasks: const [
        ExecutionObservedTask(taskId: 0, name: 'Root', state: 'running'),
      ],
    ),
  );

  @override
  ExecutionObservationResult<ExecutionValuePage> valuePage({
    required int event,
    required int taskId,
    required int frame,
    required int pageSize,
    String? cursor,
  }) => ExecutionObservationValue(
    ExecutionValuePage(
      entries: const [],
      total: 0,
      valuesRead: 0,
      truncated: false,
      nextCursor: null,
    ),
  );
}
