import '../environment/call_frame.dart';
import '../values/runtime_value.dart';
import 'environment_snapshot.dart';

final class SnapshotBuilder {
  const SnapshotBuilder();

  EnvironmentSnapshot build(List<CallFrame> framesOldestToNewest) =>
      EnvironmentSnapshot(
          [for (final frame in framesOldestToNewest) _buildFrame(frame)]);

  FrameSnapshot _buildFrame(CallFrame frame) {
    final variables = [
      for (final entry in frame.scope.entries)
        VariableSnapshotEntry(
          name: entry.key.name,
          hasValue: entry.value.hasValue,
          value: entry.value.hasValue ? entry.value.value : null,
        ),
    ];
    return FrameSnapshot(
      subroutineName: frame.subroutineName,
      variables: variables,
      receiver: frame.receiver != null ? ObjectValue(frame.receiver!) : null,
    );
  }
}
