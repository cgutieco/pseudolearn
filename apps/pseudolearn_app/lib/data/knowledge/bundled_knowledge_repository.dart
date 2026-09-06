import '../../domain/model/knowledge/content_block.dart';
import '../../domain/model/knowledge/content_load_failure.dart';
import '../../domain/model/knowledge/content_load_result.dart';
import '../../domain/model/knowledge/exercise.dart';
import '../../domain/model/knowledge/knowledge_entry.dart';
import '../../domain/model/knowledge/knowledge_entry_type.dart';
import '../../domain/model/knowledge/learning_module.dart';
import '../../domain/model/knowledge/learning_track.dart';
import '../../domain/model/knowledge/module_part.dart';
import '../../domain/model/knowledge/module_section.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/knowledge_repository.dart';
import 'content_assets.dart';
import 'exercise_document_parser.dart';
import 'referenced_content_ids.dart';
import 'knowledge_manifest_reader.dart';
import 'markdown_block_parser.dart';
import 'marker_resolver.dart';
import 'module_document_parser.dart';
import 'module_references.dart';

typedef AssetLoader = Future<String> Function(String path);

const String knowledgeAssetRoot = 'assets/knowledge/';

final class BundledKnowledgeRepository implements KnowledgeRepository {
  final AssetLoader _assetLoader;
  final MarkdownBlockParser _markdown;
  final ModuleDocumentParser _moduleParser;
  final ExerciseDocumentParser _exerciseParser;
  final KnowledgeManifestReader _manifestReader;
  final MarkerResolver _markers;

  BundledKnowledgeRepository({
    required MarkerResolver markers,
    required AssetLoader assetLoader,
    MarkdownBlockParser? markdown,
    ModuleDocumentParser? moduleParser,
    ExerciseDocumentParser? exerciseParser,
    KnowledgeManifestReader? manifestReader,
  })  : _markers = markers,
        _assetLoader = assetLoader,
        _markdown = markdown ?? const MarkdownBlockParser(),
        _moduleParser = moduleParser ?? const ModuleDocumentParser(),
        _exerciseParser = exerciseParser ?? const ExerciseDocumentParser(),
        _manifestReader = manifestReader ?? const KnowledgeManifestReader();

  @override
  Future<ContentLoadResult<List<KnowledgeEntry>>> getEntries(
    UiLanguageId language,
  ) async {
    final source = await _read(_manifestPathFor(language));
    if (source == null) {
      return ContentLoadFailed(
        failure: ContentLoadFailure.assetMissing,
        detail: _manifestPathFor(language),
      );
    }
    return _manifestReader.read(source);
  }

  @override
  Future<ContentLoadResult<List<ContentBlock>>> getDocumentBlocks({
    required String path,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) async {
    final source = await _read(path);
    if (source == null) {
      return ContentLoadFailed(
        failure: ContentLoadFailure.assetMissing,
        detail: path,
      );
    }
    return _resolveMarkers(
      blocks: _markdown.parse(source),
      profileId: profileId,
      languageId: languageId,
    );
  }

  @override
  Future<ContentLoadResult<LearningModule>> getModule({
    required KnowledgeEntry entry,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) async {
    final track = entry.track;
    final source = await _read(entry.path ?? '');
    if (source == null || track == null) {
      return ContentLoadFailed(
        failure: source == null
            ? ContentLoadFailure.assetMissing
            : ContentLoadFailure.malformedManifest,
        detail: entry.id,
      );
    }
    final parsed = _moduleParser.parse(source);
    return switch (parsed) {
      ContentLoadFailed(:final failure, :final detail) =>
        ContentLoadFailed(failure: failure, detail: detail),
      ContentLoaded(:final value) => await _moduleOf(
          entry: entry,
          track: track,
          sections: value,
          profileId: profileId,
          languageId: languageId,
        ),
    };
  }

  @override
  Future<ContentLoadResult<Exercise>> getExercise(String path) async {
    final source = await _read(path);
    if (source == null) {
      return ContentLoadFailed(
        failure: ContentLoadFailure.assetMissing,
        detail: path,
      );
    }
    return _exerciseParser.parse(source);
  }

  @override
  Future<String> getRawContent(String path) async {
    return await _read(path) ?? '';
  }

  Future<ContentLoadResult<LearningModule>> _moduleOf({
    required KnowledgeEntry entry,
    required LearningTrack track,
    required List<ModuleSection> sections,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) async {
    final resolved = <ModuleSection>[];
    for (final section in sections) {
      final blocks = await _resolveMarkers(
        blocks: section.blocks,
        profileId: profileId,
        languageId: languageId,
      );
      if (blocks is ContentLoadFailed<List<ContentBlock>>) {
        return ContentLoadFailed(
          failure: blocks.failure,
          detail: blocks.detail,
        );
      }
      resolved.add(ModuleSection(
        part: section.part,
        blocks: (blocks as ContentLoaded<List<ContentBlock>>).value,
      ));
    }
    return ContentLoaded(_assemble(entry: entry, track: track, sections: resolved));
  }

  LearningModule _assemble({
    required KnowledgeEntry entry,
    required LearningTrack track,
    required List<ModuleSection> sections,
  }) {
    return LearningModule(
      id: entry.id,
      track: track,
      order: entry.order,
      title: entry.title,
      sections: sections,
      exerciseIds: leadingTokensOfListItems(_blocksOfPart(sections, ModulePart.exercises)),
      anchorIds: leadingTokensOfListItems(_blocksOfPart(sections, ModulePart.specificationAnchors)),
      predictionActivity: predictionActivityOf(_blocksOfPart(sections, ModulePart.prediction), entry.id),
    );
  }

  List<ContentBlock> _blocksOfPart(
    List<ModuleSection> sections,
    ModulePart part,
  ) {
    for (final section in sections) {
      if (section.part == part) return section.blocks;
    }
    return const [];
  }

  Future<ContentLoadResult<List<ContentBlock>>> _resolveMarkers({
    required List<ContentBlock> blocks,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) async {
    return _markers.resolveAll(
      blocks: blocks,
      profileId: profileId,
      languageId: languageId,
      assets: await _contentAssets(blocks, languageId),
    );
  }

  Future<ContentAssets> _contentAssets(
    List<ContentBlock> blocks,
    UiLanguageId languageId,
  ) async {
    final ids = referencedContentIds(_markers.markersIn(blocks));
    if (ids.isEmpty) return ContentAssets.none;
    final entries = await getEntries(languageId);
    if (entries is! ContentLoaded<List<KnowledgeEntry>>) {
      return ContentAssets.none;
    }
    final sources = <String, String>{};
    final titles = <String, String>{};
    final captions = <String, String>{};
    for (final entry in entries.value) {
      if (!ids.contains(entry.id)) continue;
      if (entry.type == KnowledgeEntryType.illustration) {
        captions[entry.id] = entry.title;
        continue;
      }
      titles[entry.id] = entry.title;
      final source = await _read(entry.path ?? '');
      if (source != null) sources[entry.id] = source;
    }
    return ContentAssets(
      exampleSources: sources,
      exampleTitles: titles,
      illustrationTitles: captions,
    );
  }

  Future<String?> _read(String path) async {
    if (path.isEmpty) return null;
    final fullPath =
        path.startsWith(knowledgeAssetRoot) ? path : '$knowledgeAssetRoot$path';
    try {
      return await _assetLoader(fullPath);
    } catch (_) {
      return null;
    }
  }

  String _manifestPathFor(UiLanguageId language) {
    final code = language == UiLanguageId.english ? 'en' : 'es';
    return 'manifest_$code.json';
  }
}
