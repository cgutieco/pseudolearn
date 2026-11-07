import '../model/knowledge/content_load_result.dart';
import '../model/reference/reference_edition.dart';
import '../model/reference/reference_index.dart';
import '../model/reference/reference_links.dart';
import '../model/reference/reference_search_entry.dart';
import '../model/reference/reference_section.dart';

abstract interface class ReferenceRepository {
  Future<ContentLoadResult<ReferenceIndex>> loadIndex(ReferenceEdition edition);

  Future<ContentLoadResult<ReferenceSection>> loadSection(
    ReferenceEdition edition,
    String sectionId,
  );

  Future<ContentLoadResult<List<ReferenceSearchEntry>>> loadSearch(
    ReferenceEdition edition,
  );

  Future<ContentLoadResult<ReferenceLinks>> loadLinks(ReferenceEdition edition);
}
