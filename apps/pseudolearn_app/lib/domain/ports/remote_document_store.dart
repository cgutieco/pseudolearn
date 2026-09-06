import '../model/sync/document_snapshot.dart';
import '../model/sync/pull_batch_result.dart';
import '../model/sync/push_batch_result.dart';

abstract interface class RemoteDocumentStore {
  Future<PushBatchResult> pushDocuments(List<DocumentSnapshot> batch);
  Future<PullBatchResult> pullChangesSince(int cursor);
  Future<void> deleteAccount();
}
