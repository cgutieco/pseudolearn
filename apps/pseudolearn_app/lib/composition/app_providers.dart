import 'package:flutter_bloc/flutter_bloc.dart';
import '../application/account/account_cubit.dart';
import '../application/dashboard/dashboard_cubit.dart';
import '../application/dashboard/dashboard_loader.dart';
import '../application/diagram/diagram_cubit.dart';
import '../application/diagram/diagram_projection.dart';
import '../application/editor/editor_cubit.dart';
import '../application/execution/execution_cubit.dart';
import '../application/export/export_cubit.dart';
import '../application/knowledge/bank/exercise_bank_cubit.dart';
import '../application/knowledge/diagram_block_resolver.dart';
import '../application/knowledge/knowledge_cubit.dart';
import '../application/knowledge/knowledge_detail_cubit.dart';
import '../application/knowledge/prediction/prediction_session_cubit.dart';
import '../application/knowledge/route/learning_route_cubit.dart';
import '../application/knowledge/session/exercise_session_cubit.dart';
import '../application/knowledge/spec/specification_cubit.dart';
import '../application/library/library_cubit.dart';
import '../application/onboarding/demo/guided_demo_cubit.dart';
import '../application/onboarding/demo/guided_demo_loader.dart';
import '../application/onboarding/onboarding_cubit.dart';
import '../application/settings/settings_cubit.dart';
import '../application/sync/sync_cubit.dart';
import '../application/trace/trace_cubit.dart';
import 'app_dependencies.dart';

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
  final execution = ExecutionCubit(
    execution: dependencies.createProgramExecution(),
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
    BlocProvider<ExecutionCubit>(create: (_) => execution),
    BlocProvider<DiagramCubit>(
      create: (_) => DiagramCubit(
        flowchartBuilder: dependencies.flowchartBuilder,
        structogramBuilder: dependencies.structogramBuilder,
        classDiagramBuilder: dependencies.classDiagramBuilder,
      ),
    ),
    BlocProvider<TraceCubit>(
        create: (_) => TraceCubit(executionStates: execution.stream)),
    BlocProvider<ExportCubit>(
      create: (_) => ExportCubit(
        exporter: dependencies.programExporter,
        executionStates: execution.stream,
      ),
    ),
    createSyncProvider(dependencies),
  ];
}

BlocProvider<EditorCubit> createEditorProvider(AppDependencies dependencies) {
  return BlocProvider<EditorCubit>(
    create: (_) => EditorCubit(
      repository: dependencies.documentRepository,
      analyzer: dependencies.programAnalyzer,
      completionSource: dependencies.completionSource,
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
    AppDependencies dependencies) {
  return BlocProvider<DashboardCubit>(
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
  );
}

List<BlocProvider> createKnowledgeProviders(AppDependencies dependencies) {
  return [
    BlocProvider<KnowledgeCubit>(
      create: (_) => KnowledgeCubit(
        repository: dependencies.knowledgeRepository,
        referenceSource: dependencies.syntaxReferenceSource,
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
    BlocProvider<LearningRouteCubit>(
      create: (_) => LearningRouteCubit(
        repository: dependencies.knowledgeRepository,
        progressStore: dependencies.localProgressStore,
      ),
    ),
    BlocProvider<SpecificationCubit>(
      create: (_) => SpecificationCubit(
        repository: dependencies.knowledgeRepository,
      ),
    ),
    ...createExerciseProviders(dependencies),
  ];
}

List<BlocProvider> createExerciseProviders(AppDependencies dependencies) {
  return [
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
    BlocProvider<PredictionSessionCubit>(
      create: (_) => PredictionSessionCubit(
        repository: dependencies.knowledgeRepository,
        execution: dependencies.createProgramExecution(),
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
        knowledgeRepository: dependencies.knowledgeRepository,
      )..init(),
    ),
    BlocProvider<GuidedDemoCubit>(
      create: (_) => GuidedDemoCubit(
        loader: GuidedDemoLoader(repository: dependencies.knowledgeRepository),
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
    BlocProvider<AccountCubit>(
      lazy: false,
      create: (_) => AccountCubit(
        authGateway: dependencies.authGateway,
        incomingLinks: dependencies.incomingLinkSource,
        documentRepository: dependencies.documentRepository,
        remoteDocumentStore: dependencies.remoteDocumentStore,
      )..init(),
    ),
  ];
}
