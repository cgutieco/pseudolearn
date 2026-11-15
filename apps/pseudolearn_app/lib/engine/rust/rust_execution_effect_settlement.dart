import '../../domain/model/execution/effect_settlement.dart';
import '../../domain/model/execution/execution_step.dart';
import 'rust_effect_gate.dart';
import 'rust_execution_api.dart';
import 'rust_wire_models.dart';

final class RustExecutionEffectSettlement {
  const RustExecutionEffectSettlement();

  ExecutionStep settle({
    required EffectSettlement settlement,
    required RustBatch? batch,
    required int? execution,
    required RustEffectGate gate,
    required ExecutionStep Function() advance,
    required void Function() onResolved,
    required ExecutionStep Function() cancel,
  }) {
    if (settlement == EffectSettlement.cancel) return cancel();
    if (execution == null || batch?.pendingEffect == null || !gate.canResolve) {
      return advance();
    }
    gate.answer(execution, batch!);
    onResolved();
    return advance();
  }

  ExecutionStep cancel({
    required RustExecutionApi executionApi,
    required int? execution,
    required int batchSize,
    required void Function(RustBatch) observe,
    required ExecutionStep Function(RustEvent) consume,
    required ExecutionStep Function() snapshot,
    required ExecutionStep Function() terminal,
    required void Function() releaseConfirmed,
  }) {
    if (execution == null) return const ExecutionStep.exhausted();
    final batch = executionApi.stop(
      execution,
      confirmCancellation: true,
      release: false,
      batchSize: batchSize,
    );
    if (batch == null) return const ExecutionStep.exhausted();
    observe(batch);
    for (final event in batch.events) {
      final result = consume(event);
      if (result.isHalted) {
        releaseConfirmed();
        return result;
      }
    }
    if (batch.termination == RustTerminationKind.running) return snapshot();
    final result = terminal();
    if (result.isTerminal) releaseConfirmed();
    return result;
  }
}
