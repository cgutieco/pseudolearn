import 'package:pseudolearn_app/domain/model/progress/merge_progress.dart';
import 'package:pseudolearn_app/domain/model/progress/progress_entry.dart';
import 'package:pseudolearn_app/domain/model/progress/pull_progress_result.dart';
import 'package:pseudolearn_app/domain/model/progress/push_progress_result.dart';
import 'package:pseudolearn_app/domain/ports/remote_progress_store.dart';

final class _RemoteStoredEntry {
  final ProgressEntry entry;
  final int serverRevision;

  const _RemoteStoredEntry({
    required this.entry,
    required this.serverRevision,
  });
}

final class FakeRemoteProgressStore implements RemoteProgressStore {
  final Map<String, Map<String, _RemoteStoredEntry>> _userProgress = {};
  final Map<String, int> _userRevisions = {};
  String activeUserId;
  bool shouldFailPush = false;
  bool shouldFailPull = false;

  FakeRemoteProgressStore({this.activeUserId = 'test-user-id'});

  @override
  Future<PushProgressResult> pushProgress(List<ProgressEntry> entries) async {
    if (shouldFailPush) {
      return const PushProgressFailure('Simulated network failure on push');
    }

    final userMap = _userProgress.putIfAbsent(activeUserId, () => {});
    final nextRev = (_userRevisions[activeUserId] ?? 0) + 1;
    _userRevisions[activeUserId] = nextRev;

    for (final remote in entries) {
      final existing = userMap[remote.contentId]?.entry;
      final merged = mergeProgress(local: existing, remote: remote);
      userMap[remote.contentId] = _RemoteStoredEntry(
        entry: merged,
        serverRevision: nextRev,
      );
    }
    return PushProgressSuccess(nextRev);
  }

  @override
  Future<PullProgressResult> pullProgressSince(int cursor) async {
    if (shouldFailPull) {
      return const PullProgressFailure('Simulated network failure on pull');
    }

    final userMap = _userProgress[activeUserId] ?? {};
    var maxRev = cursor;
    final entries = <ProgressEntry>[];

    for (final stored in userMap.values) {
      if (stored.serverRevision > cursor) {
        entries.add(stored.entry);
        if (stored.serverRevision > maxRev) {
          maxRev = stored.serverRevision;
        }
      }
    }

    return PullProgressSuccess(entries: entries, nextCursor: maxRev);
  }

  List<ProgressEntry> get activeUserEntries {
    final userMap = _userProgress[activeUserId] ?? {};
    return userMap.values.map((s) => s.entry).toList();
  }
}
