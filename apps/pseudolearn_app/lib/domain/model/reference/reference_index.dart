import 'reference_run.dart';
import 'reference_section_kind.dart';

final class ReferenceIndexEntry {
  final String id;
  final String number;
  final ReferenceSectionKind kind;
  final List<ReferenceRun> title;
  final List<ReferenceRun> phrase;

  const ReferenceIndexEntry({
    required this.id,
    required this.number,
    required this.kind,
    required this.title,
    required this.phrase,
  });
}

final class ReferencePart {
  final String id;
  final String number;
  final String title;
  final String summary;
  final List<ReferenceIndexEntry> sections;

  const ReferencePart({
    required this.id,
    required this.number,
    required this.title,
    required this.summary,
    required this.sections,
  });
}

final class ReferenceIndex {
  final List<ReferencePart> parts;

  const ReferenceIndex(this.parts);

  const ReferenceIndex.empty() : parts = const [];

  List<ReferenceIndexEntry> get sections => [
    for (final part in parts) ...part.sections,
  ];

  ReferenceIndexEntry? entry(String id) {
    for (final section in sections) {
      if (section.id == id) return section;
    }
    return null;
  }
}
