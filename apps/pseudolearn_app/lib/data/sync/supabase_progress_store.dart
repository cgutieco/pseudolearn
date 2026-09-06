import 'package:supabase/supabase.dart';
import '../../domain/model/progress/progress_entry.dart';
import '../../domain/model/progress/pull_progress_result.dart';
import '../../domain/model/progress/push_progress_result.dart';
import '../../domain/ports/remote_progress_store.dart';

final class SupabaseProgressStore implements RemoteProgressStore {
  final SupabaseClient _client;

  const SupabaseProgressStore({
    required SupabaseClient client,
  }) : _client = client;

  @override
  Future<PushProgressResult> pushProgress(List<ProgressEntry> entries) async {
    try {
      final payload = entries
          .map((entry) => {
                'content_id': entry.contentId,
                'visited': entry.visited,
                'completed': entry.completed,
                'first_visited_at': entry.firstVisitedAt?.toIso8601String(),
                'first_completed_at': entry.firstCompletedAt?.toIso8601String(),
              })
          .toList();

      final res = await _client.rpc<dynamic>(
        'push_progress',
        params: {'payload': payload},
      );

      final nextRev = (res as num?)?.toInt() ?? 0;
      return PushProgressSuccess(nextRev);
    } catch (e) {
      return PushProgressFailure(e.toString());
    }
  }

  @override
  Future<PullProgressResult> pullProgressSince(int cursor) async {
    try {
      final res = await _client
          .from('progress')
          .select()
          .gt('server_revision', cursor)
          .order('server_revision', ascending: true);

      final rows = res as List<dynamic>;
      var maxRevision = cursor;
      final entries = rows.map((dynamic row) {
        final map = row as Map<String, dynamic>;
        final rev = (map['server_revision'] as num).toInt();
        if (rev > maxRevision) {
          maxRevision = rev;
        }

        return ProgressEntry(
          contentId: map['content_id'] as String,
          visited: map['visited'] as bool? ?? false,
          completed: map['completed'] as bool? ?? false,
          firstVisitedAt: map['first_visited_at'] != null
              ? DateTime.parse(map['first_visited_at'] as String)
              : null,
          firstCompletedAt: map['first_completed_at'] != null
              ? DateTime.parse(map['first_completed_at'] as String)
              : null,
        );
      }).toList();

      return PullProgressSuccess(entries: entries, nextCursor: maxRevision);
    } catch (e) {
      return PullProgressFailure(e.toString());
    }
  }
}
