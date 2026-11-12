import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart' show GlobalCupertinoLocalizations;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart' show GlobalWidgetsLocalizations;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/execution/execution_history_command.dart';
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
  late StreamController<ExecutionState> states;
  late ExecutionHistoryCubit cubit;
  late AppLocalizations l10n;

  setUp(() async {
    states = StreamController<ExecutionState>.broadcast(sync: true);
    cubit = ExecutionHistoryCubit(
      executionStates: states.stream,
      observer: _Observer(),
      flowProjector: const TaskFlowProjection(),
      structureProjector: const TaskStructureProjection(),
    );
    l10n = await AppLocalizations.delegate.load(const Locale('es'));
  });

  tearDown(() async {
    await cubit.close();
    await states.close();
  });

  testWidgets('narrates the live event and follows it on a phone screen', (
    tester,
  ) async {
    await _pump(tester, cubit, states);

    expect(
      find.text(l10n.executionEventPosition(_last, _last)),
      findsOneWidget,
    );
    expect(
      find.text(l10n.executionSentenceEnter('T1 · Produce', 9)),
      findsOneWidget,
    );
    expect(find.text('$_last').hitTestable(), findsOneWidget);
    expect(find.text('0').hitTestable(), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('steps back through events and explains the wait on the join', (
    tester,
  ) async {
    await _pump(tester, cubit, states);

    cubit.dispatch(const SelectHistoryEvent(4));
    await tester.pumpAndSettle();

    expect(find.text(l10n.executionEventPosition(4, _last)), findsOneWidget);
    expect(
      find.text(l10n.executionSentenceWaitJoin('T0 · principal')),
      findsOneWidget,
    );
    expect(find.text('4').hitTestable(), findsOneWidget);

    await tester.tap(find.text(l10n.executionProjectionStructure));
    await tester.pumpAndSettle();
    expect(find.text(l10n.executionHintWaitJoin(1, 1)), findsOneWidget);
    expect(find.text(l10n.executionHintReady), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  _compactPaneTest();

  testWidgets('shows variables of the chosen task in one scrollable list', (
    tester,
  ) async {
    await _pump(tester, cubit, states);

    await tester.tap(find.text(l10n.executionProjectionEvents));
    await tester.pumpAndSettle();

    expect(find.text(l10n.executionFollowEventTask), findsOneWidget);
    expect(find.text('Produce'), findsWidgets);
    expect(find.text('firstAccepted'), findsOneWidget);
    expect(find.text('Verdadero'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

const int _last = 60;

void _compactPaneTest() => testWidgets(
  'fits the companion pane under the editor without overflowing',
  (tester) async {
    final states = StreamController<ExecutionState>.broadcast(sync: true);
    final cubit = ExecutionHistoryCubit(
      executionStates: states.stream,
      observer: _Observer(),
      flowProjector: const TaskFlowProjection(),
      structureProjector: const TaskStructureProjection(),
    );
    final l10n = await AppLocalizations.delegate.load(const Locale('es'));
    await _pump(tester, cubit, states, size: const Size(375, 230));

    final sentence = l10n.executionSentenceEnter('T1 · Produce', 9);
    expect(find.text('$_last/$_last · $sentence'), findsOneWidget);
    expect(find.text(l10n.executionEventPosition(_last, _last)), findsNothing);
    expect(find.text('$_last').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);

    await cubit.close();
    await states.close();
  },
);

Future<void> _pump(
  WidgetTester tester,
  ExecutionHistoryCubit cubit,
  StreamController<ExecutionState> states, {
  Size size = const Size(375, 520),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
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
              builder: (context, state) => TaskProjectionsTabView(state: state),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

ExecutionState _executionState() => const ExecutionState(
  status: ExecutionStatus.pausedAtStatement,
  currentStep: ExecutionStep(
    stepNumber: 1,
    scopeName: 'global',
    scopeDepth: 1,
    eventIndex: _last,
  ),
  outputLines: [],
  runId: 1,
);

final List<ExecutionHistoryEvent> _events = [
  _event(0, 0, 'statement_entered'),
  _event(1, 0, 'task_spawned', {'task': 1, 'parent': 0, 'scope': 0}),
  _event(2, 0, 'task_ready', {'task': 1, 'cause': 'spawn'}),
  _event(3, 0, 'statement_exited'),
  _event(4, 0, 'task_suspended', {'task': 0, 'cause': 'join', 'target': 0}),
  _event(5, 1, 'task_resumed', {'task': 1}),
  _event(6, 1, 'call', {'nombre': 'Produce'}),
  for (var index = 7; index <= _last; index++)
    _event(index, 1, 'statement_entered', const {}, 9),
];

ExecutionHistoryEvent _event(
  int index,
  int taskId,
  String eventClass, [
  Map<String, Object?> data = const {},
  int line = 1,
]) => ExecutionHistoryEvent(
  index: index,
  taskId: taskId,
  eventClass: eventClass,
  line: line,
  depth: 0,
  data: data,
  revisionId: 'revision',
  nodeId: null,
  sourceRange: null,
);

final class _Observer implements ProgramExecutionObserver {
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
        horizonLast: _last,
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
  }) => ExecutionObservationValue(
    ExecutionObservationState(
      event: event,
      taskId: taskId,
      totalFrames: 1,
      frames: const [
        ExecutionObservedFrame(
          id: 1,
          name: 'Produce',
          sourceId: 0,
          revisionId: 'revision',
          line: 9,
          column: 1,
        ),
      ],
      tasks: const [
        ExecutionObservedTask(taskId: 0, name: 'Root', state: 'suspended'),
        ExecutionObservedTask(taskId: 1, name: 'Task 1', state: 'running'),
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
      entries: [
        ExecutionValueEntry(
          name: 'firstAccepted',
          value: const {'valor': 'Verdadero'},
        ),
      ],
      total: 1,
      valuesRead: 1,
      truncated: false,
      nextCursor: null,
    ),
  );
}
