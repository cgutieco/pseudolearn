import 'progress_entry.dart';

sealed class PullProgressResult {
  const PullProgressResult();
}

final class PullProgressSuccess extends PullProgressResult {
  final List<ProgressEntry> entries;
  final int nextCursor;

  const PullProgressSuccess({
    required this.entries,
    required this.nextCursor,
  });
}

final class PullProgressFailure extends PullProgressResult {
  final String error;

  const PullProgressFailure(this.error);
}
