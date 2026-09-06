import 'dart:io';
import 'package:supabase/supabase.dart';
import '../data/auth/session_storage.dart';
import '../data/documents/file_document_repository.dart';
import '../data/index/metadata_index.dart';
import '../data/sync/sqlite_progress_sync_store.dart';
import '../data/sync/sqlite_sync_queue.dart';
import '../data/sync/supabase_document_store.dart';
import '../data/sync/supabase_progress_store.dart';
import '../data/sync/sync_drainer.dart';
import '../data/sync/sync_metadata_store.dart';
import '../data/sync/syncing_document_repository.dart';
import '../data/platform/connectivity_monitor_adapter.dart';
import '../domain/ports/auth_gateway.dart';
import '../domain/ports/clock.dart';
import '../domain/ports/connectivity_monitor.dart';
import '../domain/ports/document_repository.dart';
import '../domain/ports/identifier_generator.dart';
import '../domain/ports/remote_document_store.dart';
import '../domain/ports/remote_progress_store.dart';
import '../domain/ports/sync_coordinator.dart';
import '../domain/ports/sync_queue.dart';

final class SyncServices {
  final RemoteDocumentStore remoteStore;
  final RemoteProgressStore remoteProgressStore;
  final SyncQueue queue;
  final ConnectivityMonitor connectivity;
  final SyncCoordinator coordinator;
  final DocumentRepository repository;

  const SyncServices({
    required this.remoteStore,
    required this.remoteProgressStore,
    required this.queue,
    required this.connectivity,
    required this.coordinator,
    required this.repository,
  });
}

SupabaseClient buildSupabaseClient() {
  const sessionStorage = SecureSessionStorage();
  return SupabaseClient(
    const String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://placeholder.supabase.co'),
    const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'placeholder-anon-key'),
    authOptions: const AuthClientOptions(
      pkceAsyncStorage: GotrueSessionStorageAdapter(sessionStorage),
    ),
  );
}

SyncServices buildSyncServices({
  required MetadataIndex index,
  required Directory documentsDirectory,
  required SupabaseClient client,
  required AuthGateway authGateway,
  required IdentifierGenerator identifiers,
  required Clock clock,
}) {
  final fileRepo = FileDocumentRepository(directory: documentsDirectory, index: index);
  final queue = SqliteSyncQueue(index.database);
  final remoteStore = SupabaseDocumentStore(client: client);
  final remoteProgressStore = SupabaseProgressStore(client: client);
  final drainer = _buildSyncDrainer(
    index: index,
    authGateway: authGateway,
    remoteStore: remoteStore,
    remoteProgressStore: remoteProgressStore,
    fileRepo: fileRepo,
    queue: queue,
    identifiers: identifiers,
    clock: clock,
  );
  return SyncServices(
    remoteStore: remoteStore,
    remoteProgressStore: remoteProgressStore,
    queue: queue,
    connectivity: ConnectivityMonitorAdapter(),
    coordinator: drainer,
    repository: SyncingDocumentRepository(
      inner: fileRepo,
      queue: queue,
      identifiers: identifiers,
      clock: clock,
    ),
  );
}

SyncDrainer _buildSyncDrainer({
  required MetadataIndex index,
  required AuthGateway authGateway,
  required RemoteDocumentStore remoteStore,
  required RemoteProgressStore remoteProgressStore,
  required DocumentRepository fileRepo,
  required SyncQueue queue,
  required IdentifierGenerator identifiers,
  required Clock clock,
}) {
  return SyncDrainer(
    authGateway: authGateway,
    remoteStore: remoteStore,
    queue: queue,
    metadataStore: SyncMetadataStore(index.database),
    repository: fileRepo,
    identifiers: identifiers,
    clock: clock,
    remoteProgressStore: remoteProgressStore,
    progressSyncStore: SqliteProgressSyncStore(index.database),
  );
}
