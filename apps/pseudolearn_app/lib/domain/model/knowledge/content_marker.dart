import 'content_marker_kind.dart';

final class ContentMarker {
  final ContentMarkerKind kind;
  final String argument;

  const ContentMarker({
    required this.kind,
    required this.argument,
  });

  String get text => '{{${kind.slug}:$argument}}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentMarker &&
          runtimeType == other.runtimeType &&
          kind == other.kind &&
          argument == other.argument;

  @override
  int get hashCode => Object.hash(kind, argument);
}
