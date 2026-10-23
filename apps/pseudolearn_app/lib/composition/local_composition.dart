import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:supabase/supabase.dart' show SupabaseClient;
import '../application/review/review_prompting_progress_store.dart';
import '../data/auth/native_credential_source.dart';
import '../data/auth/session_storage.dart';
import '../data/auth/supabase_account_deletion_gateway.dart';
import '../data/auth/supabase_auth_gateway.dart';
import '../data/auth/supabase_session_persistence.dart';
import '../data/index/metadata_index.dart';
import '../data/knowledge/bundled_knowledge_repository.dart';
import '../data/knowledge/marker_resolver.dart';
import '../data/platform/app_links_incoming_link_source.dart';
import '../data/platform/platform_app_version_source.dart';
import '../data/platform/platform_store_review_prompt.dart';
import '../data/platform/platform_text_entry_modality.dart';
import '../data/platform/random_identifier_generator.dart';
import '../data/platform/system_clock.dart';
import '../data/preferences/file_preferences_store.dart';
import '../data/progress/sqlite_progress_history.dart';
import '../domain/ports/account_deletion_gateway.dart';
import '../domain/ports/auth_gateway.dart';
import '../domain/ports/clock.dart';
import '../domain/ports/identifier_generator.dart';
import '../domain/ports/incoming_link_source.dart';
import '../domain/ports/local_progress_store.dart';
import '../domain/ports/preferences_store.dart';
import '../domain/ports/progress_history.dart';
import '../domain/ports/syntax_reference_source.dart';
import 'app_dependencies.dart';
import '../engine/rust/rust_transport.dart';
import 'engine_services.dart';
import 'rust_engine_services.dart';
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

final class _AccountServices {
  final AuthGateway authGateway;
  final AccountDeletionGateway deletionGateway;
  final IncomingLinkSource incomingLinks;

  const _AccountServices({
    required this.authGateway,
    required this.deletionGateway,
    required this.incomingLinks,
  });
}

final class _DependencyAssembly {
  final Clock clock;
  final IdentifierGenerator identifiers;
  final _LocalStores stores;
  final SyncServices sync;
  final _AccountServices account;
  final EngineServices engine;

  const _DependencyAssembly({
    required this.clock,
    required this.identifiers,
    required this.stores,
    required this.sync,
    required this.account,
    required this.engine,
  });
}

_AccountServices _buildAccountServices(SupabaseClient client) {
  final credentialSource = PlatformNativeCredentialSource();
  final sessionPersistence = SupabaseSessionPersistence(
    auth: client.auth,
    storage: const SecureSessionStorage(),
  )..start();
  return _AccountServices(
    authGateway: SupabaseAuthGateway(
      client: client,
      sessionPersistence: sessionPersistence,
      credentialSource: credentialSource,
    ),
    deletionGateway: SupabaseAccountDeletionGateway(
      client: client,
      credentialSource: credentialSource,
    ),
    incomingLinks: AppLinksIncomingLinkSource(),
  );
}

AppDependencies buildLocalDependencies({
  required Directory documentsDirectory,
  required MetadataIndex index,
  required LocalProgressStore progressStore,
  required RustTransport transport,
}) => _buildLocalDependencies(
  documentsDirectory: documentsDirectory,
  index: index,
  progressStore: progressStore,
  engine: buildRustEngineServices(transport),
);

AppDependencies _buildLocalDependencies({
  required Directory documentsDirectory,
  required MetadataIndex index,
  required LocalProgressStore progressStore,
  required EngineServices engine,
}) {
  final identifierGenerator = RandomIdentifierGenerator();
  final supabaseClient = buildSupabaseClient();
  final account = _buildAccountServices(supabaseClient);
  const clock = SystemClock();
  return _assembleDependencies(
    _DependencyAssembly(
      clock: clock,
      identifiers: identifierGenerator,
      stores: _LocalStores(
        preferences: FilePreferencesStore(directory: documentsDirectory),
        progress: ReviewPromptingProgressStore(
          inner: progressStore,
          prompt: const PlatformStoreReviewPrompt(),
        ),
        history: SqliteProgressHistory(index.database),
      ),
      sync: buildSyncServices(
        index: index,
        documentsDirectory: documentsDirectory,
        client: supabaseClient,
        authGateway: account.authGateway,
        identifiers: identifierGenerator,
        clock: clock,
      ),
      account: account,
      engine: engine,
    ),
  );
}

AppDependencies _assembleDependencies(_DependencyAssembly assembly) {
  return AppDependencies(
    clock: assembly.clock,
    identifiers: assembly.identifiers,
    preferences: assembly.stores.preferences,
    documentRepository: assembly.sync.repository,
    authGateway: assembly.account.authGateway,
    incomingLinkSource: assembly.account.incomingLinks,
    accountDeletionGateway: assembly.account.deletionGateway,
    localAccountDataPurger: assembly.sync.accountDataPurger,
    remoteProgressStore: assembly.sync.remoteProgressStore,
    syncQueue: assembly.sync.queue,
    connectivityMonitor: assembly.sync.connectivity,
    syncCoordinator: assembly.sync.coordinator,
    programAnalyzer: assembly.engine.analyzer,
    createProgramExecution: assembly.engine.createProgramExecution,
    flowchartBuilder: assembly.engine.flowchartBuilder,
    structogramBuilder: assembly.engine.structogramBuilder,
    classDiagramBuilder: assembly.engine.classDiagramBuilder,
    completionSource: assembly.engine.completionSource,
    contextualCompletionSource: assembly.engine.contextualCompletionSource,
    sourceEditor: assembly.engine.sourceEditor,
    editorKeySource: assembly.engine.editorKeySource,
    textEntryModality: const PlatformTextEntryModality(),
    appVersionSource: const PlatformAppVersionSource(),
    knowledgeRepository: _buildKnowledgeRepository(
      assembly.engine.syntaxReferenceSource,
    ),
    syntaxReferenceSource: assembly.engine.syntaxReferenceSource,
    syntaxHelpSource: assembly.engine.syntaxHelpSource,
    programExporter: assembly.engine.programExporter,
    localProgressStore: assembly.stores.progress,
    progressHistory: assembly.stores.history,
    programConstructReader: assembly.engine.programConstructReader,
    exerciseChecker: assembly.engine.exerciseChecker,
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
