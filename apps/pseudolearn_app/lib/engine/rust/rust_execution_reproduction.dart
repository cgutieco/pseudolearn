import '../../domain/model/execution/effect_tape.dart';
import '../../domain/model/execution/execution_projection.dart';
import '../../domain/model/execution/output_line.dart';
import '../../domain/model/execution/replay_rejection.dart';
import 'rust_effect_tape_assembly.dart';
import 'rust_event_signature.dart';
import 'rust_replay_rejection.dart';
import 'rust_transport.dart';
import 'rust_wire_models.dart';

final class RustExecutionReproduction {
  final List<String> _events = [];
  final RustEffectTapeAssembly tape = RustEffectTapeAssembly();
  EffectTape? _recordedTape;
  ReplayRejection? _rejection;
  bool _replaying = false;

  bool get replaying => _replaying;

  ReplayRejection? get rejection => _rejection;

  EffectTape? get recordedTape {
    final recorded = _recordedTape;
    if (recorded != null) return recorded;
    final document = tape.document();
    if (document == null) return null;
    return _recordedTape = EffectTape.fromDocument(document);
  }

  void begin({required bool replaying}) {
    _events.clear();
    tape.clear();
    _recordedTape = null;
    _rejection = null;
    _replaying = replaying;
  }

  void consumed(RustEvent event) => _events.add(rustEventSignature(event));

  void observed(RustBatch batch) {
    if (batch.effectTape != null) _recordedTape = null;
  }

  ReplayRejection reject(RustBridgeFailure failure) =>
      _rejection = replayRejectionOf(failure);

  ExecutionProjection projection({
    required RustTerminationKind termination,
    required List<OutputLine> output,
    String? failure,
  }) => ExecutionProjection(
    events: List.unmodifiable(_events),
    output: [for (final line in output) '${line.kind.name}:${line.text}'],
    termination: termination.name,
    failure: failure,
  );
}
