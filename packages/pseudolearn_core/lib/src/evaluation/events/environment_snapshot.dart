import '../values/runtime_value.dart';

final class VariableSnapshotEntry {
  final String name;
  final bool hasValue;
  final RuntimeValue? value;

  const VariableSnapshotEntry({
    required this.name,
    required this.hasValue,
    this.value,
  });
}

final class FrameSnapshot {
  final String subroutineName;
  final List<VariableSnapshotEntry> variables;
  final ObjectValue? receiver;

  const FrameSnapshot({
    required this.subroutineName,
    required this.variables,
    this.receiver,
  });
}

final class EnvironmentSnapshot {
  final List<FrameSnapshot> frames;

  const EnvironmentSnapshot(this.frames);
}
