import '../domain/ports/auth_gateway.dart';
import '../domain/ports/class_diagram_builder.dart';
import '../domain/ports/clock.dart';
import '../domain/ports/completion_source.dart';
import '../domain/ports/connectivity_monitor.dart';
import '../domain/ports/document_repository.dart';
import '../domain/ports/editor_key_source.dart';
import '../domain/ports/exercise_checker.dart';
import '../domain/ports/flowchart_builder.dart';
import '../domain/ports/identifier_generator.dart';
import '../domain/ports/incoming_link_source.dart';
import '../domain/ports/knowledge_repository.dart';
import '../domain/ports/local_progress_store.dart';
import '../domain/ports/preferences_store.dart';
import '../domain/ports/program_analyzer.dart';
import '../domain/ports/program_construct_reader.dart';
import '../domain/ports/program_execution.dart';
import '../domain/ports/program_exporter.dart';
import '../domain/ports/progress_history.dart';
import '../domain/ports/remote_document_store.dart';
import '../domain/ports/remote_progress_store.dart';
import '../domain/ports/source_editor.dart';
import '../domain/ports/structogram_builder.dart';
import '../domain/ports/sync_coordinator.dart';
import '../domain/ports/sync_queue.dart';
import '../domain/ports/syntax_reference_source.dart';
import '../domain/ports/text_entry_modality.dart';

final class AppDependencies {
  final Clock clock;
  final IdentifierGenerator identifiers;
  final PreferencesStore preferences;
  final DocumentRepository documentRepository;
  final AuthGateway authGateway;
  final IncomingLinkSource incomingLinkSource;
  final RemoteDocumentStore remoteDocumentStore;
  final RemoteProgressStore remoteProgressStore;
  final SyncQueue syncQueue;
  final ConnectivityMonitor connectivityMonitor;
  final SyncCoordinator syncCoordinator;
  final ProgramAnalyzer programAnalyzer;
  final ProgramExecution Function() createProgramExecution;
  final FlowchartBuilder flowchartBuilder;
  final StructogramBuilder structogramBuilder;
  final ClassDiagramBuilder classDiagramBuilder;
  final CompletionSource completionSource;
  final SourceEditor sourceEditor;
  final EditorKeySource editorKeySource;
  final TextEntryModality textEntryModality;
  final KnowledgeRepository knowledgeRepository;
  final SyntaxReferenceSource syntaxReferenceSource;
  final ProgramExporter programExporter;
  final LocalProgressStore localProgressStore;
  final ProgressHistory progressHistory;
  final ProgramConstructReader programConstructReader;
  final ExerciseChecker exerciseChecker;

  const AppDependencies({
    required this.clock,
    required this.identifiers,
    required this.preferences,
    required this.documentRepository,
    required this.authGateway,
    required this.incomingLinkSource,
    required this.remoteDocumentStore,
    required this.remoteProgressStore,
    required this.syncQueue,
    required this.connectivityMonitor,
    required this.syncCoordinator,
    required this.programAnalyzer,
    required this.createProgramExecution,
    required this.flowchartBuilder,
    required this.structogramBuilder,
    required this.classDiagramBuilder,
    required this.completionSource,
    required this.sourceEditor,
    required this.editorKeySource,
    required this.textEntryModality,
    required this.knowledgeRepository,
    required this.syntaxReferenceSource,
    required this.programExporter,
    required this.localProgressStore,
    required this.progressHistory,
    required this.programConstructReader,
    required this.exerciseChecker,
  });
}
