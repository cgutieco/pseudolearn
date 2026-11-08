import 'package:flutter_bloc/flutter_bloc.dart';
import '../application/account/account_cubit.dart';
import '../application/dashboard/dashboard_cubit.dart';
import '../application/dashboard/dashboard_loader.dart';
import '../application/diagram/diagram_cubit.dart';
import '../application/diagram/diagram_projection.dart';
import '../application/editor/editor_cubit.dart';
import '../application/execution/execution_cubit.dart';
import '../application/execution/execution_history_cubit.dart';
import '../application/export/export_cubit.dart';
import '../application/route/route_bank_cubit.dart';
import '../application/route/route_exercise_cubit.dart';
import '../application/route/route_index_cubit.dart';
import '../application/route/route_spec_links_cubit.dart';
import '../application/route/route_lesson_cubit.dart';
import '../application/route/session/exercise_session_cubit.dart';
import '../application/reference/reference_index_cubit.dart';
import '../application/reference/reference_section_cubit.dart';
import '../application/library/library_cubit.dart';
import '../application/onboarding/demo/guided_demo_cubit.dart';
import '../application/onboarding/demo/guided_demo_loader.dart';
import '../application/onboarding/onboarding_cubit.dart';
import '../application/settings/app_version_cubit.dart';
import '../application/settings/settings_cubit.dart';
import '../application/sync/sync_cubit.dart';
import '../application/trace/trace_cubit.dart';
import 'app_dependencies.dart';
import 'syntax_help_provider.dart';
import '../engine/execution/task_flow_projection.dart';
import '../engine/execution/task_structure_projection.dart';

List<BlocProvider> buildAppProviders(AppDependencies dependencies) {
  return [
    ...createDocumentProviders(dependencies),
    ...createKnowledgeProviders(dependencies),
    createDashboardProvider(dependencies),
    ...createOnboardingProviders(dependencies),
    ...createSettingsProviders(dependencies),
  ];
}

List<BlocProvider> createDocumentProviders(AppDependencies dependencies) {
  final (:execution, :executionHistory) = _createExecutionProviders(
    dependencies,
  );
  return [
    BlocProvider<LibraryCubit>(
      create: (_) => LibraryCubit(
        repository: dependencies.documentRepository,
        idGenerator: dependencies.identifiers,
        clock: dependencies.clock,
      ),
    ),
    createEditorProvider(dependencies),
    createSyntaxHelpProvider(dependencies),
    BlocProvider<ExecutionCubit>(create: (_) => execution),
    BlocProvider<ExecutionHistoryCubit>(create: (_) => executionHistory),
    BlocProvider<DiagramCubit>(
      create: (_) => DiagramCubit(
        flowchartBuilder: dependencies.flowchartBuilder,
        structogramBuilder: dependencies.structogramBuilder,
        classDiagramBuilder: dependencies.classDiagramBuilder,
      ),
    ),
    BlocProvider<TraceCubit>(
      create: (_) => TraceCubit(executionStates: execution.stream),
    ),
    BlocProvider<ExportCubit>(
      create: (_) => ExportCubit(
        exporter: dependencies.programExporter,
        executionStates: execution.stream,
      ),
    ),
    createSyncProvider(dependencies),
  ];
}

({ExecutionCubit execution, ExecutionHistoryCubit executionHistory})
_createExecutionProviders(AppDependencies dependencies) {
  final session = dependencies.createObservableExecutionSession?.call();
  final execution = ExecutionCubit(
    execution: session?.execution ?? dependencies.createProgramExecution(),
  );
  final history = ExecutionHistoryCubit(
    executionStates: execution.stream,
    observer: session?.observer,
    flowProjector: const TaskFlowProjection(),
    structureProjector: const TaskStructureProjection(),
  );
  return (execution: execution, executionHistory: history);
}

BlocProvider<EditorCubit> createEditorProvider(AppDependencies dependencies) {
  return BlocProvider<EditorCubit>(
    create: (_) => EditorCubit(
      repository: dependencies.documentRepository,
      analyzer: dependencies.programAnalyzer,
      completionSource: dependencies.completionSource,
      contextualCompletionSource: dependencies.contextualCompletionSource,
      keySource: dependencies.editorKeySource,
      sourceEditor: dependencies.sourceEditor,
      textEntry: dependencies.textEntryModality,
      clock: dependencies.clock,
    ),
  );
}

BlocProvider<SyncCubit> createSyncProvider(AppDependencies dependencies) {
  return BlocProvider<SyncCubit>(
    create: (_) => SyncCubit(
      coordinator: dependencies.syncCoordinator,
      connectivityMonitor: dependencies.connectivityMonitor,
      authGateway: dependencies.authGateway,
      repository: dependencies.documentRepository,
      syncQueue: dependencies.syncQueue,
    )..init(),
  );
}

BlocProvider<DashboardCubit> createDashboardProvider(
  AppDependencies dependencies,
) {
  return BlocProvider<DashboardCubit>(
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
  );
}

List<BlocProvider> createKnowledgeProviders(AppDependencies dependencies) {
  return [
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
    BlocProvider<RouteSpecLinksCubit>(
      create: (_) =>
          RouteSpecLinksCubit(repository: dependencies.routeRepository),
    ),
    BlocProvider<ReferenceIndexCubit>(
      create: (_) =>
          ReferenceIndexCubit(repository: dependencies.referenceRepository),
    ),
    BlocProvider<ReferenceSectionCubit>(
      create: (_) =>
          ReferenceSectionCubit(repository: dependencies.referenceRepository),
    ),
    ...createExerciseProviders(dependencies),
  ];
}

List<BlocProvider> createExerciseProviders(AppDependencies dependencies) {
  return [
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
  ];
}

List<BlocProvider> createOnboardingProviders(AppDependencies dependencies) {
  return [
    BlocProvider<OnboardingCubit>(
      lazy: false,
      create: (_) => OnboardingCubit(
        preferences: dependencies.preferences,
        routeRepository: dependencies.routeRepository,
        referenceRepository: dependencies.referenceRepository,
      )..init(),
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
  ];
}

List<BlocProvider> createSettingsProviders(AppDependencies dependencies) {
  return [
    BlocProvider<SettingsCubit>(
      create: (_) =>
          SettingsCubit(preferences: dependencies.preferences)..init(),
    ),
    BlocProvider<AppVersionCubit>(
      create: (_) =>
          AppVersionCubit(source: dependencies.appVersionSource)..init(),
    ),
    BlocProvider<AccountCubit>(
      lazy: false,
      create: (_) => AccountCubit(
        authGateway: dependencies.authGateway,
        incomingLinks: dependencies.incomingLinkSource,
        documentRepository: dependencies.documentRepository,
        accountDeletionGateway: dependencies.accountDeletionGateway,
        localAccountDataPurger: dependencies.localAccountDataPurger,
      )..init(),
    ),
  ];
}
