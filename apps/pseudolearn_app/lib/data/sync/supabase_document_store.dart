import 'package:supabase/supabase.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/sync/document_snapshot.dart';
import '../../domain/model/sync/pull_batch_result.dart';
import '../../domain/model/sync/push_batch_result.dart';
import '../../domain/ports/remote_document_store.dart';

final class SupabaseDocumentStore implements RemoteDocumentStore {
  final SupabaseClient _client;
  final String _originDevice;

  const SupabaseDocumentStore({
    required SupabaseClient client,
    String originDevice = 'app',
  })  : _client = client,
        _originDevice = originDevice;

  @override
  Future<PushBatchResult> pushDocuments(List<DocumentSnapshot> batch) async {
    try {
      final payload = batch
          .map((doc) => {
                'id': doc.id,
                'title': doc.title,
                'content': doc.content,
                'profile_id': doc.profileId.name,
                'exercise_id': doc.exerciseId,
                'created_at': doc.updatedAt.toIso8601String(),
                'updated_at': doc.updatedAt.toIso8601String(),
                'deleted_at': doc.deletedAt?.toIso8601String(),
                'origin_device': _originDevice,
              })
          .toList();

      final res = await _client.rpc<dynamic>(
        'push_documents',
        params: {'payload': payload},
      );

      final nextRev = (res as num?)?.toInt() ?? 0;
      return PushBatchSuccess(nextRev);
    } catch (e) {
      return PushBatchFailure(e.toString());
    }
  }

  @override
  Future<PullBatchResult> pullChangesSince(int cursor) async {
    try {
      final res = await _client
          .from('documents')
          .select()
          .gt('server_revision', cursor)
          .order('server_revision', ascending: true);

      final rows = res as List<dynamic>;
      final docs = rows.map((dynamic row) {
        final map = row as Map<String, dynamic>;
        final profileName = map['profile_id'] as String;
        final profileId = SyntaxProfileId.values.firstWhere(
          (p) => p.name == profileName,
          orElse: () => SyntaxProfileId.classicSpanish,
        );
        return DocumentSnapshot(
          id: map['id'] as String,
          revision: (map['server_revision'] as num).toInt(),
          updatedAt: DateTime.parse(map['updated_at'] as String),
          deletedAt: map['deleted_at'] != null
              ? DateTime.parse(map['deleted_at'] as String)
              : null,
          content: map['content'] as String,
          title: map['title'] as String,
          profileId: profileId,
          exerciseId: map['exercise_id'] as String?,
        );
      }).toList();

      final nextCursor = docs.isNotEmpty ? docs.last.revision : cursor;
      return PullBatchSuccess(documents: docs, nextCursor: nextCursor);
    } catch (e) {
      return PullBatchFailure(e.toString());
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await _client.rpc<void>('delete_account');
    } catch (_) {}
  }
}
