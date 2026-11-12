import '../../domain/model/route/route_kinds.dart';
import '../../domain/model/route/route_toc.dart';

enum RouteBankStatus { initial, loading, success, error }

final class RouteBankFilter {
  final String? partId;
  final RouteExerciseKind? kind;
  final RouteLevel? level;

  const RouteBankFilter({this.partId, this.kind, this.level});

  bool get isEmpty => partId == null && kind == null && level == null;

  RouteBankFilter togglePart(String part) => RouteBankFilter(
    partId: partId == part ? null : part,
    kind: kind,
    level: level,
  );

  RouteBankFilter toggleKind(RouteExerciseKind wanted) => RouteBankFilter(
    partId: partId,
    kind: kind == wanted ? null : wanted,
    level: level,
  );

  RouteBankFilter toggleLevel(RouteLevel wanted) => RouteBankFilter(
    partId: partId,
    kind: kind,
    level: level == wanted ? null : wanted,
  );
}

final class RouteBankState {
  final RouteBankStatus status;
  final List<RoutePartEntry> parts;
  final List<RouteExerciseEntry> visible;
  final Set<String> completedIds;
  final RouteBankFilter filter;

  const RouteBankState({
    this.status = RouteBankStatus.initial,
    this.parts = const [],
    this.visible = const [],
    this.completedIds = const {},
    this.filter = const RouteBankFilter(),
  });
}
