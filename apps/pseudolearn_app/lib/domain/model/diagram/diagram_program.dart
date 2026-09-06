import 'diagram_scene.dart';
import 'diagram_unit.dart';

final class DiagramProgram {
  final List<DiagramUnit> units;
  final Map<String, DiagramScene> _scenes;

  const DiagramProgram({
    required this.units,
    required Map<String, DiagramScene> scenes,
  }) : _scenes = scenes;

  const DiagramProgram.empty()
      : units = const [],
        _scenes = const {};

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
          _hasSameScenes(other._scenes);

  bool _hasSameScenes(Map<String, DiagramScene> otherScenes) {
    if (_scenes.length != otherScenes.length) return false;
    for (final entry in _scenes.entries) {
      if (!otherScenes.containsKey(entry.key)) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(units.length, _scenes.length);
}
