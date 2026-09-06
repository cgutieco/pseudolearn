import '../../domain/model/knowledge/content_marker.dart';
import '../../domain/model/knowledge/content_marker_kind.dart';
import 'diagram_marker_argument.dart';

Set<String> referencedContentIds(List<ContentMarker> markers) {
  final ids = <String>{};
  for (final marker in markers) {
    switch (marker.kind) {
      case ContentMarkerKind.example:
      case ContentMarkerKind.figure:
        ids.add(marker.argument);
      case ContentMarkerKind.diagram:
        final parsed = DiagramMarkerArgument.parse(marker.argument);
        if (parsed != null) ids.add(parsed.exampleId);
      case ContentMarkerKind.lexeme:
      case ContentMarkerKind.table:
      case ContentMarkerKind.signature:
      case ContentMarkerKind.diagnostic:
        break;
    }
  }
  return ids;
}
