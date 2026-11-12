import 'package:pseudolearn_app/domain/model/knowledge/content_load_failure.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_load_result.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_edition.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_index.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_links.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_search_entry.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_section.dart';
import 'package:pseudolearn_app/domain/ports/reference_repository.dart';

class FakeReferenceRepository implements ReferenceRepository {
  final ReferenceIndex index;
  final Map<String, ReferenceSection> sections;
  final List<ReferenceSearchEntry> search;
  final ReferenceLinks links;
  final List<ReferenceEdition> requestedEditions = [];

  FakeReferenceRepository({
    this.index = const ReferenceIndex.empty(),
    this.sections = const {},
    this.search = const [],
    this.links = const ReferenceLinks.empty(),
  });

  @override
  Future<ContentLoadResult<ReferenceIndex>> loadIndex(
    ReferenceEdition edition,
  ) async {
    requestedEditions.add(edition);
    return ContentLoaded(index);
  }

  @override
  Future<ContentLoadResult<ReferenceSection>> loadSection(
    ReferenceEdition edition,
    String sectionId,
  ) async {
    final section = sections[sectionId];
    if (section == null) {
      return ContentLoadFailed(
        failure: ContentLoadFailure.assetMissing,
        detail: sectionId,
      );
    }
    return ContentLoaded(section);
  }

  @override
  Future<ContentLoadResult<List<ReferenceSearchEntry>>> loadSearch(
    ReferenceEdition edition,
  ) async => ContentLoaded(search);

  @override
  Future<ContentLoadResult<ReferenceLinks>> loadLinks(
    ReferenceEdition edition,
  ) async => ContentLoaded(links);
}
