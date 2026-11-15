import 'document_snapshot.dart';

sealed class PullBatchResult {
  const PullBatchResult();
}

final class PullBatchSuccess extends PullBatchResult {
  final List<DocumentSnapshot> documents;
  final int nextCursor;

  const PullBatchSuccess({
    required this.documents,
    required this.nextCursor,
  });
}

final class PullBatchFailure extends PullBatchResult {
  final String error;

  const PullBatchFailure(this.error);
}
