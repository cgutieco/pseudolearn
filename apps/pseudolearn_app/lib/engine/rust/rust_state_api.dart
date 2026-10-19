import 'rust_transport.dart';

final class RustStateApi {
  final RustTransport _transport;

  const RustStateApi(this._transport);

  Map<String, Object?>? frame(int execution, int event, int frame) {
    try {
      return _transport.call('query_frame', {
            'resource': execution,
            'event': event,
            'frame': frame,
          })
          as Map<String, Object?>;
    } on RustBridgeFailure catch (failure) {
      if (failure.isUsage) return null;
      rethrow;
    }
  }

  int? arrayLength(int execution, int event, int reference) {
    final page = _page(
      execution,
      event,
      query: 'array_cells',
      target: reference,
    );
    return page?['total'] as int?;
  }

  Map<String, Object?>? objectOf(int execution, int event, int reference) {
    try {
      return _transport.call('query_object', {
            'resource': execution,
            'event': event,
            'reference': reference,
          })
          as Map<String, Object?>;
    } on RustBridgeFailure catch (failure) {
      if (failure.isUsage) return null;
      rethrow;
    }
  }

  Map<String, Object?>? _page(
    int execution,
    int event, {
    required String query,
    required int target,
  }) {
    try {
      return _transport.call('query_page', {
            'resource': execution,
            'event': event,
            'query': query,
            'target': target,
            'page_size': 1,
          })
          as Map<String, Object?>;
    } on RustBridgeFailure catch (failure) {
      if (failure.isUsage) return null;
      rethrow;
    }
  }
}
