import 'package:pseudolearn_app/composition/app_dependencies.dart';
import 'package:pseudolearn_app/domain/ports/auth_gateway.dart';
import 'package:pseudolearn_app/domain/ports/connectivity_monitor.dart';
import 'package:pseudolearn_app/domain/ports/document_repository.dart';
import 'package:pseudolearn_app/domain/ports/exercise_checker.dart';
import 'package:pseudolearn_app/domain/ports/incoming_link_source.dart';
import 'package:pseudolearn_app/domain/ports/knowledge_repository.dart';
import 'package:pseudolearn_app/domain/ports/local_progress_store.dart';
import 'package:pseudolearn_app/domain/ports/preferences_store.dart';
import 'package:pseudolearn_app/domain/ports/program_construct_reader.dart';
import 'package:pseudolearn_app/domain/ports/program_exporter.dart';
import 'package:pseudolearn_app/domain/ports/progress_history.dart';
import 'package:pseudolearn_app/domain/ports/remote_document_store.dart';
import 'package:pseudolearn_app/domain/ports/remote_progress_store.dart';
import 'package:pseudolearn_app/domain/ports/sync_coordinator.dart';
import 'package:pseudolearn_app/domain/ports/sync_queue.dart';
import 'package:pseudolearn_app/domain/ports/syntax_reference_source.dart';
import 'package:pseudolearn_app/engine/analysis/core_program_analyzer.dart';
import 'package:pseudolearn_app/engine/completion/profile_completion_source.dart';
import 'package:pseudolearn_app/engine/editing/lexicon_source_editor.dart';
import 'package:pseudolearn_app/engine/editing/profile_key_source.dart';
import 'package:pseudolearn_app/engine/classdiagram/core_class_diagram_builder.dart';
import 'package:pseudolearn_app/engine/diagram/flowchart_layout.dart';
import 'package:pseudolearn_app/engine/structogram/structogram_layout.dart';
import 'package:pseudolearn_app/engine/execution/core_program_execution.dart';
import 'fake_auth_gateway.dart';
import 'fake_clock.dart';
import 'fake_connectivity_monitor.dart';
import 'fake_exercise_checker.dart';
import 'fake_identifier_generator.dart';
import 'fake_incoming_link_source.dart';
import 'fake_knowledge_repository.dart';
import 'fake_program_construct_reader.dart';
import 'fake_program_exporter.dart';
import 'fake_remote_document_store.dart';
import 'fake_remote_progress_store.dart';
import 'fake_sync_coordinator.dart';
import 'fake_sync_queue.dart';
import 'fake_syntax_reference_source.dart';
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
  ProgramExporter? programExporter,
  LocalProgressStore? localProgressStore,
  ProgressHistory? progressHistory,
  ProgramConstructReader? programConstructReader,
  ExerciseChecker? exerciseChecker,
  PreferencesStore? preferences,
  AuthGateway? authGateway,
  IncomingLinkSource? incomingLinkSource,
  RemoteDocumentStore? remoteDocumentStore,
  RemoteProgressStore? remoteProgressStore,
  SyncQueue? syncQueue,
  ConnectivityMonitor? connectivityMonitor,
  SyncCoordinator? syncCoordinator,
  FakeTextEntryModality? textEntryModality,
}) {
  return AppDependencies(
    clock: clock ?? FakeClock(DateTime(2026, 8, 15, 12, 0)),
    identifiers: identifiers ?? FakeIdentifierGenerator(),
    preferences: preferences ?? InMemoryPreferencesStore(),
    documentRepository: repository ?? InMemoryDocumentRepository(),
    authGateway: authGateway ?? FakeAuthGateway(),
    incomingLinkSource: incomingLinkSource ?? FakeIncomingLinkSource(),
    remoteDocumentStore: remoteDocumentStore ?? FakeRemoteDocumentStore(),
    remoteProgressStore: remoteProgressStore ?? FakeRemoteProgressStore(),
    syncQueue: syncQueue ?? FakeSyncQueue(),
    connectivityMonitor: connectivityMonitor ?? FakeConnectivityMonitor(),
    syncCoordinator: syncCoordinator ?? FakeSyncCoordinator(),
    programAnalyzer: CoreProgramAnalyzer(),
    createProgramExecution: CoreProgramExecution.new,
    flowchartBuilder: FlowchartLayout(),
    structogramBuilder: StructogramLayout(),
    classDiagramBuilder: CoreClassDiagramBuilder(),
    completionSource: const ProfileCompletionSource(),
    sourceEditor: const LexiconSourceEditor(),
    editorKeySource: const ProfileKeySource(),
    textEntryModality: textEntryModality ?? const FakeTextEntryModality(),
    knowledgeRepository: knowledgeRepository ?? FakeKnowledgeRepository(),
    syntaxReferenceSource: syntaxReferenceSource ?? FakeSyntaxReferenceSource(),
    programExporter: programExporter ?? FakeProgramExporter(),
    localProgressStore: localProgressStore ?? InMemoryLocalProgressStore(),
    progressHistory: progressHistory ?? InMemoryProgressHistory(),
    programConstructReader:
        programConstructReader ?? FakeProgramConstructReader(),
    exerciseChecker: exerciseChecker ?? FakeExerciseChecker(),
  );
}
