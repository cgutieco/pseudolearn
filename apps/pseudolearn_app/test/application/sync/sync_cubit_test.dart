import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/sync/sync_cubit.dart';
import 'package:pseudolearn_app/application/sync/sync_state.dart';
import 'package:pseudolearn_app/domain/model/account/account_session.dart';
import 'package:pseudolearn_app/domain/model/account/auth_method.dart';
import 'package:pseudolearn_app/domain/model/sync/sync_drain_outcome.dart';
import '../../fakes/fake_auth_gateway.dart';
import '../../fakes/fake_connectivity_monitor.dart';
import '../../fakes/fake_sync_coordinator.dart';
import '../../fakes/fake_sync_queue.dart';
import '../../fakes/in_memory_document_repository.dart';

void main() {
  group('SyncCubit', () {
    late FakeSyncCoordinator coordinator;
    late FakeConnectivityMonitor connectivity;
    late FakeAuthGateway authGateway;
    late InMemoryDocumentRepository repository;
    late FakeSyncQueue queue;
    late SyncCubit cubit;

    setUp(() {
      coordinator = FakeSyncCoordinator();
      connectivity = FakeConnectivityMonitor();
      authGateway = FakeAuthGateway();
      repository = InMemoryDocumentRepository();
      queue = FakeSyncQueue();
      cubit = SyncCubit(
        coordinator: coordinator,
        connectivityMonitor: connectivity,
        authGateway: authGateway,
        repository: repository,
        syncQueue: queue,
      );
    });

    tearDown(() async {
      await cubit.close();
      connectivity.dispose();
    });

    test('initial state is SyncIdle', () {
      expect(cubit.state, isA<SyncIdle>());
    });

    test('syncNow triggers coordinator.drain and emits SyncIdle on success', () async {
      authGateway.session = const AccountSession(
        userId: 'u1',
        email: 'u1@test.com',
        provider: AuthMethod.apple,
      );
      coordinator.outcome = SyncDrainOutcome.success;

      await cubit.syncNow();

      expect(coordinator.drainCallCount, equals(1));
      expect(cubit.state, isA<SyncIdle>());
    });

    test('syncNow emits SyncError on failure', () async {
      coordinator.outcome = SyncDrainOutcome.failure;

      await cubit.syncNow();

      expect(cubit.state, isA<SyncError>());
    });
  });
}
