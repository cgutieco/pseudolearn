import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/execution/execution_cubit.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';
import 'package:pseudolearn_app/application/export/export_cubit.dart';
import 'package:pseudolearn_app/application/knowledge/knowledge_cubit.dart';
import 'package:pseudolearn_app/application/knowledge/knowledge_state.dart';
import 'package:pseudolearn_app/application/trace/trace_cubit.dart';
import 'package:pseudolearn_app/presentation/document/components/tab_selector.dart';

import 'product_documents.dart';
import 'scene_actions.dart';
import 'scene_stage.dart';
import 'store_scene.dart';

typedef SceneCheck = void Function(SceneStage stage);

final class StoreSceneSpec {
  final StoreScene scene;
  final List<SceneAction> script;
  final SceneCheck check;

  const StoreSceneSpec({
    required this.scene,
    required this.script,
    required this.check,
  });
}

final Map<StoreScene, StoreSceneSpec> storeSceneSpecs =
    <StoreScene, StoreSceneSpec>{
  StoreScene.syncedViews: StoreSceneSpec(
    scene: StoreScene.syncedViews,
    script: <SceneAction>[
      openDocument(guidedDemoId),
      beginStepping(),
      stepInto(times: 11),
      openTab(DocumentTabKind.flowchart),
      toggleCompanion(),
    ],
    check: _pausedMidProgram,
  ),
  StoreScene.stepByStep: StoreSceneSpec(
    scene: StoreScene.stepByStep,
    script: <SceneAction>[
      openDocument(guidedDemoId),
      beginStepping(),
      stepInto(times: 11),
      expandOutputPanel(),
    ],
    check: _pausedMidProgram,
  ),
  StoreScene.traceTable: StoreSceneSpec(
    scene: StoreScene.traceTable,
    script: <SceneAction>[
      openDocument(aliasDemoId),
      openTab(DocumentTabKind.trace),
      toggleCompanion(),
      beginStepping(),
      stepInto(times: 4),
    ],
    check: _traceShowsAliasedObjects,
  ),
  StoreScene.equivalentCode: StoreSceneSpec(
    scene: StoreScene.equivalentCode,
    script: <SceneAction>[
      openDocument(functionDemoId),
      openTab(DocumentTabKind.equivalentCode),
      toggleCompanion(),
    ],
    check: _exportProducedCode,
  ),
  StoreScene.knowledgeBase: StoreSceneSpec(
    scene: StoreScene.knowledgeBase,
    script: <SceneAction>[openKnowledgeCatalogue()],
    check: _knowledgeCatalogueLoaded,
  ),
};

void _pausedMidProgram(SceneStage stage) {
  final execution =
      BlocProvider.of<ExecutionCubit>(stage.appContext).state;
  expect(
    execution.status,
    ExecutionStatus.pausedAtStatement,
    reason: 'The shot would show an idle editor instead of a running program',
  );
  expect(execution.statementNumber, greaterThan(1));
}

void _traceShowsAliasedObjects(SceneStage stage) {
  final trace = BlocProvider.of<TraceCubit>(stage.appContext).state;
  expect(trace.rows, isNotEmpty, reason: 'The trace table would be empty');
  expect(
    trace.variableNames.length,
    greaterThanOrEqualTo(2),
    reason: 'Aliasing needs two names pointing at one object',
  );
  expect(
    trace.rows.last.cells.values.any((cell) => cell.identityBadge != null),
    isTrue,
    reason: 'No object identity badge is visible, so aliasing is not shown',
  );
}

void _exportProducedCode(SceneStage stage) {
  final export = BlocProvider.of<ExportCubit>(stage.appContext).state;
  expect(
    export.exportedCode,
    isNotEmpty,
    reason: 'The equivalent code pane would show an empty state',
  );
}

void _knowledgeCatalogueLoaded(SceneStage stage) {
  final knowledge = BlocProvider.of<KnowledgeCubit>(stage.appContext).state;
  expect(knowledge.status, KnowledgeStatus.success);
  expect(
    knowledge.specificationEntries,
    isNotEmpty,
    reason: 'The bundled knowledge base did not load',
  );
}
