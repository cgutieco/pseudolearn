import 'rust_transport.dart';

sealed class RustStateResult<T> {
  const RustStateResult();
}

final class RustStateValue<T> extends RustStateResult<T> {
  final T value;

  const RustStateValue(this.value);
}

final class RustStateUsage<T> extends RustStateResult<T> {
  const RustStateUsage();
}

final class RustStateFailure<T> extends RustStateResult<T> {
  final String reason;

  const RustStateFailure(this.reason);
}

final class RustStateApi {
  final RustTransport _transport;

  const RustStateApi(this._transport);

  RustStateResult<Map<String, Object?>> frame(
    int execution,
    int event,
    int frame, {
    required int taskId,
  }) => _readMap('query_frame', {
    'resource': execution,
    'event': event,
    'frame': frame,
    'task_id': taskId,
  });

  RustStateResult<List<int>> arrayShape(
    int execution,
    int event,
    int reference, {
    required int taskId,
  }) {
    final page = _page(
      execution,
      event,
      taskId: taskId,
      query: 'array_cells',
      target: reference,
    );
    if (page is RustStateUsage<Map<String, Object?>>) {
      return const RustStateUsage();
    }
    if (page is RustStateFailure<Map<String, Object?>>) {
      return RustStateFailure(page.reason);
    }
    if (page is! RustStateValue<Map<String, Object?>>) {
      return const RustStateFailure('invalid_state_response');
    }
    final dimensions = page.value['dimensions'];
    if (dimensions is! List<Object?> ||
        dimensions.any((item) => item is! int)) {
      return const RustStateFailure('invalid_state_response');
    }
    return RustStateValue(dimensions.cast<int>());
  }

  RustStateResult<Map<String, Object?>> objectOf(
    int execution,
    int event,
    int reference, {
    required int taskId,
  }) => _readMap('query_object', {
    'resource': execution,
    'event': event,
    'reference': reference,
    'task_id': taskId,
  });

  RustStateResult<Map<String, Object?>> _page(
    int execution,
    int event, {
    required int taskId,
    required String query,
    required int target,
  }) => _readMap('query_page', {
    'resource': execution,
    'event': event,
    'query': query,
    'target': target,
    'page_size': 1,
    'task_id': taskId,
  });

  RustStateResult<Map<String, Object?>> _readMap(
    String operation,
    Map<String, Object?> arguments,
  ) {
    try {
      final result = _transport.call(operation, arguments);
      if (result is Map<String, Object?>) return RustStateValue(result);
      return const RustStateFailure('invalid_state_response');
    } on RustBridgeFailure catch (failure) {
      if (failure.isUsage) return const RustStateUsage();
      return RustStateFailure(failure.family);
    } on Object {
      return const RustStateFailure('invalid_state_response');
    }
  }
}
