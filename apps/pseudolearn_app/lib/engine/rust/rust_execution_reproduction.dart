import '../../domain/model/execution/effect_tape.dart';
import '../../domain/model/execution/execution_projection.dart';
import '../../domain/model/execution/output_line.dart';
import '../../domain/model/execution/replay_rejection.dart';
import 'rust_event_signature.dart';
import 'rust_replay_rejection.dart';
import 'rust_transport.dart';
import 'rust_wire_models.dart';

final class RustExecutionReproduction {
  final List<String> _events = [];
  Map<String, Object?>? _tape;
  ReplayRejection? _rejection;
  bool _replaying = false;

  bool get replaying => _replaying;

  ReplayRejection? get rejection => _rejection;

  EffectTape? get recordedTape {
    final tape = _tape;
    return tape == null ? null : EffectTape.fromDocument(tape);
  }

  void begin({required bool replaying}) {
    _events.clear();
    _tape = null;
    _rejection = null;
    _replaying = replaying;
  }

  void consumed(RustEvent event) => _events.add(rustEventSignature(event));

  void observed(RustBatch batch) {
    _tape = batch.effectTape ?? _tape;
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
