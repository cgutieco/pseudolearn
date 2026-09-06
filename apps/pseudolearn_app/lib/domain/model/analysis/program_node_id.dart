final class ProgramNodeId {
  final int value;

  const ProgramNodeId(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ProgramNodeId && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
