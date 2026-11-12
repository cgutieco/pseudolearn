import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pseudolearn_app/application/execution/execution_cubit.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';
import 'package:pseudolearn_app/presentation/diagram/flowchart_tab_view.dart';
import 'package:pseudolearn_app/presentation/document/components/output_panel.dart';
import 'package:pseudolearn_app/presentation/document/components/tab_selector.dart';

import '../product/product_documents.dart';
import '../product/scene_actions.dart';
import 'live_take.dart';
import 'plate_timeline.dart';

const String trailerPlate = 'trailer-run';
const String trailerTheme = 'light';
const int trailerSteps = 9;
const double trailerStepSeconds = 0.65;

final List<SceneAction> trailerSetup = <SceneAction>[
  openDocument(guidedDemoId),
  openTab(DocumentTabKind.flowchart),
];

Map<String, Finder> trailerFocus() => <String, Finder>{
      'diagram': find.byType(FlowchartTabView),
      'output': find.byType(OutputPanel),
    };

Future<void> performTrailerRun(LiveTake take) async {
  await take.hold(1);
  await take.tap(find.byIcon(Icons.skip_next), mark: PlateEventKind.statement);
  await take.hold(0.8);
  for (var step = 0; step < trailerSteps; step++) {
    await take.tap(find.byIcon(Icons.arrow_downward),
        mark: PlateEventKind.diagramNode);
    await take.hold(trailerStepSeconds);
  }
  await take.hold(1);
}

void expectTrailerRunPaused(LiveTake take) {
  final execution =
      BlocProvider.of<ExecutionCubit>(take.stage.appContext).state;
  expect(execution.status, ExecutionStatus.pausedAtStatement,
      reason: 'The trailer tail would show an idle program');
}
