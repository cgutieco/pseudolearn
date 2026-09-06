import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';
import 'package:go_router/go_router.dart';
import 'package:pseudolearn_app/application/dashboard/dashboard_cubit.dart';
import 'package:pseudolearn_app/application/dashboard/dashboard_loader.dart';
import 'package:pseudolearn_app/application/diagram/diagram_cubit.dart';
import 'package:pseudolearn_app/application/editor/editor_cubit.dart';
import 'package:pseudolearn_app/application/execution/execution_cubit.dart';
import 'package:pseudolearn_app/application/knowledge/bank/exercise_bank_cubit.dart';
import 'package:pseudolearn_app/application/knowledge/diagram_block_resolver.dart';
import 'package:pseudolearn_app/application/knowledge/knowledge_cubit.dart';
import 'package:pseudolearn_app/application/knowledge/knowledge_detail_cubit.dart';
import 'package:pseudolearn_app/application/knowledge/route/learning_route_cubit.dart';
import 'package:pseudolearn_app/application/knowledge/session/exercise_session_cubit.dart';
import 'package:pseudolearn_app/application/library/library_cubit.dart';
import 'package:pseudolearn_app/application/diagram/diagram_projection.dart';
import 'package:pseudolearn_app/application/onboarding/demo/guided_demo_cubit.dart';
import 'package:pseudolearn_app/application/onboarding/demo/guided_demo_loader.dart';
import 'package:pseudolearn_app/application/onboarding/onboarding_cubit.dart';
import 'package:pseudolearn_app/application/settings/settings_cubit.dart';
import 'package:pseudolearn_app/application/sync/sync_cubit.dart';
import 'package:pseudolearn_app/application/trace/trace_cubit.dart';
import 'package:pseudolearn_app/composition/app_dependencies.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_block.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry_type.dart';
import 'package:pseudolearn_app/domain/model/knowledge/learning_module.dart';
import 'package:pseudolearn_app/domain/model/knowledge/learning_track.dart';
import 'package:pseudolearn_app/domain/model/knowledge/module_part.dart';
import 'package:pseudolearn_app/domain/model/knowledge/module_section.dart';
import 'package:pseudolearn_app/presentation/knowledge/knowledge_page.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/routing/app_router.dart';
import 'package:pseudolearn_app/presentation/shell/adaptive_shell.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/shell/destinations.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';
import '../../fakes/fake_knowledge_repository.dart';
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
      BlocProvider<KnowledgeCubit>(
        create: (_) => KnowledgeCubit(
          repository: dependencies.knowledgeRepository,
          referenceSource: dependencies.syntaxReferenceSource,
        ),
      ),
      BlocProvider<LearningRouteCubit>(
        create: (_) => LearningRouteCubit(
          repository: dependencies.knowledgeRepository,
          progressStore: dependencies.localProgressStore,
        ),
      ),
      BlocProvider<ExerciseBankCubit>(
        create: (_) => ExerciseBankCubit(
          repository: dependencies.knowledgeRepository,
          progressStore: dependencies.localProgressStore,
        ),
      ),
      BlocProvider<ExerciseSessionCubit>(
        create: (_) => ExerciseSessionCubit(
          repository: dependencies.knowledgeRepository,
          checker: dependencies.exerciseChecker,
          progressStore: dependencies.localProgressStore,
        ),
      ),
      BlocProvider<KnowledgeDetailCubit>(
        create: (_) => KnowledgeDetailCubit(
          repository: dependencies.knowledgeRepository,
          referenceSource: dependencies.syntaxReferenceSource,
          analyzer: dependencies.programAnalyzer,
          progressStore: dependencies.localProgressStore,
          diagramResolver: DiagramBlockResolver(
            flowchartBuilder: dependencies.flowchartBuilder,
            structogramBuilder: dependencies.structogramBuilder,
            classDiagramBuilder: dependencies.classDiagramBuilder,
          ),
        ),
      ),
      BlocProvider<OnboardingCubit>(
        create: (_) => OnboardingCubit(
          preferences: dependencies.preferences,
          knowledgeRepository: dependencies.knowledgeRepository,
        ),
      ),
      BlocProvider<GuidedDemoCubit>(
        create: (_) => GuidedDemoCubit(
          loader: GuidedDemoLoader(
            repository: dependencies.knowledgeRepository,
          ),
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
      BlocProvider<DashboardCubit>(
        create: (_) => DashboardCubit(
          loader: DashboardLoader(
            documents: dependencies.documentRepository,
            knowledge: dependencies.knowledgeRepository,
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

  group('Knowledge detail navigation flow', () {
    testWidgets('pushing specification from module preserves module state on pop', (tester) async {
      const moduleEntry = KnowledgeEntry(
        id: 'CON-A1',
        type: KnowledgeEntryType.module,
        title: 'Qué es un algoritmo',
        summary: 'Secuencia, precisión y ambigüedad.',
        path: 'modules/CON-A1_es.md',
        track: LearningTrack.foundations,
      );
      const specEntry = KnowledgeEntry(
        id: 'esp-i-lexico',
        type: KnowledgeEntryType.specificationSection,
        title: 'Estructura léxica',
        summary: 'Caracteres, comentarios e identificadores.',
        path: 'specification/esp-i-lexico_es.md',
      );
      const module = LearningModule(
        id: 'CON-A1',
        track: LearningTrack.foundations,
        order: 1,
        title: 'Qué es un algoritmo',
        sections: [
          ModuleSection(
            part: ModulePart.question,
            blocks: [ParagraphBlock(text: 'Introducción.')],
          ),
        ],
      );

      final fakeRepo = FakeKnowledgeRepository(
        entries: const [moduleEntry, specEntry],
        modulesByEntryId: {'CON-A1': module},
        blocksByPath: {
          'specification/esp-i-lexico_es.md': const [
            ParagraphBlock(text: 'Estructura léxica.'),
          ],
        },
      );
      final deps = buildTestDependencies(knowledgeRepository: fakeRepo);
      final router = buildAppRouter(initialLocation: '/conocimiento');
      await tester.pumpWidget(_appWith(router, deps));
      await tester.pumpAndSettle();

      unawaited(router.push('/conocimiento/CON-A1'));
      await tester.pumpAndSettle();
      expect(find.text('Qué es un algoritmo'), findsWidgets);

      unawaited(router.push('/conocimiento/esp-i-lexico?fromModule=CON-A1'));
      await tester.pumpAndSettle();
      expect(find.text('Estructura léxica'), findsWidgets);

      router.pop();
      await tester.pumpAndSettle();
      expect(find.text('Qué es un algoritmo'), findsWidgets);

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
