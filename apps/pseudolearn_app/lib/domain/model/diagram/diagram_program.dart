import '../analysis/program_dependency.dart';
import 'diagram_scene.dart';
import 'diagram_unit.dart';

final class DiagramProgram {
  final List<DiagramUnit> units;
  final Map<String, DiagramScene> _scenes;
  final List<String> unsupportedKinds;
  final List<ProgramDependency> dependencies;

  const DiagramProgram({
    required this.units,
    required this._scenes,
    this.dependencies = const [],
  })  : unsupportedKinds = const [];

  const DiagramProgram.empty()
      : units = const [],
        _scenes = const {},
        unsupportedKinds = const [],
        dependencies = const [];

  const DiagramProgram.unsupported(this.unsupportedKinds)
      : units = const [],
        _scenes = const {},
        dependencies = const [];

  bool get isUnsupported => unsupportedKinds.isNotEmpty;

  bool get isEmpty => units.isEmpty;

  bool get isNotEmpty => units.isNotEmpty;

  DiagramUnit? get defaultUnit => units.isEmpty ? null : units.first;

  DiagramScene sceneFor(String? unitId) {
    if (unitId == null) {
      return defaultUnit != null
          ? (_scenes[defaultUnit!.id] ?? const DiagramScene.empty())
          : const DiagramScene.empty();
    }
    return _scenes[unitId] ?? const DiagramScene.empty();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiagramProgram &&
          units.length == other.units.length &&
          _hasSameDependencies(other.dependencies) &&
          _hasSameScenes(other._scenes);

  bool _hasSameDependencies(List<ProgramDependency> others) {
    if (dependencies.length != others.length) return false;
    for (var index = 0; index < dependencies.length; index++) {
      if (dependencies[index].id != others[index].id) return false;
    }
    return true;
  }

  bool _hasSameScenes(Map<String, DiagramScene> otherScenes) {
    if (_scenes.length != otherScenes.length) return false;
    for (final entry in _scenes.entries) {
      if (!otherScenes.containsKey(entry.key)) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(units.length, _scenes.length, dependencies.length);
}
