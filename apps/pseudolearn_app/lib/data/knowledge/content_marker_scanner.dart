import '../../domain/model/knowledge/content_marker.dart';
import '../../domain/model/knowledge/content_marker_kind.dart';
import 'marker_occurrence.dart';

final class ContentMarkerScanner {
  static const String opening = '{{';
  static const String closing = '}}';

  const ContentMarkerScanner();

  List<MarkerOccurrence> scan(String text) {
    final occurrences = <MarkerOccurrence>[];
    var cursor = 0;
    while (cursor < text.length) {
      final start = text.indexOf(opening, cursor);
      if (start < 0) break;
      final closes = text.indexOf(closing, start + opening.length);
      if (closes < 0) break;
      final end = closes + closing.length;
      occurrences.add(MarkerOccurrence(
        marker: _parse(text.substring(start + opening.length, closes)),
        raw: text.substring(start, end),
        start: start,
        end: end,
      ));
      cursor = end;
    }
    return occurrences;
  }

  ContentMarker? _parse(String body) {
    final separator = body.indexOf(':');
    if (separator <= 0 || separator == body.length - 1) return null;
    final kind = ContentMarkerKind.fromSlug(body.substring(0, separator).trim());
    if (kind == null) return null;
    final argument = body.substring(separator + 1).trim();
    if (argument.isEmpty) return null;
    return ContentMarker(kind: kind, argument: argument);
  }
}
