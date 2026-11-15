import 'dart:convert';
import '../../domain/model/knowledge/content_load_failure.dart';
import '../../domain/model/knowledge/content_load_result.dart';
import '../../domain/model/reference/reference_edition.dart';
import '../../domain/model/reference/reference_index.dart';
import '../../domain/model/reference/reference_links.dart';
import '../../domain/model/reference/reference_search_entry.dart';
import '../../domain/model/reference/reference_section.dart';
import '../../domain/ports/reference_repository.dart';
import 'reference_index_parser.dart';

typedef ReferenceAssetLoader = Future<String> Function(String path);

const String referenceAssetRoot = 'assets/reference/';

final class BundledReferenceRepository implements ReferenceRepository {
  final ReferenceAssetLoader _assetLoader;

  const BundledReferenceRepository({required this._assetLoader});

  @override
  Future<ContentLoadResult<ReferenceIndex>> loadIndex(
    ReferenceEdition edition,
  ) => _load(edition, 'toc.json', parseIndex);

  @override
  Future<ContentLoadResult<ReferenceSection>> loadSection(
    ReferenceEdition edition,
    String sectionId,
  ) => _load(edition, 'sections/$sectionId.json', parseSection);

  @override
  Future<ContentLoadResult<List<ReferenceSearchEntry>>> loadSearch(
    ReferenceEdition edition,
  ) => _load(edition, 'search.json', parseSearch);

  @override
  Future<ContentLoadResult<ReferenceLinks>> loadLinks(
    ReferenceEdition edition,
  ) => _load(edition, 'links.json', parseLinks);

  Future<ContentLoadResult<T>> _load<T>(
    ReferenceEdition edition,
    String file,
    T Function(Object? json) parse,
  ) async {
    final path = '$referenceAssetRoot${edition.directory}/$file';
    final String text;
    try {
      text = await _assetLoader(path);
    } catch (_) {
      return ContentLoadFailed(
        failure: ContentLoadFailure.assetMissing,
        detail: path,
      );
    }
    try {
      return ContentLoaded(parse(jsonDecode(text)));
    } on FormatException catch (error) {
      return ContentLoadFailed(
        failure: ContentLoadFailure.malformedReference,
        detail: '$path: ${error.message}',
      );
    }
  }
}
