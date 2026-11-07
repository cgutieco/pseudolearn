import '../../domain/model/reference/reference_index.dart';
import '../../domain/model/reference/reference_links.dart';
import '../../domain/model/reference/reference_search_entry.dart';
import '../../domain/model/reference/reference_section.dart';
import '../../domain/model/reference/reference_section_kind.dart';
import 'reference_block_parser.dart';
import 'reference_json.dart';
import 'reference_run_parser.dart';

ReferenceIndex parseIndex(Object? value) =>
    ReferenceIndex(mappedList(value, _part));

ReferencePart _part(Object? value) {
  final source = objectOf(value);
  return ReferencePart(
    id: textOf(source, 'id'),
    number: textOf(source, 'number'),
    title: textOf(source, 'title'),
    summary: textOf(source, 'summary'),
    sections: mappedList(source['sections'], _entry),
  );
}

ReferenceIndexEntry _entry(Object? value) {
  final source = objectOf(value);
  return ReferenceIndexEntry(
    id: textOf(source, 'id'),
    number: textOf(source, 'number'),
    kind: sectionKindOf(textOf(source, 'kind')),
    title: parseRuns(source['title']),
    phrase: parseRuns(source['phrase']),
  );
}

ReferenceSection parseSection(Object? value) {
  final source = objectOf(value);
  return ReferenceSection(
    id: textOf(source, 'id'),
    number: textOf(source, 'number'),
    kind: sectionKindOf(textOf(source, 'kind')),
    title: parseRuns(source['title']),
    phrase: parseRuns(source['phrase']),
    blocks: parseBlocks(source['blocks']),
  );
}

ReferenceSectionKind sectionKindOf(String name) => switch (name) {
  'concepto' => ReferenceSectionKind.concept,
  'construccion' => ReferenceSectionKind.construction,
  'tipo' => ReferenceSectionKind.type,
  'motor' => ReferenceSectionKind.engine,
  _ => ReferenceSectionKind.appendix,
};

List<ReferenceSearchEntry> parseSearch(Object? value) =>
    mappedList(value, (element) {
      final source = objectOf(element);
      return ReferenceSearchEntry(
        text: textOf(source, 'text'),
        kind: textOf(source, 'kind'),
        sectionId: textOf(source, 'section'),
        anchor: optionalTextOf(source, 'anchor'),
      );
    });

ReferenceLinks parseLinks(Object? value) {
  final source = objectOf(value);
  Map<String, String> table(String key) => objectOf(
    source[key],
  ).map((identity, section) => MapEntry(identity, '$section'));
  return ReferenceLinks(
    cards: table('cards'),
    diagnostics: table('diagnostics'),
  );
}
