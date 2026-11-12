import 'package:cupertino_ui/cupertino_ui.dart' show GlobalCupertinoLocalizations;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart' show GlobalWidgetsLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/onboarding/demo/guided_demo_state.dart';
import 'package:pseudolearn_app/application/diagram/diagram_projection.dart';
import 'package:pseudolearn_app/application/diagram/diagram_state.dart';
import 'package:pseudolearn_app/application/onboarding/onboarding_state.dart';
import 'package:pseudolearn_app/application/trace/trace_rows_projection.dart';
import 'package:pseudolearn_app/application/trace/trace_state.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_notation.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_focus.dart';
import 'package:pseudolearn_app/domain/model/route/route_kinds.dart';
import 'package:pseudolearn_app/domain/model/onboarding/guided_demo_surface.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_step.dart';
import 'package:pseudolearn_app/domain/model/execution/watch_row.dart';
import 'package:pseudolearn_app/domain/model/onboarding/knowledge_highlights.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/onboarding/onboarding_view.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

import '../../fakes/fake_diagram_builders.dart';

const String demoCode = 'Clase Termometro\n'
    '    Privado Definir grados Como Entero;\n'
    'FinClase\n'
    'Proceso DemostracionGuiada\n'
    '    Definir sensor Como Termometro;\n'
    '    sensor <- Nuevo Termometro(30);\n'
    'FinProceso';

const KnowledgeHighlights demoHighlights = KnowledgeHighlights(
  parts: [
    RoutePartHighlight(number: '0', title: 'Empezar de cero', lessonCount: 4),
    RoutePartHighlight(number: 'I', title: 'Imperativo y estructurado', lessonCount: 9),
    RoutePartHighlight(number: 'II', title: 'Procedimental y modular', lessonCount: 8),
  ],
  exerciseLevels: [
    ExerciseLevelHighlight(level: RouteLevel.seed, count: 40),
    ExerciseLevelHighlight(level: RouteLevel.sprout, count: 35),
    ExerciseLevelHighlight(level: RouteLevel.tree, count: 20),
  ],
  lessonCount: 21,
  specificationCount: 22,
  exerciseCount: 95,
);

final DiagramState demoDiagram = DiagramProjection(
  flowchartBuilder: FakeFlowchartBuilder(),
  structogramBuilder: FakeStructogramBuilder(),
  classDiagramBuilder: FakeClassDiagramBuilder(classNames: const ['Termometro']),
).project(
  previous: const DiagramState.initial(),
  sourceCode: demoCode,
  profileId: SyntaxProfileId.classicSpanish,
  languageId: UiLanguageId.spanish,
);

final TraceState demoTrace = const TraceRowsProjection().opened(
  const TraceState.initial(),
  ExecutionStep(
    stepNumber: 1,
    scopeName: 'global',
    scopeDepth: 1,
    focus: focusAtLine(6),
    focusRevision: 1,
    variables: const [
      WatchRow(name: 'sensor', formattedValue: 'Termometro', scopeName: 'global'),
      WatchRow(name: 'actual', formattedValue: '30', scopeName: 'global'),
    ],
  ),
  focusAtLine(6),
);

ExecutionFocus focusAtLine(int line) {
  return ExecutionFocus(
    nodeId: ProgramNodeId(line),
    range: SourceRange(
      startOffset: line,
      endOffset: line + 1,
      startLine: line,
      startColumn: 1,
      endLine: line,
      endColumn: 2,
    ),
    kind: ExecutionFocusKind.statement,
  );
}

final class OnboardingProbe {
  final List<GuidedDemoSurface> surfaces = [];
  final List<DiagramNotation> notations = [];
  int nextCount = 0;
  int backCount = 0;
  int skipCount = 0;
  int createCount = 0;
  int exploreCount = 0;
  int stepCount = 0;
  int restartCount = 0;
}

Widget buildOnboardingApp({
  required OnboardingState state,
  GuidedDemoState demoState = const GuidedDemoState(),
  bool assistedDiagramZoom = true,
  OnboardingProbe? probe,
  ThemeData? theme,
  Locale locale = const Locale('es'),
  double textScale = 1.0,
}) {
  final calls = probe ?? OnboardingProbe();

  return MaterialApp(
    theme: theme ?? AppTheme.light(),
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScale),
      ),
      child: DesignCanvas(child: child ?? const SizedBox.shrink()),
    ),
    home: OnboardingView(
      state: state,
      demoState: demoState,
      assistedDiagramZoom: assistedDiagramZoom,
      onNext: () => calls.nextCount++,
      onBack: () => calls.backCount++,
      onSkip: () => calls.skipCount++,
      onCreateFirstDocument: () => calls.createCount++,
      onExploreRoute: () => calls.exploreCount++,
      onStep: () => calls.stepCount++,
      onRestart: () => calls.restartCount++,
      onSurfaceSelected: calls.surfaces.add,
      onNotationSelected: calls.notations.add,
    ),
  );
}

void sizeCanvas(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
