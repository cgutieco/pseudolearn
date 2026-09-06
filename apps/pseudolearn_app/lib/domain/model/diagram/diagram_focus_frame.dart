final class DiagramFocusFrame {
  final double x;
  final double y;
  final double width;
  final double height;

  const DiagramFocusFrame({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  double get centerX => x + width / 2;

  double get centerY => y + height / 2;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiagramFocusFrame &&
          x == other.x &&
          y == other.y &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode => Object.hash(x, y, width, height);
}
