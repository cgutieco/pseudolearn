import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/reference/reference_index_cubit.dart';
import 'package:pseudolearn_app/application/reference/reference_section_cubit.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_run.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_section.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_section_kind.dart';
import '../../fakes/fake_reference_repository.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';
import 'package:go_router/go_router.dart';
import 'package:pseudolearn_app/application/dashboard/dashboard_cubit.dart';
import 'package:pseudolearn_app/application/dashboard/dashboard_loader.dart';
import 'package:pseudolearn_app/application/diagram/diagram_cubit.dart';
import 'package:pseudolearn_app/application/editor/editor_cubit.dart';
import 'package:pseudolearn_app/application/execution/execution_cubit.dart';
import 'package:pseudolearn_app/application/library/library_cubit.dart';
import 'package:pseudolearn_app/application/diagram/diagram_projection.dart';
import 'package:pseudolearn_app/application/onboarding/demo/guided_demo_cubit.dart';
import 'package:pseudolearn_app/application/onboarding/demo/guided_demo_loader.dart';
import 'package:pseudolearn_app/application/onboarding/onboarding_cubit.dart';
import 'package:pseudolearn_app/application/settings/app_version_cubit.dart';
import 'package:pseudolearn_app/application/settings/settings_cubit.dart';
import 'package:pseudolearn_app/application/sync/sync_cubit.dart';
import 'package:pseudolearn_app/application/trace/trace_cubit.dart';
import 'package:pseudolearn_app/composition/app_dependencies.dart';
import 'package:pseudolearn_app/application/route/route_bank_cubit.dart';
import 'package:pseudolearn_app/application/route/route_exercise_cubit.dart';
import 'package:pseudolearn_app/application/route/route_index_cubit.dart';
import 'package:pseudolearn_app/application/route/route_lesson_cubit.dart';
import 'package:pseudolearn_app/application/route/session/exercise_session_cubit.dart';
import 'package:pseudolearn_app/presentation/knowledge/knowledge_page.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/routing/app_router.dart';
import 'package:pseudolearn_app/presentation/shell/adaptive_shell.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/shell/destinations.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';
import '../../fakes/fake_route_repository.dart';
import '../../fakes/route_fixtures.dart';
import '../../fakes/test_dependencies.dart';

Widget _appWith(GoRouter router, [AppDependencies? deps]) {
  final dependencies = deps ?? buildTestDependencies();
  return MultiBlocProvider(
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
        create: (_) => ExecutionCubit(execution: dependencies.createProgramExecution()),
      ),
      BlocProvider<DiagramCubit>(
        create: (_) => DiagramCubit(
          flowchartBuilder: dependencies.flowchartBuilder,
          structogramBuilder: dependencies.structogramBuilder,
          classDiagramBuilder: dependencies.classDiagramBuilder,
        ),
      ),
      BlocProvider<TraceCubit>(
          create: (_) => TraceCubit(executionStates: const Stream<ExecutionState>.empty()),
        ),
      BlocProvider<ReferenceIndexCubit>(
        create: (_) => ReferenceIndexCubit(repository: dependencies.referenceRepository),
      ),
      BlocProvider<ReferenceSectionCubit>(
        create: (_) => ReferenceSectionCubit(repository: dependencies.referenceRepository),
      ),
      BlocProvider<RouteIndexCubit>(
        create: (_) => RouteIndexCubit(
          repository: dependencies.routeRepository,
          progressStore: dependencies.localProgressStore,
        ),
      ),
      BlocProvider<RouteLessonCubit>(
        create: (_) => RouteLessonCubit(
          repository: dependencies.routeRepository,
          progressStore: dependencies.localProgressStore,
        ),
      ),
      BlocProvider<RouteBankCubit>(
        create: (_) => RouteBankCubit(
          repository: dependencies.routeRepository,
          progressStore: dependencies.localProgressStore,
        ),
      ),
      BlocProvider<RouteExerciseCubit>(
        create: (_) => RouteExerciseCubit(
          repository: dependencies.routeRepository,
          progressStore: dependencies.localProgressStore,
          evaluators: dependencies.routeEvaluators,
        ),
      ),
      BlocProvider<ExerciseSessionCubit>(
        create: (_) => ExerciseSessionCubit(
          repository: dependencies.routeRepository,
          checker: dependencies.exerciseChecker,
          progressStore: dependencies.localProgressStore,
        ),
      ),
      BlocProvider<OnboardingCubit>(
        create: (_) => OnboardingCubit(
          preferences: dependencies.preferences,
          routeRepository: dependencies.routeRepository,
          referenceRepository: dependencies.referenceRepository,
        ),
      ),
      BlocProvider<GuidedDemoCubit>(
        create: (_) => GuidedDemoCubit(
          loader: GuidedDemoLoader(source: dependencies.demoProgramSource),
          execution: dependencies.createProgramExecution(),
          diagrams: DiagramProjection(
            flowchartBuilder: dependencies.flowchartBuilder,
            structogramBuilder: dependencies.structogramBuilder,
            classDiagramBuilder: dependencies.classDiagramBuilder,
          ),
        ),
      ),
      BlocProvider<SettingsCubit>(
        create: (_) => SettingsCubit(
          preferences: dependencies.preferences,
        ),
      ),
      BlocProvider<AppVersionCubit>(
        create: (_) => AppVersionCubit(source: dependencies.appVersionSource),
      ),
      BlocProvider<DashboardCubit>(
        create: (_) => DashboardCubit(
          loader: DashboardLoader(
            documents: dependencies.documentRepository,
            route: dependencies.routeRepository,
            reference: dependencies.referenceRepository,
            progressHistory: dependencies.progressHistory,
            syncQueue: dependencies.syncQueue,
            constructReader: dependencies.programConstructReader,
            clock: dependencies.clock,
          ),
        ),
      ),
      BlocProvider<SyncCubit>(
        create: (_) => SyncCubit(
          coordinator: dependencies.syncCoordinator,
          connectivityMonitor: dependencies.connectivityMonitor,
          authGateway: dependencies.authGateway,
          repository: dependencies.documentRepository,
          syncQueue: dependencies.syncQueue,
        ),
      ),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      theme: AppTheme.light(),
      locale: const Locale('es'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => DesignCanvas(child: child ?? const SizedBox.shrink()),
    ),
  );
}

void main() {
  group('buildAppRouter (CIM-F5)', () {
    testWidgets('starts at the first destination and shows its label', (tester) async {
      await tester.pumpWidget(_appWith(buildAppRouter()));
      await tester.pumpAndSettle();

      final l10n = await AppLocalizations.delegate.load(const Locale('es'));
      expect(find.text(l10n.navLibrary), findsWidgets);
    });

    testWidgets('every destination route resolves without throwing', (tester) async {
      for (final destination in appDestinations) {
        final router = buildAppRouter();
        router.go(destination.path);
        await tester.pumpWidget(_appWith(router));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('StatefulShellRoute branch state preservation (README §3.5)', () {
    testWidgets('switching destination and back keeps the text a branch held', (tester) async {
      final router = GoRouter(
        initialLocation: '/one',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) =>
                AdaptiveShell(navigationShell: navigationShell),
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(path: '/one', builder: (context, state) => const _StatefulField(fieldKey: Key('field-one'))),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(path: '/two', builder: (context, state) => const _StatefulField(fieldKey: Key('field-two'))),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(path: '/three', builder: (context, state) => const _StatefulField(fieldKey: Key('field-three'))),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(_appWith(router));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('field-one')), 'kept across branches');
      await tester.pumpAndSettle();

      router.go('/two');
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('field-one')), findsNothing);

      router.go('/one');
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byKey(const Key('field-one')));
      expect(textField.controller!.text, 'kept across branches');
    });
  });

  group('Learning route navigation flow', () {
    testWidgets('a specification link from a lesson returns to the lesson on pop', (tester) async {
      final routes = FakeRouteRepository(
        toc: sampleToc,
        lessons: {'inicio.primero': sampleLesson('inicio.primero')},
      );
      final references = FakeReferenceRepository(
        sections: const {
          'lexico.palabras-reservadas': ReferenceSection(
            id: 'lexico.palabras-reservadas',
            number: '2.5',
            kind: ReferenceSectionKind.concept,
            title: [ReferenceTextRun('Estructura léxica')],
            phrase: [],
            blocks: [],
          ),
        },
      );
      final deps = buildTestDependencies(
        routeRepository: routes,
        referenceRepository: references,
      );
      final router = buildAppRouter(initialLocation: '/conocimiento');
      await tester.pumpWidget(_appWith(router, deps));
      await tester.pumpAndSettle();

      unawaited(router.push('/conocimiento/ruta/inicio.primero'));
      await tester.pumpAndSettle();
      expect(find.text('Una frase'), findsWidgets);

      unawaited(router.push('/conocimiento/especificacion/lexico.palabras-reservadas'));
      await tester.pumpAndSettle();
      expect(find.text('Estructura léxica'), findsWidgets);

      router.pop();
      await tester.pumpAndSettle();
      expect(find.text('Una frase'), findsWidgets);

      router.pop();
      await tester.pumpAndSettle();
      expect(find.byType(KnowledgePage), findsOneWidget);
    });
  });
}

final class _StatefulField extends StatefulWidget {
  final Key fieldKey;

  const _StatefulField({required this.fieldKey});

  @override
  State<_StatefulField> createState() => _StatefulFieldState();
}

final class _StatefulFieldState extends State<_StatefulField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TextField(key: widget.fieldKey, controller: _controller),
    );
  }
}
