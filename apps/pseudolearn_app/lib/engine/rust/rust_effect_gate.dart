import '../../domain/model/execution/effect_wait.dart';
import '../../domain/model/execution/simulated_capabilities.dart';
import 'rust_execution_api.dart';
import 'rust_simulated_host.dart';
import 'rust_transport.dart';
import 'rust_wire_models.dart';

final class RustEffectGate {
  final RustExecutionApi _execution;
  final RustSimulatedHost? _host;
  final bool _autoResolve;

  RustEffectGate(
    RustTransport transport,
    SimulatedCapabilities capabilities,
    this._autoResolve,
  ) : _execution = RustExecutionApi(transport),
      _host = capabilities.isEmpty ? null : RustSimulatedHost(capabilities);

  Map<String, Object?>? get hostDocument => _host?.hostDocument();

  bool get canResolve => _host != null;

  RustBatch drain(
    int execution,
    int batchSize,
    List<RustEvent> collected,
  ) {
    var batch = _execution.advance(execution, batchSize);
    collected.addAll(batch.events);
    while (_autoResolve &&
        _host != null &&
        batch.termination == RustTerminationKind.awaitingEffect) {
      answer(execution, batch);
      batch = _execution.advance(execution, batchSize);
      collected.addAll(batch.events);
    }
    return batch;
  }

  void answer(int execution, RustBatch batch) {
    final request = batch.pendingRequest;
    final pending = batch.pendingEffect;
    final host = _host;
    if (request == null || pending == null || host == null) return;
    _execution.provideEffectResult(
      execution,
      pending.effectSeq,
      host.reply(request),
    );
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
