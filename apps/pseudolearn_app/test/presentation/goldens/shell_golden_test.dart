import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';
import 'package:pseudolearn_app/application/diagram/diagram_cubit.dart';
import 'package:pseudolearn_app/application/editor/editor_cubit.dart';
import 'package:pseudolearn_app/application/execution/execution_cubit.dart';
import 'package:pseudolearn_app/application/library/library_cubit.dart';
import 'package:pseudolearn_app/application/trace/trace_cubit.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/routing/app_router.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';
import '../../fakes/test_dependencies.dart';

Future<void> _pumpShell(WidgetTester tester, Size size, ThemeData theme) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final dependencies = buildTestDependencies();

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<LibraryCubit>(
          create: (_) => LibraryCubit(
            repository: dependencies.documentRepository,
            idGenerator: dependencies.identifiers,
            clock: dependencies.clock,
          ),
        ),
        BlocProvider<EditorCubit>(
          create: (_) => EditorCubit(
            repository: dependencies.documentRepository,
            analyzer: dependencies.programAnalyzer,
            completionSource: dependencies.completionSource,
            keySource: dependencies.editorKeySource,
            sourceEditor: dependencies.sourceEditor,
            textEntry: dependencies.textEntryModality,
            clock: dependencies.clock,
          ),
        ),
        BlocProvider<ExecutionCubit>(
          create: (_) =>
              ExecutionCubit(execution: dependencies.createProgramExecution()),
        ),
        BlocProvider<DiagramCubit>(
          create: (_) => DiagramCubit(
            flowchartBuilder: dependencies.flowchartBuilder,
            structogramBuilder: dependencies.structogramBuilder,
            classDiagramBuilder: dependencies.classDiagramBuilder,
          ),
        ),
        BlocProvider<TraceCubit>(
          create: (_) =>
              TraceCubit(executionStates: const Stream<ExecutionState>.empty()),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: buildAppRouter(),
        theme: theme,
        themeMode: ThemeMode.light,
        locale: const Locale('es'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) =>
            DesignCanvas(child: child ?? const SizedBox.shrink()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Empty adaptive shell goldens (CIM-F5) — three widths, two themes', () {
    final widths = <String, double>{
      'compact': 360,
      'compact_wide': 480,
      'medium': 600,
      'medium_wide': 800,
      'expanded': 960,
      'expanded_desktop': 1280,
      'expanded_wide': 1920,
      'expanded_ultrawide': 2560,
    };

    for (final entry in widths.entries) {
      testWidgets('${entry.key} · light', (tester) async {
        await _pumpShell(tester, Size(entry.value, 800), AppTheme.light());
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('shell_${entry.key}_light.png'),
        );
      });

      testWidgets('${entry.key} · dark', (tester) async {
        await _pumpShell(tester, Size(entry.value, 800), AppTheme.dark());
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('shell_${entry.key}_dark.png'),
        );
      });
    }
  });
}
