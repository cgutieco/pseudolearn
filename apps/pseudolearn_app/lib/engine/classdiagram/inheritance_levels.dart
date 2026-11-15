import 'dart:math' as math;

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

  static int depthOf(ClassBox box, Map<String, ClassBox> byName) =>
      _depth(box, byName, {box.name});

  static int _depth(ClassBox box, Map<String, ClassBox> byName, Set<String> path) {
    var deepest = 0;
    for (final name in [?box.superclassName, ...box.contractNames]) {
      final parent = byName[name];
      if (parent == null || !path.add(parent.name)) continue;
      deepest = math.max(deepest, 1 + _depth(parent, byName, path));
      path.remove(parent.name);
    }
    return deepest;
  }
}
