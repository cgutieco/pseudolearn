import '../model/sync/sync_drain_outcome.dart';

abstract interface class SyncCoordinator {
  Future<SyncDrainOutcome> drain();
}
