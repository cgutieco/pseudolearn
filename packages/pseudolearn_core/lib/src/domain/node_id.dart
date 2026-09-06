final class NodeId {
  final int value;

  const NodeId(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NodeId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => '#$value';
}

final class NodeIdGenerator {
  int _nextValue;

  NodeIdGenerator([this._nextValue = 1]);

  NodeId next() => NodeId(_nextValue++);
}
