import 'package:pseudolearn_app/domain/model/sync/sync_drain_outcome.dart';
import 'package:pseudolearn_app/domain/ports/sync_coordinator.dart';

final class FakeSyncCoordinator implements SyncCoordinator {
  SyncDrainOutcome outcome;
  int drainCallCount = 0;

  FakeSyncCoordinator({this.outcome = SyncDrainOutcome.success});

  @override
  Future<SyncDrainOutcome> drain() async {
    drainCallCount++;
    return outcome;
  }
}
