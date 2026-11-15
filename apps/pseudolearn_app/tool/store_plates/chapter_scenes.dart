import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/execution/execution_cubit.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';
import 'package:pseudolearn_app/application/export/export_cubit.dart';
import 'package:pseudolearn_app/application/route/route_index_cubit.dart';
import 'package:pseudolearn_app/application/route/route_index_state.dart';
import 'package:pseudolearn_app/application/trace/trace_cubit.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/presentation/agent/agent_message_bubble.dart';
import 'package:pseudolearn_app/presentation/agent/verified_code_block.dart';
import 'package:pseudolearn_app/presentation/diagram/flowchart_tab_view.dart';
import 'package:pseudolearn_app/presentation/document/components/output_panel.dart';
import 'package:pseudolearn_app/presentation/document/components/tab_selector.dart';
import 'package:pseudolearn_app/presentation/editor/code_field.dart';
import 'package:pseudolearn_app/presentation/export/export_tab_view.dart';
import 'package:pseudolearn_app/presentation/route/route_index_view.dart';
import 'package:pseudolearn_app/presentation/trace/trace_table.dart';

import '../product/product_documents.dart';
import '../product/scene_actions.dart';
import '../product/scene_stage.dart';
import 'chapter_actions.dart';
import 'nodo_script.dart';

typedef ChapterCheck = void Function(SceneStage stage);

final class ChapterScene {
  final String plate;
  final List<SceneAction> Function(UiLanguageId language) script;
  final ChapterCheck check;
  final Map<String, Finder> Function() focus;

  const ChapterScene({
    required this.plate,
    required this.script,
    required this.check,
    required this.focus,
  });
}

final List<ChapterScene> chapterScenes = <ChapterScene>[
  ChapterScene(
    plate: 'chapter-idea',
    script: (_) => <SceneAction>[openDocument(guidedDemoId)],
    check: _editorShowsProgram,
    focus: () => <String, Finder>{'editor': find.byType(CodeField)},
  ),
  ChapterScene(
    plate: 'chapter-run',
    script: (_) => <SceneAction>[
      openDocument(guidedDemoId),
      beginStepping(),
      stepInto(times: 11),
      openTab(DocumentTabKind.flowchart),
    ],
    check: _pausedMidProgram,
    focus: () => <String, Finder>{
      'diagram': find.byType(FlowchartTabView),
      'output': find.byType(OutputPanel),
    },
  ),
  ChapterScene(
    plate: 'chapter-trace',
    script: (_) => <SceneAction>[
      openDocument(guidedDemoId),
      openTab(DocumentTabKind.trace),
      beginStepping(),
      stepInto(times: 11),
    ],
    check: _traceHasRows,
    focus: () => <String, Finder>{'trace': find.byType(TraceTable)},
  ),
  ChapterScene(
    plate: 'chapter-nodo',
    script: (language) => <SceneAction>[
      openDocument(guidedDemoId),
      openNodo(),
      askNodo(nodoExchanges[language]!.question),
    ],
    check: _nodoAnsweredWithVerifiedCode,
    focus: () => <String, Finder>{
      'question': find.byType(AgentMessageBubble).first,
      'answer': find.byType(AgentMessageBubble).last,
      'verified-code': find.byType(VerifiedCodeBlock),
    },
  ),
  ChapterScene(
    plate: 'chapter-code',
    script: (_) => <SceneAction>[
      openDocument(functionDemoId),
      openTab(DocumentTabKind.equivalentCode),
      selectRustExport(),
    ],
    check: _exportProducedCode,
    focus: () => <String, Finder>{'export': find.byType(ExportTabView)},
  ),
  ChapterScene(
    plate: 'chapter-route',
    script: (_) => <SceneAction>[openKnowledgeCatalogue()],
    check: _routeLoaded,
    focus: () => <String, Finder>{'lesson': find.byType(RouteLessonTile).first},
  ),
];

void _editorShowsProgram(SceneStage stage) {
  expect(find.textContaining('temperatur'), findsWidgets,
      reason: 'The editor would not show the guided program');
}

void _pausedMidProgram(SceneStage stage) {
  final execution = BlocProvider.of<ExecutionCubit>(stage.appContext).state;
  expect(execution.status, ExecutionStatus.pausedAtStatement,
      reason: 'The plate would show an idle program instead of a running one');
  expect(execution.statementNumber, greaterThan(1));
}

void _traceHasRows(SceneStage stage) {
  final trace = BlocProvider.of<TraceCubit>(stage.appContext).state;
  expect(trace.rows.length, greaterThanOrEqualTo(3),
      reason: 'The trace table would be nearly empty');
}

void _nodoAnsweredWithVerifiedCode(SceneStage stage) {
  final l10n = stage.l10n;
  expect(find.textContaining(l10n.agentAiBadge), findsWidgets,
      reason: 'Nodo must always carry its AI label');
  expect(find.text('✓ ${l10n.agentVerified}'), findsOneWidget,
      reason: 'The scripted code did not pass the analyzer');
}

void _exportProducedCode(SceneStage stage) {
  final export = BlocProvider.of<ExportCubit>(stage.appContext).state;
  expect(export.exportedCode, isNotEmpty,
      reason: 'The equivalent code pane would be empty');
}

void _routeLoaded(SceneStage stage) {
  final route = BlocProvider.of<RouteIndexCubit>(stage.appContext).state;
  expect(route.status, RouteIndexStatus.success);
  expect(route.toc.lessons, isNotEmpty);
}
