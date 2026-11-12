import '../../domain/model/reference/reference_anatomy.dart';
import '../../domain/model/reference/reference_block.dart';
import '../../domain/model/reference/reference_callout_kind.dart';
import 'reference_figure_parser.dart';
import 'reference_json.dart';
import 'reference_program_parser.dart';
import 'reference_run_parser.dart';

List<ReferenceBlock> parseBlocks(Object? value) =>
    mappedList(value, (block) => parseBlock(objectOf(block)));

ReferenceBlock parseBlock(Map<String, Object?> source) {
  return switch (textOf(source, 'type')) {
    'heading' => ReferenceHeading(
      id: textOf(source, 'id'),
      number: optionalTextOf(source, 'number'),
      runs: parseRuns(source['runs']),
    ),
    'paragraph' => ReferenceParagraph(parseRuns(source['runs'])),
    'list' => ReferenceList(
      ordered: flagOf(source, 'ordered'),
      entries: parseRunGroups(source['entries']),
    ),
    'table' => ReferenceTable(
      header: parseRunGroups(source['header']),
      rows: mappedList(source['rows'], parseRunGroups),
    ),
    'form' => ReferenceFormBlock(mappedList(source['lines'], parseFormLine)),
    final other => _richBlock(other, source),
  };
}

ReferenceBlock _richBlock(String type, Map<String, Object?> source) {
  return switch (type) {
    'anatomy' => ReferenceAnatomy(
      mappedList(source['parts'], parseAnatomyPart),
    ),
    'program' => ReferenceProgramBlock(parseProgram(source)),
    'figure' => ReferenceFigureBlock(parseFigure(source)),
    'callout' => ReferenceCallout(
      kind: parseCalloutKind(textOf(source, 'kind')),
      collapsible: flagOf(source, 'collapsible'),
      blocks: parseBlocks(source['blocks']),
    ),
    'summary' => ReferenceSummary(parseRunGroups(source['points'])),
    'see_also' => ReferenceSeeAlso(mappedList(source['links'], parseSectionLink)),
    _ => _listing(type, source),
  };
}

ReferenceBlock _listing(String type, Map<String, Object?> source) {
  return switch (type) {
    'intermediate' => ReferenceListing(
      kind: ReferenceListingKind.intermediate,
      lines: mappedList(source['lines'], (line) => '$line'),
    ),
    'trace' => ReferenceListing(
      kind: ReferenceListingKind.trace,
      lines: mappedList(source['events'], _traceLine),
    ),
    _ => throw FormatException('unknown block $type'),
  };
}

String _traceLine(Object? value) {
  final source = objectOf(value);
  return '${numberOf(source, 'line')} · ${textOf(source, 'detail')}';
}

ReferenceAnatomyPart parseAnatomyPart(Object? value) {
  final source = objectOf(value);
  return ReferenceAnatomyPart(
    tokens: parseTokens(source['tokens']),
    label: parseRuns(source['label']),
  );
}

ReferenceSectionLink parseSectionLink(Object? value) {
  final source = objectOf(value);
  return ReferenceSectionLink(
    sectionId: textOf(source, 'section'),
    number: textOf(source, 'number'),
    title: textOf(source, 'title'),
  );
}

ReferenceCalloutKind parseCalloutKind(String name) => switch (name) {
  'phrase' => ReferenceCalloutKind.phrase,
  'limit' => ReferenceCalloutKind.limit,
  'inside' => ReferenceCalloutKind.inside,
  'analogy' => ReferenceCalloutKind.analogy,
  'parts' => ReferenceCalloutKind.parts,
  'errors' => ReferenceCalloutKind.errors,
  _ => ReferenceCalloutKind.note,
};
