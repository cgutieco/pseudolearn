import '../model/execution/effect_tape.dart';
import '../model/execution/execution_projection.dart';
import '../model/execution/replay_rejection.dart';

abstract interface class ExecutionReproduction {
  EffectTape? get recordedTape;
  ReplayRejection? get replayRejection;
  ExecutionProjection get projection;
}
