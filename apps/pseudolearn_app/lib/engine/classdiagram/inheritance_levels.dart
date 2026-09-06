import '../../domain/model/diagram/class_model.dart';

final class InheritanceLevels {
  const InheritanceLevels._();

  static List<List<ClassBox>> of(List<ClassBox> classes) {
    if (classes.isEmpty) return const [];
    final byName = <String, ClassBox>{};
    for (final box in classes) {
      byName.putIfAbsent(box.name, () => box);
    }
    final byDepth = <int, List<ClassBox>>{};
    for (final box in classes) {
      byDepth.putIfAbsent(depthOf(box, byName), () => []).add(box);
    }
    final depths = byDepth.keys.toList()..sort();
    return [
      for (final depth in depths) List<ClassBox>.unmodifiable(byDepth[depth]!),
    ];
  }

  static int depthOf(ClassBox box, Map<String, ClassBox> byName) {
    final visited = <String>{box.name};
    var depth = 0;
    var current = box;
    while (current.superclassName != null) {
      final parent = byName[current.superclassName];
      if (parent == null || !visited.add(parent.name)) return depth;
      depth += 1;
      current = parent;
    }
    return depth;
  }
}
