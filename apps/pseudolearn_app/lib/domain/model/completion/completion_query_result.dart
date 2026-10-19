import 'completion_item.dart';

enum CompletionFailure { invalidCursor, staleRevision, serviceFailure }

final class CompletionQueryResult {
  final int revision;
  final List<CompletionItem> candidates;
  final CompletionFailure? failure;

  const CompletionQueryResult({
    required this.revision,
    this.candidates = const [],
    this.failure,
  });

  bool get isSuccessful => failure == null;
}
