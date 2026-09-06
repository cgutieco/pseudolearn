import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import '../data/auth/native_credential_source.dart';
import '../data/auth/supabase_auth_gateway.dart';
import '../data/index/metadata_index.dart';
import '../data/knowledge/bundled_knowledge_repository.dart';
import '../data/knowledge/marker_resolver.dart';
import '../data/platform/app_links_incoming_link_source.dart';
import '../data/platform/platform_text_entry_modality.dart';
import '../data/platform/random_identifier_generator.dart';
import '../data/platform/system_clock.dart';
import '../data/preferences/file_preferences_store.dart';
import '../data/progress/sqlite_progress_history.dart';
import '../domain/ports/auth_gateway.dart';
import '../domain/ports/clock.dart';
import '../domain/ports/exercise_checker.dart';
import '../domain/ports/identifier_generator.dart';
import '../domain/ports/incoming_link_source.dart';
import '../domain/ports/local_progress_store.dart';
import '../domain/ports/preferences_store.dart';
import '../domain/ports/program_analyzer.dart';
import '../domain/ports/progress_history.dart';
import '../domain/ports/syntax_reference_source.dart';
import '../engine/analysis/analysis_cache.dart';
import '../engine/analysis/core_program_analyzer.dart';
import '../engine/analysis/core_program_construct_reader.dart';
import '../engine/classdiagram/core_class_diagram_builder.dart';
import '../engine/completion/profile_completion_source.dart';
import '../engine/diagram/flowchart_layout.dart';
import '../engine/editing/lexicon_source_editor.dart';
import '../engine/editing/profile_key_source.dart';
import '../engine/execution/core_program_execution.dart';
import '../engine/exercise/behaviour_checker.dart';
import '../engine/exercise/exercise_check_runner.dart';
import '../engine/exercise/structural_assertion_checker.dart';
import '../engine/export/core_program_exporter.dart';
import '../engine/knowledge/syntax_reference_generator.dart';
import '../engine/structogram/structogram_layout.dart';
import 'app_dependencies.dart';
import 'sync_composition.dart';

final class _LocalStores {
  final PreferencesStore preferences;
  final LocalProgressStore progress;
  final ProgressHistory history;

  const _LocalStores({
    required this.preferences,
    required this.progress,
    required this.history,
  });
}

final class _EngineServices {
  final ProgramAnalyzer analyzer;
  final AnalysisCache analyses;
  final SyntaxReferenceSource syntaxReference;

  const _EngineServices({
    required this.analyzer,
    required this.analyses,
    required this.syntaxReference,
  });
}

AppDependencies buildLocalDependencies({
  required Directory documentsDirectory,
  required MetadataIndex index,
  required LocalProgressStore progressStore,
}) {
  final identifierGenerator = RandomIdentifierGenerator();
  final analyses = AnalysisCache();
  final supabaseClient = buildSupabaseClient();
  final authGateway = SupabaseAuthGateway(
    client: supabaseClient,
    credentialSource: PlatformNativeCredentialSource(),
  );
  const clock = SystemClock();
  return _assembleDependencies(
    clock: clock,
    identifiers: identifierGenerator,
    stores: _LocalStores(
      preferences: FilePreferencesStore(directory: documentsDirectory),
      progress: progressStore,
      history: SqliteProgressHistory(index.database),
    ),
    sync: buildSyncServices(
      index: index,
      documentsDirectory: documentsDirectory,
      client: supabaseClient,
      authGateway: authGateway,
      identifiers: identifierGenerator,
      clock: clock,
    ),
    authGateway: authGateway,
    incomingLinkSource: AppLinksIncomingLinkSource(),
    engine: _EngineServices(
      analyzer: CoreProgramAnalyzer(analyses: analyses),
      analyses: analyses,
      syntaxReference: const SyntaxReferenceGenerator(),
    ),
  );
}

AppDependencies _assembleDependencies({
  required Clock clock,
  required IdentifierGenerator identifiers,
  required _LocalStores stores,
  required SyncServices sync,
  required AuthGateway authGateway,
  required IncomingLinkSource incomingLinkSource,
  required _EngineServices engine,
}) {
  return AppDependencies(
    clock: clock,
    identifiers: identifiers,
    preferences: stores.preferences,
    documentRepository: sync.repository,
    authGateway: authGateway,
    incomingLinkSource: incomingLinkSource,
    remoteDocumentStore: sync.remoteStore,
    remoteProgressStore: sync.remoteProgressStore,
    syncQueue: sync.queue,
    connectivityMonitor: sync.connectivity,
    syncCoordinator: sync.coordinator,
    programAnalyzer: engine.analyzer,
    createProgramExecution: () => CoreProgramExecution(analyses: engine.analyses),
    flowchartBuilder: FlowchartLayout(analyses: engine.analyses),
    structogramBuilder: StructogramLayout(analyses: engine.analyses),
    classDiagramBuilder: CoreClassDiagramBuilder(analyses: engine.analyses),
    completionSource: const ProfileCompletionSource(),
    sourceEditor: const LexiconSourceEditor(),
    editorKeySource: const ProfileKeySource(),
    textEntryModality: const PlatformTextEntryModality(),
    knowledgeRepository: _buildKnowledgeRepository(engine.syntaxReference),
    syntaxReferenceSource: engine.syntaxReference,
    programExporter: CoreProgramExporter(analyses: engine.analyses),
    localProgressStore: stores.progress,
    progressHistory: stores.history,
    programConstructReader: CoreProgramConstructReader(analyses: engine.analyses),
    exerciseChecker: _buildExerciseChecker(engine.analyses, engine.analyzer),
  );
}

BundledKnowledgeRepository _buildKnowledgeRepository(
  SyntaxReferenceSource syntaxRef,
) {
  return BundledKnowledgeRepository(
    markers: MarkerResolver(reference: syntaxRef),
    assetLoader: rootBundle.loadString,
  );
}

ExerciseChecker _buildExerciseChecker(
  AnalysisCache analyses,
  ProgramAnalyzer analyzer,
) {
  return ExerciseCheckRunner(
    behaviour: BehaviourChecker(
      execution: CoreProgramExecution(analyses: analyses),
      analyzer: analyzer,
    ),
    structure: StructuralAssertionChecker(analyses: analyses),
  );
}
