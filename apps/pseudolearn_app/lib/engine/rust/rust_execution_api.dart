import 'rust_analysis_api.dart';
import 'rust_transport.dart';
import 'rust_wire_models.dart';

final class RustExecutionApi {
  final RustTransport _transport;

  const RustExecutionApi(this._transport);

  int start(
    RustAnalysisHandle handle, {
    int statementLimit = 0,
    Map<String, Object?>? host,
  }) {
    final started =
        _transport.call('start', {
              'analysis': handle.analysis,
              'observe': 'events',
              'limits': statementLimit > 0
                  ? {'statements': statementLimit}
                  : {},
              'host': ?host,
            })
            as Map<String, Object?>;
    return started['resource'] as int;
  }

  RustBatch advance(int execution, int batchSize) {
    final batch =
        _transport.call('advance', {
              'resource': execution,
              'batch_size': batchSize,
            })
            as Map<String, Object?>;
    return RustBatch.fromJson(batch);
  }

  void provideInput(int execution, String text) {
    _transport.call('input', {'resource': execution, 'text': text});
  }

  void provideEffectResult(int execution, int sequence, Object? result) {
    _transport.call('effect_result', {
      'resource': execution,
      'effect_seq': sequence,
      'result': result,
    });
  }

  void cancel(int execution) {
    _transport.call('cancel', {'resource': execution});
  }
}
