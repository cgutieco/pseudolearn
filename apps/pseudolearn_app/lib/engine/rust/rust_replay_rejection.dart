import '../../domain/model/execution/replay_rejection.dart';
import 'rust_transport.dart';

const String _missingTapeDetail =
    'Invalid protocol: missing effect tape for replay';
const String _protocolPrefix = 'Invalid protocol: ';

ReplayRejection replayRejectionOf(RustBridgeFailure failure) {
  if (failure.family == 'version') return ReplayRejection.unsupportedSchema;
  if (failure.detail == _missingTapeDetail) return ReplayRejection.missingTape;
  if (!failure.detail.startsWith(_protocolPrefix)) {
    return ReplayRejection.engineRefused;
  }
  final code = failure.detail.substring(_protocolPrefix.length);
  for (final rejection in ReplayRejection.values) {
    if (rejection.code == code) return rejection;
  }
  return ReplayRejection.engineRefused;
}
