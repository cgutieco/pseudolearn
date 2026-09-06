import 'dart:math' as math;

final class _Interval {
  final double start;
  final double end;
  final String? sharedKey;

  const _Interval(this.start, this.end, [this.sharedKey]);

  bool overlapsWith(double s, double e, String? key) {
    if (sharedKey != null && key != null && sharedKey == key) return false;
    return math.max(start, s) < math.min(end, e) - 0.01;
  }
}

final class RoutingReservations {
  final Map<int, Map<int, List<_Interval>>> _verticalTracks = {};
  final Map<int, Map<int, List<_Interval>>> _horizontalTracks = {};

  int findVerticalSublane({
    required int corridorIndex,
    required double y1,
    required double y2,
    String? sharedKey,
  }) {
    final start = math.min(y1, y2);
    final end = math.max(y1, y2);
    final tracks = _verticalTracks[corridorIndex];
    if (tracks == null) return 0;
    var sublane = 0;
    while (true) {
      final intervals = tracks[sublane];
      if (intervals == null || !intervals.any((i) => i.overlapsWith(start, end, sharedKey))) {
        return sublane;
      }
      sublane += 1;
    }
  }

  void commitVertical({
    required int corridorIndex,
    required int sublane,
    required double y1,
    required double y2,
    String? sharedKey,
  }) {
    final start = math.min(y1, y2);
    final end = math.max(y1, y2);
    final tracks = _verticalTracks.putIfAbsent(corridorIndex, () => {});
    final intervals = tracks.putIfAbsent(sublane, () => []);
    intervals.add(_Interval(start, end, sharedKey));
  }

  int findHorizontalSublane({
    required int bandIndex,
    required double x1,
    required double x2,
    String? sharedKey,
  }) {
    final start = math.min(x1, x2);
    final end = math.max(x1, x2);
    final tracks = _horizontalTracks[bandIndex];
    if (tracks == null) return 0;
    var sublane = 0;
    while (true) {
      final intervals = tracks[sublane];
      if (intervals == null || !intervals.any((i) => i.overlapsWith(start, end, sharedKey))) {
        return sublane;
      }
      sublane += 1;
    }
  }

  void commitHorizontal({
    required int bandIndex,
    required int sublane,
    required double x1,
    required double x2,
    String? sharedKey,
  }) {
    final start = math.min(x1, x2);
    final end = math.max(x1, x2);
    final tracks = _horizontalTracks.putIfAbsent(bandIndex, () => {});
    final intervals = tracks.putIfAbsent(sublane, () => []);
    intervals.add(_Interval(start, end, sharedKey));
  }
}
