import '../../domain/model/exercises/user_exercise_snapshot.dart';
import '../../domain/ports/remote_user_exercise_store.dart';
import '../../domain/ports/user_exercise_repository.dart';
import 'user_exercise_sync_state.dart';

final class UserExerciseSyncDrainer {
  final RemoteUserExerciseStore _remote;
  final UserExerciseRepository _repository;
  final UserExerciseSyncState _state;

  const UserExerciseSyncDrainer({
    required RemoteUserExerciseStore remote,
    required UserExerciseRepository repository,
    required UserExerciseSyncState state,
  }) : _remote = remote,
       _repository = repository,
       _state = state;

  Future<bool> drainPull() async {
    final pulled = await _remote.pullSince(await _state.cursor());
    if (pulled == null) return false;
    var cursor = await _state.cursor();
    for (final remote in pulled) {
      await _apply(remote);
      if (remote.serverRevision > cursor) cursor = remote.serverRevision;
    }
    await _state.saveCursor(cursor);
    return true;
  }

  Future<bool> drainPush() async {
    final dirty = await _state.dirtyRows();
    if (dirty.isEmpty) return true;
    final batch = [
      for (final row in dirty)
        UserExerciseSnapshot(
          id: row.id,
          exercise: row.exercise,
          updatedAt: row.updatedAt,
        ),
    ];
    if (!await _remote.push(batch)) return false;
    for (final row in dirty) {
      await _state.markClean(row.id);
    }
    return true;
  }

  Future<void> _apply(UserExerciseSnapshot remote) async {
    final local = await _state.localRow(remote.id);
    final localWins = local != null &&
        local.dirty &&
        !local.updatedAt.isBefore(remote.updatedAt);
    if (localWins) return;
    final exercise = remote.exercise;
    if (exercise == null) {
      await _repository.deleteExercise(remote.id);
    } else {
      await _repository.saveExercise(exercise);
    }
    await _state.markClean(remote.id, serverRevision: remote.serverRevision);
  }
}
