import 'content_load_failure.dart';

sealed class ContentLoadResult<T> {
  const ContentLoadResult();
}

final class ContentLoaded<T> extends ContentLoadResult<T> {
  final T value;

  const ContentLoaded(this.value);
}

final class ContentLoadFailed<T> extends ContentLoadResult<T> {
  final ContentLoadFailure failure;
  final String detail;

  const ContentLoadFailed({
    required this.failure,
    required this.detail,
  });
}
