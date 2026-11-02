import '../../domain/model/execution/input_wait.dart';
import 'rust_analysis_api.dart';
import 'rust_execution_resource.dart';
import 'rust_transport.dart';
import 'rust_wire_models.dart';

final class RustExecutionApi {
  final RustTransport _transport;
  final RustExecutionResource? _resource;

  const RustExecutionApi(this._transport, {RustExecutionResource? resource})
    : _resource = resource;

  int start(
    RustAnalysisHandle handle,
    Map<String, Object?>? host,
    String? revision, {
    int statementLimit = 0,
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
    final execution = started['resource'] as int;
    final resource = _resource;
    if (resource != null && revision != null) {
      resource.open(execution, revision);
    }
    return execution;
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

  void provideInput(int execution, InputWait request, String text) {
    _transport.call('input', {
      'resource': execution,
      'resource_id': request.resourceId,
      'task_id': request.taskId,
      'request_id': request.requestId,
      'text': text,
    });
  }

  void provideEffectResult(int execution, int sequence, Object? result) {
    _transport.call('effect_result', {
      'resource': execution,
      'effect_seq': sequence,
      'result': result,
    });
  }

  void stop(int? execution) {
    if (execution != null) {
      _transport.call('cancel', {'resource': execution});
      _transport.call('release', {'resource': execution});
    }
    _resource?.clear();
  }
}
