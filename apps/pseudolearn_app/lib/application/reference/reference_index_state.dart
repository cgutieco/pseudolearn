import '../../domain/model/reference/reference_edition.dart';
import '../../domain/model/reference/reference_index.dart';
import '../../domain/model/reference/reference_links.dart';
import '../../domain/model/reference/reference_search_entry.dart';

enum ReferenceIndexStatus { initial, loading, success, error }

final class ReferenceIndexState {
  final ReferenceIndexStatus status;
  final ReferenceEdition? edition;
  final ReferenceIndex index;
  final List<ReferenceSearchEntry> searchEntries;
  final ReferenceLinks links;
  final String query;

  const ReferenceIndexState({
    this.status = ReferenceIndexStatus.initial,
    this.edition,
    this.index = const ReferenceIndex.empty(),
    this.searchEntries = const [],
    this.links = const ReferenceLinks.empty(),
    this.query = '',
  });

  bool get isSearching => query.trim().isNotEmpty;

  List<ReferencePart> get visibleParts {
    if (!isSearching) return index.parts;
    final matching = matchingSectionIds;
    return [
      for (final part in index.parts)
        if (part.sections.any((section) => matching.contains(section.id)))
          ReferencePart(
            id: part.id,
            number: part.number,
            title: part.title,
            summary: part.summary,
            sections: part.sections
                .where((section) => matching.contains(section.id))
                .toList(),
          ),
    ];
  }

  Set<String> get matchingSectionIds {
    final folded = foldSearchText(query.trim());
    return {
      for (final entry in searchEntries)
        if (entry.matches(folded)) entry.sectionId,
    };
  }

  ReferenceIndexState copyWith({
    ReferenceIndexStatus? status,
    ReferenceEdition? edition,
    ReferenceIndex? index,
    List<ReferenceSearchEntry>? searchEntries,
    ReferenceLinks? links,
    String? query,
  }) {
    return ReferenceIndexState(
      status: status ?? this.status,
      edition: edition ?? this.edition,
      index: index ?? this.index,
      searchEntries: searchEntries ?? this.searchEntries,
      links: links ?? this.links,
      query: query ?? this.query,
    );
  }
}
