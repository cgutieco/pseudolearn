import '../../domain/model/knowledge/content_block.dart';
import '../../domain/model/knowledge/content_load_result.dart';
import '../../domain/model/knowledge/content_marker.dart';
import '../../domain/model/knowledge/content_marker_kind.dart';
import 'content_assets.dart';
import 'diagram_marker_argument.dart';

ContentLoadResult<ContentBlock>? contentMarkerBlock(
  ContentMarker marker,
  ContentAssets assets,
) {
  return switch (marker.kind) {
    ContentMarkerKind.example => _codeBlockOf(assets, marker.argument),
    ContentMarkerKind.figure => _figureBlockOf(assets, marker.argument),
    ContentMarkerKind.diagram => _diagramBlockOf(assets, marker.argument),
    _ => null,
  };
}

ContentLoadResult<ContentBlock>? _codeBlockOf(
  ContentAssets assets,
  String exampleId,
) {
  final source = assets.exampleSources[exampleId];
  if (source == null) return null;
  final title = assets.exampleTitles[exampleId];
  return ContentLoaded(CodeBlock(code: source, title: title));
}

ContentLoadResult<ContentBlock>? _figureBlockOf(
  ContentAssets assets,
  String illustrationId,
) {
  final caption = assets.illustrationTitles[illustrationId];
  if (caption == null) return null;
  return ContentLoaded(
    FigureBlock(illustrationId: illustrationId, caption: caption),
  );
}

ContentLoadResult<ContentBlock>? _diagramBlockOf(
  ContentAssets assets,
  String argument,
) {
  final parsed = DiagramMarkerArgument.parse(argument);
  if (parsed == null) return null;
  final source = assets.exampleSources[parsed.exampleId];
  if (source == null) return null;
  final title = assets.exampleTitles[parsed.exampleId];
  return ContentLoaded(
    DiagramBlock(
      code: source,
      notation: parsed.notation,
      title: title,
    ),
  );
}
