import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/execution/execution_cubit.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';
import 'package:pseudolearn_app/presentation/diagram/flowchart_tab_view.dart';
import 'package:pseudolearn_app/presentation/document/components/tab_selector.dart';
import 'package:pseudolearn_app/presentation/editor/code_field.dart';
import 'package:pseudolearn_app/presentation/export/export_tab_view.dart';
import 'package:pseudolearn_app/presentation/trace/trace_table.dart';

import '../product/product_documents.dart';
import '../product/scene_actions.dart';
import '../product/scene_stage.dart';
import 'chapter_scenes.dart';

const String desktopPlateDevice = 'windows-desktop';
const int desktopStep = 4;

List<SceneAction> _besideEditor(DocumentTabKind tab) => <SceneAction>[
      openDocument(guidedDemoId),
      openTab(tab),
      toggleCompanion(),
      beginStepping(),
      stepInto(times: desktopStep),
    ];

final List<ChapterScene> desktopScenes = <ChapterScene>[
  ChapterScene(
    plate: 'desk-run',
    script: (_) => _besideEditor(DocumentTabKind.flowchart),
    check: _pausedBesideEditor,
    focus: () => <String, Finder>{
      'editor': find.byType(CodeField).first,
      'diagram': find.byType(FlowchartTabView),
    },
  ),
  ChapterScene(
    plate: 'desk-trace',
    script: (_) => _besideEditor(DocumentTabKind.trace),
    check: _pausedBesideEditor,
    focus: () => <String, Finder>{
      'editor': find.byType(CodeField).first,
      'trace': find.byType(TraceTable),
    },
  ),
  ChapterScene(
    plate: 'desk-code',
    script: (_) => _besideEditor(DocumentTabKind.equivalentCode),
    check: _pausedBesideEditor,
    focus: () => <String, Finder>{
      'editor': find.byType(CodeField).first,
      'export': find.byType(ExportTabView),
    },
  ),
];

void _pausedBesideEditor(SceneStage stage) {
  final execution = BlocProvider.of<ExecutionCubit>(stage.appContext).state;
  expect(execution.status, ExecutionStatus.pausedAtStatement,
      reason: 'The desktop plate would show an idle program');
  expect(find.byType(CodeField), findsWidgets,
      reason: 'The editor must stay beside the companion view');
}
