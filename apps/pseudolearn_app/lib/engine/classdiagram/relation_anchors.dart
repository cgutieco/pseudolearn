import '../../domain/model/diagram/class_model.dart';
import '../../domain/model/diagram/diagram_scene.dart';
import 'class_box_placement.dart';

enum _Side { left, right }

final class _Endpoint {
  final ClassRelation relation;
  final PlacedClassBox box;
  final _Side side;
  final bool isSource;
  final PlacedClassBox otherBox;

  const _Endpoint({
    required this.relation,
    required this.box,
    required this.side,
    required this.isSource,
    required this.otherBox,
  });
}

final class RelationAnchors {
  const RelationAnchors._();

  static Map<ClassRelation, (DiagramPoint, DiagramPoint)> of({
    required List<ClassRelation> associations,
    required Map<String, PlacedClassBox> byName,
  }) {
    final groups = <String, List<_Endpoint>>{};
    _collectGroups(associations, byName, groups);

    final sources = <ClassRelation, DiagramPoint>{};
    final targets = <ClassRelation, DiagramPoint>{};
    _assignPoints(groups, sources, targets);

    final result = <ClassRelation, (DiagramPoint, DiagramPoint)>{};
    for (final rel in associations) {
      final s = sources[rel];
      final t = targets[rel];
      if (s != null && t != null) result[rel] = (s, t);
    }
    return Map.unmodifiable(result);
  }

  static void _collectGroups(
    List<ClassRelation> associations,
    Map<String, PlacedClassBox> byName,
    Map<String, List<_Endpoint>> groups,
  ) {
    for (final relation in associations) {
      final from = byName[relation.fromClassName];
      final to = byName[relation.toClassName];
      if (from == null || to == null || identical(from, to)) continue;

      final isLeft = to.centerX < from.centerX;
      final fromSide = isLeft ? _Side.left : _Side.right;
      final toSide = isLeft ? _Side.right : _Side.left;

      groups.putIfAbsent('${from.box.name}_$fromSide', () => []).add(_Endpoint(
            relation: relation,
            box: from,
            side: fromSide,
            isSource: true,
            otherBox: to,
          ));
      groups.putIfAbsent('${to.box.name}_$toSide', () => []).add(_Endpoint(
            relation: relation,
            box: to,
            side: toSide,
            isSource: false,
            otherBox: from,
          ));
    }
  }

  static void _assignPoints(
    Map<String, List<_Endpoint>> groups,
    Map<ClassRelation, DiagramPoint> sources,
    Map<ClassRelation, DiagramPoint> targets,
  ) {
    for (final entry in groups.entries) {
      final list = entry.value;
      list.sort((a, b) => a.otherBox.centerY.compareTo(b.otherBox.centerY));
      final box = list.first.box;
      final side = list.first.side;
      final x = side == _Side.left ? box.left : box.right;

      for (var i = 0; i < list.length; i++) {
        final ep = list[i];
        final y = box.top + box.size.height * (i + 1) / (list.length + 1);
        final pt = DiagramPoint(x, y);
        if (ep.isSource) {
          sources[ep.relation] = pt;
        } else {
          targets[ep.relation] = pt;
        }
      }
    }
  }
}
