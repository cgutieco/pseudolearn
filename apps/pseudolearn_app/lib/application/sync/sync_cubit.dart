import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../domain/model/sync/sync_drain_outcome.dart';
import '../../domain/ports/auth_gateway.dart';
import '../../domain/ports/connectivity_monitor.dart';
import '../../domain/ports/document_repository.dart';
import '../../domain/ports/sync_coordinator.dart';
import '../../domain/ports/sync_queue.dart';
import 'conflict_projection.dart';
import 'sync_state.dart';

final class SyncCubit extends Cubit<SyncState> {
  final SyncCoordinator _coordinator;
  final ConnectivityMonitor _connectivityMonitor;
  final AuthGateway _authGateway;
  final DocumentRepository _repository;
  final SyncQueue _syncQueue;
  final ConflictProjection _conflictProjection;

  StreamSubscription<bool>? _connectivitySub;
  StreamSubscription<dynamic>? _sessionSub;
  Timer? _debounceTimer;

  SyncCubit({
    required SyncCoordinator coordinator,
    required ConnectivityMonitor connectivityMonitor,
    required AuthGateway authGateway,
    required DocumentRepository repository,
    required SyncQueue syncQueue,
    ConflictProjection conflictProjection = const ConflictProjection(),
  })  : _coordinator = coordinator,
        _connectivityMonitor = connectivityMonitor,
        _authGateway = authGateway,
        _repository = repository,
        _syncQueue = syncQueue,
        _conflictProjection = conflictProjection,
        super(const SyncIdle());

  void init() {
    _refreshCounts();
    _connectivitySub =
        _connectivityMonitor.onConnectivityChanged.listen((connected) {
      if (connected) {
        _triggerDebouncedSync();
      }
    });
    _sessionSub = _authGateway.sessionChanges().listen((_) {
      _triggerDebouncedSync();
    });
  }

  void notifyLocalChange() {
    _refreshCounts();
    _triggerDebouncedSync();
  }

  Future<void> syncNow() async {
    if (state is SyncInProgress) return;
    emit(SyncInProgress(
      lastSyncAt: state.lastSyncAt,
      pendingCount: state.pendingCount,
      conflictCount: state.conflictCount,
    ));

    try {
      final outcome = await _coordinator.drain();
      await _handleOutcome(outcome);
    } catch (e) {
      emit(SyncError(
        message: e.toString(),
        lastSyncAt: state.lastSyncAt,
        pendingCount: state.pendingCount,
        conflictCount: state.conflictCount,
      ));
    }
  }

  @override
  Future<void> close() async {
    _debounceTimer?.cancel();
    await _connectivitySub?.cancel();
    await _sessionSub?.cancel();
    return super.close();
  }

  void _triggerDebouncedSync() {
    _debounceTimer?.cancel();
    final delay = DateTime.fromMillisecondsSinceEpoch(3000)
        .difference(DateTime.fromMillisecondsSinceEpoch(0));
    _debounceTimer = Timer(delay, () {
      syncNow();
    });
  }

  Future<void> _handleOutcome(SyncDrainOutcome outcome) async {
    final pending = (await _syncQueue.pendingEntries()).length;
    final docs = await _repository.listDocuments();
    final conflicts = _conflictProjection.countConflicts(docs);

    switch (outcome) {
      case SyncDrainOutcome.success:
        if (conflicts > 0) {
          emit(SyncConflictDetected(
            conflictCount: conflicts,
            lastSyncAt: DateTime.now(),
            pendingCount: pending,
          ));
        } else {
          emit(SyncIdle(
            lastSyncAt: DateTime.now(),
            pendingCount: pending,
            conflictCount: 0,
          ));
        }
      case SyncDrainOutcome.failure:
        emit(SyncError(
          message: 'Sync failed',
          lastSyncAt: state.lastSyncAt,
          pendingCount: pending,
          conflictCount: conflicts,
        ));
      case SyncDrainOutcome.unauthenticated:
        emit(SyncIdle(
          lastSyncAt: state.lastSyncAt,
          pendingCount: pending,
          conflictCount: conflicts,
        ));
    }
  }

  Future<void> _refreshCounts() async {
    try {
      final pending = (await _syncQueue.pendingEntries()).length;
      final docs = await _repository.listDocuments();
      final conflicts = _conflictProjection.countConflicts(docs);
      if (conflicts > 0) {
        emit(SyncConflictDetected(
          conflictCount: conflicts,
          lastSyncAt: state.lastSyncAt,
          pendingCount: pending,
        ));
      } else {
        emit(SyncIdle(
          lastSyncAt: state.lastSyncAt,
          pendingCount: pending,
          conflictCount: 0,
        ));
      }
    } catch (_) {}
  }
}
