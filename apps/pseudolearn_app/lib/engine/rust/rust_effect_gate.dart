import '../../domain/model/execution/effect_wait.dart';
import '../../domain/model/execution/execution_configuration.dart';
import '../../domain/ports/execution_environment.dart';
import 'rust_execution_api.dart';
import 'rust_transport.dart';
import 'rust_wire_models.dart';

final class RustEffectGate {
  static const int maxResolutionsPerDrain = 16;
  final RustTransport _transport;
  final RustExecutionApi _execution;
  final ExecutionEnvironment? _environment;
  final bool _autoResolve;
  ExecutionConfiguration _configuration = const ExecutionConfiguration();
  int? _resource;
  bool _replaying = false;

  RustEffectGate(this._transport, this._environment, this._autoResolve)
    : _execution = RustExecutionApi(_transport);

  void reset(ExecutionConfiguration configuration, {required bool replaying}) {
    close();
    _configuration = configuration;
    _replaying = replaying;
  }

  void close() {
    final resource = _resource;
    _resource = null;
    if (resource != null) _transport.call('host_close', {'resource': resource});
  }

  Map<String, Object?> get hostDocument => const {'detached': true};
  bool get canResolve => !_replaying;
  String? get workingDirectory =>
      _environment?.directoryFor(_configuration.documentId);

  RustBatch drain(int execution, int batchSize, List<RustEvent> collected) {
    var batch = _execution.advance(execution, batchSize);
    collected.addAll(batch.events);
    var resolutions = 0;
    while (_autoResolve &&
        canResolve &&
        batch.termination == RustTerminationKind.awaitingEffect) {
      if (resolutions == maxResolutionsPerDrain || !answer(execution, batch)) {
        return batch;
      }
      resolutions++;
      batch = _execution.advance(execution, batchSize);
      collected.addAll(batch.events);
    }
    return batch;
  }

  bool answer(int execution, RustBatch batch) {
    if (_replaying) return false;
    if (_resource == null) {
      final directory = _environment?.directoryFor(_configuration.documentId);
      _transport.call('host_open', {
        'resource': execution,
        'directory': ?directory,
        'args': _configuration.arguments,
      });
      _resource = execution;
    }
    for (final effect in batch.pendingRequests) {
      _transport.call('host_submit', {'resource': execution, 'effect': effect});
    }
    final replies =
        _transport.call('host_poll', {'resource': execution}) as List<Object?>;
    for (final raw in replies) {
      final reply = raw as Map<String, Object?>;
      _execution.provideEffectResult(
        execution,
        reply['effect_seq'] as int,
        reply['result'],
      );
    }
    return replies.isNotEmpty;
  }

  static EffectWait? waitOf(PendingEffectRequest? request) => request == null
      ? null
      : EffectWait(
          sequence: request.effectSeq,
          capabilityKind: request.capabilityKind,
          operation: request.operation,
          argumentsSummary: request.argumentsSummary,
        );
}
