import 'native_test_engine.dart';
import 'package:pseudolearn_app/composition/app_dependencies.dart';
import 'package:pseudolearn_app/domain/ports/account_deletion_gateway.dart';
import 'package:pseudolearn_app/domain/ports/auth_gateway.dart';
import 'package:pseudolearn_app/domain/ports/connectivity_monitor.dart';
import 'package:pseudolearn_app/domain/ports/document_repository.dart';
import 'package:pseudolearn_app/domain/ports/exercise_checker.dart';
import 'package:pseudolearn_app/domain/ports/incoming_link_source.dart';
import 'package:pseudolearn_app/domain/ports/knowledge_repository.dart';
import 'package:pseudolearn_app/domain/ports/local_account_data_purger.dart';
import 'package:pseudolearn_app/domain/ports/local_progress_store.dart';
import 'package:pseudolearn_app/domain/ports/preferences_store.dart';
import 'package:pseudolearn_app/domain/ports/program_construct_reader.dart';
import 'package:pseudolearn_app/domain/ports/program_exporter.dart';
import 'package:pseudolearn_app/domain/ports/progress_history.dart';
import 'package:pseudolearn_app/domain/ports/remote_progress_store.dart';
import 'package:pseudolearn_app/domain/ports/sync_coordinator.dart';
import 'package:pseudolearn_app/domain/ports/sync_queue.dart';
import 'package:pseudolearn_app/domain/ports/syntax_help_source.dart';
import 'package:pseudolearn_app/domain/ports/syntax_reference_source.dart';
import 'package:pseudolearn_app/composition/engine_services.dart';
import 'fake_account_deletion_gateway.dart';
import 'fake_auth_gateway.dart';
import 'fake_clock.dart';
import 'fake_connectivity_monitor.dart';
import 'fake_exercise_checker.dart';
import 'fake_identifier_generator.dart';
import 'fake_incoming_link_source.dart';
import 'fake_knowledge_repository.dart';
import 'fake_program_construct_reader.dart';
import 'fake_program_exporter.dart';
import 'fake_local_account_data_purger.dart';
import 'fake_remote_progress_store.dart';
import 'fake_sync_coordinator.dart';
import 'fake_sync_queue.dart';
import 'fake_syntax_help_source.dart';
import 'fake_syntax_reference_source.dart';
import 'fake_app_version_source.dart';
import 'fake_text_entry_modality.dart';
import 'in_memory_document_repository.dart';
import 'in_memory_local_progress_store.dart';
import 'in_memory_preferences_store.dart';
import 'in_memory_progress_history.dart';

AppDependencies buildTestDependencies({
  DocumentRepository? repository,
  FakeIdentifierGenerator? identifiers,
  FakeClock? clock,
  KnowledgeRepository? knowledgeRepository,
  SyntaxReferenceSource? syntaxReferenceSource,
  SyntaxHelpSource? syntaxHelpSource,
  ProgramExporter? programExporter,
  LocalProgressStore? localProgressStore,
  ProgressHistory? progressHistory,
  ProgramConstructReader? programConstructReader,
  ExerciseChecker? exerciseChecker,
  PreferencesStore? preferences,
  AuthGateway? authGateway,
  IncomingLinkSource? incomingLinkSource,
  AccountDeletionGateway? accountDeletionGateway,
  LocalAccountDataPurger? localAccountDataPurger,
  RemoteProgressStore? remoteProgressStore,
  SyncQueue? syncQueue,
  ConnectivityMonitor? connectivityMonitor,
  SyncCoordinator? syncCoordinator,
  FakeTextEntryModality? textEntryModality,
  FakeAppVersionSource? appVersionSource,
  EngineServices? engine,
}) {
  return AppDependencies(
    clock: clock ?? FakeClock(DateTime(2026, 8, 15, 12, 0)),
    identifiers: identifiers ?? FakeIdentifierGenerator(),
    preferences: preferences ?? InMemoryPreferencesStore(),
    documentRepository: repository ?? InMemoryDocumentRepository(),
    authGateway: authGateway ?? FakeAuthGateway(),
    incomingLinkSource: incomingLinkSource ?? FakeIncomingLinkSource(),
    accountDeletionGateway:
        accountDeletionGateway ?? FakeAccountDeletionGateway(),
    localAccountDataPurger:
        localAccountDataPurger ?? FakeLocalAccountDataPurger(),
    remoteProgressStore: remoteProgressStore ?? FakeRemoteProgressStore(),
    syncQueue: syncQueue ?? FakeSyncQueue(),
    connectivityMonitor: connectivityMonitor ?? FakeConnectivityMonitor(),
    syncCoordinator: syncCoordinator ?? FakeSyncCoordinator(),
    programAnalyzer: engine?.analyzer ?? nativeTestEngine.analyzer,
    createProgramExecution:
        engine?.createProgramExecution ??
        nativeTestEngine.createProgramExecution,
    flowchartBuilder:
        engine?.flowchartBuilder ?? nativeTestEngine.flowchartBuilder,
    structogramBuilder:
        engine?.structogramBuilder ?? nativeTestEngine.structogramBuilder,
    classDiagramBuilder:
        engine?.classDiagramBuilder ?? nativeTestEngine.classDiagramBuilder,
    completionSource:
        engine?.completionSource ?? nativeTestEngine.completionSource,
    contextualCompletionSource: engine?.contextualCompletionSource,
    sourceEditor: engine?.sourceEditor ?? nativeTestEngine.sourceEditor,
    editorKeySource:
        engine?.editorKeySource ?? nativeTestEngine.editorKeySource,
    textEntryModality: textEntryModality ?? const FakeTextEntryModality(),
    appVersionSource: appVersionSource ?? const FakeAppVersionSource(),
    knowledgeRepository: knowledgeRepository ?? FakeKnowledgeRepository(),
    syntaxReferenceSource:
        syntaxReferenceSource ??
        engine?.syntaxReferenceSource ??
        FakeSyntaxReferenceSource(),
    syntaxHelpSource:
        syntaxHelpSource ??
        engine?.syntaxHelpSource ??
        FakeSyntaxHelpSource(),
    programExporter:
        programExporter ?? engine?.programExporter ?? FakeProgramExporter(),
    localProgressStore: localProgressStore ?? InMemoryLocalProgressStore(),
    progressHistory: progressHistory ?? InMemoryProgressHistory(),
    programConstructReader:
        programConstructReader ??
        engine?.programConstructReader ??
        FakeProgramConstructReader(),
    exerciseChecker:
        exerciseChecker ?? engine?.exerciseChecker ?? FakeExerciseChecker(),
  );
}
