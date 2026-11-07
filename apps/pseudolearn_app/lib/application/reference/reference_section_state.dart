import '../../domain/model/reference/reference_edition.dart';
import '../../domain/model/reference/reference_section.dart';

enum ReferenceSectionStatus { initial, loading, success, notFound }

final class ReferenceSectionState {
  final ReferenceEdition? edition;
  final Map<String, ReferenceSection> sections;
  final Set<String> loading;
  final Set<String> missing;

  const ReferenceSectionState({
    this.edition,
    this.sections = const {},
    this.loading = const {},
    this.missing = const {},
  });

  ReferenceSectionStatus statusOf(String sectionId) {
    if (sections.containsKey(sectionId)) return ReferenceSectionStatus.success;
    if (missing.contains(sectionId)) return ReferenceSectionStatus.notFound;
    if (loading.contains(sectionId)) return ReferenceSectionStatus.loading;
    return ReferenceSectionStatus.initial;
  }

  ReferenceSection? sectionOf(String sectionId) => sections[sectionId];
}
