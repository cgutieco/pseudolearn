import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pseudolearn_app/application/knowledge/bank/exercise_bank_cubit.dart';
import 'package:pseudolearn_app/application/knowledge/bank/exercise_bank_state.dart';
import 'package:pseudolearn_app/application/knowledge/knowledge_cubit.dart';
import 'package:pseudolearn_app/application/knowledge/knowledge_state.dart';
import 'package:pseudolearn_app/application/knowledge/route/learning_route_cubit.dart';
import 'package:pseudolearn_app/application/knowledge/route/learning_route_state.dart';
import 'package:pseudolearn_app/presentation/document/components/tab_selector.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';

import 'scene_stage.dart';

typedef SceneAction = Future<void> Function(SceneStage stage);

const String knowledgeRoute = '/conocimiento';
const Duration _bundleReadSlice = Duration(milliseconds: 50);
const int _bundleReadAttempts = 60;

SceneAction openDocument(String documentId) {
  return (stage) async {
    GoRouter.of(stage.appContext).go('/biblioteca/documento/$documentId');
    await stage.tester.pumpAndSettle();
  };
}

SceneAction openKnowledgeCatalogue() {
  return (stage) async {
    final settled = _knowledgeSectionsSettled(stage);
    GoRouter.of(stage.appContext).go(knowledgeRoute);
    for (var attempt = 0; attempt < _bundleReadAttempts; attempt++) {
      await stage.tester.pump();
      await stage.tester
          .runAsync(() => Future<void>.delayed(_bundleReadSlice));
      if (settled()) break;
    }
    await stage.tester.pumpAndSettle();
  };
}

SceneAction beginStepping() {
  return (stage) async => stage.tapIcon(Icons.skip_next);
}

SceneAction stepInto({required int times}) {
  return (stage) async {
    for (var step = 0; step < times; step++) {
      await stage.tapIcon(Icons.arrow_downward);
    }
  };
}

SceneAction runToEnd() {
  return (stage) async => stage.tapIcon(Icons.play_arrow);
}

SceneAction openTab(DocumentTabKind tab) {
  return (stage) async => stage.tapText(tabLabelOf(tab, stage.l10n));
}

SceneAction toggleCompanion() {
  return (stage) async => stage.tapIcon(Icons.crop_square);
}

SceneAction expandOutputPanel() {
  return (stage) async => stage.tapIcon(Icons.keyboard_arrow_up);
}

bool Function() _knowledgeSectionsSettled(SceneStage stage) {
  final entries = BlocProvider.of<KnowledgeCubit>(stage.appContext);
  final route = BlocProvider.of<LearningRouteCubit>(stage.appContext);
  final bank = BlocProvider.of<ExerciseBankCubit>(stage.appContext);
  return () =>
      entries.state.status == KnowledgeStatus.success &&
      route.state.status == LearningRouteStatus.success &&
      bank.state.status == ExerciseBankStatus.success;
}

String tabLabelOf(DocumentTabKind tab, AppLocalizations l10n) {
  return switch (tab) {
    DocumentTabKind.editor => l10n.tabEditor,
    DocumentTabKind.flowchart => l10n.tabDiagrams,
    DocumentTabKind.trace => l10n.tabTrace,
    DocumentTabKind.equivalentCode => l10n.tabEquivalentCode,
  };
}
