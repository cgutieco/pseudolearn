import '../../domain/model/knowledge/content_marker.dart';

final class MarkerOccurrence {
  final ContentMarker? marker;
  final String raw;
  final int start;
  final int end;

  const MarkerOccurrence({
    required this.marker,
    required this.raw,
    required this.start,
    required this.end,
  });
}
