import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
import 'chapter_actions.dart';
import 'nodo_script.dart';
import 'plate_timeline.dart';
import 'preview_take.dart';

typedef PreviewPerformance = Future<void> Function(
  PreviewTake take,
  UiLanguageId language,
);

final class PreviewScene {
  final String plate;
  final String theme;
  final List<SceneAction> setup;
  final PreviewPerformance perform;
  final Map<String, Finder> Function() focus;
  final void Function(PreviewTake take) check;

  const PreviewScene({
    required this.plate,
    required this.theme,
    required this.setup,
    required this.perform,
    required this.focus,
    this.check = _showsWhatItRecorded,
  });
}

void _showsWhatItRecorded(PreviewTake take) {}

void _nodoAnsweredWithVerifiedCode(PreviewTake take) {
  final l10n = take.stage.l10n;
  expect(find.textContaining(l10n.agentAiBadge), findsWidgets,
      reason: 'Nodo must always carry its AI label');
  expect(find.text('\u2713 ${l10n.agentVerified}'), findsOneWidget,
      reason: 'The scripted code did not pass the analyzer');
}

const int _steps = 9;
const Duration _routeSettle = Duration(seconds: 8);
const double _stepSeconds = 0.65;

final List<PreviewScene> previewScenes = <PreviewScene>[
  PreviewScene(
    plate: 'preview-program',
    theme: 'light',
    setup: <SceneAction>[openDocument(guidedDemoId)],
    perform: (take, _) async {
      await take.hold(1.2);
      await take.tap(find.byIcon(Icons.play_arrow),
          mark: PlateEventKind.statement);
      await take.hold(2.5);
      take.mark(PlateEventKind.completion);
      await take.hold(3);
    },
    focus: () => <String, Finder>{
      'editor': find.byType(CodeField),
      'output': find.byType(OutputPanel),
    },
  ),
  PreviewScene(
    plate: 'preview-run',
    theme: 'light',
    setup: <SceneAction>[
      openDocument(guidedDemoId),
      openTab(DocumentTabKind.flowchart),
    ],
    perform: (take, _) => _stepThrough(take, PlateEventKind.diagramNode),
    focus: () => <String, Finder>{
      'diagram': find.byType(FlowchartTabView),
      'output': find.byType(OutputPanel),
    },
  ),
  PreviewScene(
    plate: 'preview-trace',
    theme: 'light',
    setup: <SceneAction>[
      openDocument(guidedDemoId),
      openTab(DocumentTabKind.trace),
    ],
    perform: (take, _) => _stepThrough(take, PlateEventKind.statement),
    focus: () => <String, Finder>{'trace': find.byType(TraceTable)},
  ),
  PreviewScene(
    plate: 'preview-nodo',
    theme: 'dark',
    setup: <SceneAction>[openDocument(guidedDemoId)],
    perform: _askNodo,
    check: _nodoAnsweredWithVerifiedCode,
    focus: () => <String, Finder>{
      'question': find.byType(AgentMessageBubble).first,
      'answer': find.byType(AgentMessageBubble).last,
      'verified-code': find.byType(VerifiedCodeBlock),
    },
  ),
  PreviewScene(
    plate: 'preview-code',
    theme: 'light',
    setup: <SceneAction>[openDocument(functionDemoId)],
    perform: (take, _) async {
      await take.hold(1);
      await take.tap(find.text(tabLabelOf(
          DocumentTabKind.equivalentCode, take.stage.l10n)));
      await take.hold(1.8);
      await take.tap(find.text('Rust'), mark: PlateEventKind.statement);
      await take.hold(3.5);
    },
    focus: () => <String, Finder>{'export': find.byType(ExportTabView)},
  ),
  PreviewScene(
    plate: 'preview-route',
    theme: 'light',
    setup: <SceneAction>[openKnowledgeCatalogue(settleFor: _routeSettle)],
    perform: (take, _) async {
      await take.hold(1.5);
      await take.fling(
        find.ancestor(
          of: find.byType(RouteLessonTile).first,
          matching: find.byType(Scrollable),
        ),
        const Offset(0, -500),
        900,
      );
      await take.hold(3);
      take.mark(PlateEventKind.completion);
      await take.hold(1);
    },
    focus: () => <String, Finder>{'lesson': find.byType(RouteLessonTile).first},
  ),
];

Future<void> _stepThrough(PreviewTake take, PlateEventKind milestone) async {
  await take.hold(1);
  await take.tap(find.byIcon(Icons.skip_next), mark: PlateEventKind.statement);
  await take.hold(0.8);
  for (var step = 0; step < _steps; step++) {
    await take.tap(find.byIcon(Icons.arrow_downward), mark: milestone);
    await take.hold(_stepSeconds);
  }
  await take.hold(1);
}

Future<void> _askNodo(PreviewTake take, UiLanguageId language) async {
  await take.hold(1);
  await take.tap(find.byKey(agentLauncherKey));
  await take.hold(1.2);
  await take.type(
    find.descendant(
      of: find.byKey(agentComposerKey),
      matching: find.byType(TextField),
    ),
    nodoExchanges[language]!.question,
  );
  await take.hold(0.8);
  await take.tap(find.byKey(agentSendKey), mark: PlateEventKind.agentMessage);
  await take.hold(5);
}
