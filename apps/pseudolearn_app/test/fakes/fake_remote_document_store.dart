import 'package:pseudolearn_app/domain/model/sync/document_snapshot.dart';
import 'package:pseudolearn_app/domain/model/sync/pull_batch_result.dart';
import 'package:pseudolearn_app/domain/model/sync/push_batch_result.dart';
import 'package:pseudolearn_app/domain/ports/remote_document_store.dart';

final class FakeRemoteDocumentStore implements RemoteDocumentStore {
  final Map<String, List<DocumentSnapshot>> _userDocuments = {};
  final Map<String, int> _userRevisions = {};
  String activeUserId;

  FakeRemoteDocumentStore({this.activeUserId = 'test-user-id'});

  @override
  Future<PushBatchResult> pushDocuments(List<DocumentSnapshot> batch) async {
    final docs = _userDocuments.putIfAbsent(activeUserId, () => []);
    final nextRev = (_userRevisions[activeUserId] ?? 0) + 1;
    _userRevisions[activeUserId] = nextRev;

    for (final doc in batch) {
      final index = docs.indexWhere((d) => d.id == doc.id);
      final stamped = DocumentSnapshot(
        id: doc.id,
        revision: nextRev,
        updatedAt: doc.updatedAt,
        deletedAt: doc.deletedAt,
        content: doc.content,
        title: doc.title,
        profileId: doc.profileId,
        exerciseId: doc.exerciseId,
      );
      if (index >= 0) {
        docs[index] = stamped;
      } else {
        docs.add(stamped);
      }
    }
    return PushBatchSuccess(nextRev);
  }

  @override
  Future<PullBatchResult> pullChangesSince(int cursor) async {
    final docs = _userDocuments[activeUserId] ?? [];
    final filtered = docs.where((d) => d.revision > cursor).toList();
    filtered.sort((a, b) => a.revision.compareTo(b.revision));
    final nextCursor = filtered.isNotEmpty ? filtered.last.revision : cursor;
    return PullBatchSuccess(documents: filtered, nextCursor: nextCursor);
  }

  bool throwOnDeleteAccount = false;

  @override
  Future<void> deleteAccount() async {
    if (throwOnDeleteAccount) {
      throw Exception('deleteAccount error');
    }
    _userDocuments.remove(activeUserId);
    _userRevisions.remove(activeUserId);
  }

  List<DocumentSnapshot> get activeUserDocuments =>
      List.unmodifiable(_userDocuments[activeUserId] ?? []);
}
