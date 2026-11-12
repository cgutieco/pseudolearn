import 'reference_anatomy.dart';
import 'reference_callout_kind.dart';
import 'reference_figure.dart';
import 'reference_form.dart';
import 'reference_program.dart';
import 'reference_run.dart';

sealed class ReferenceBlock {
  const ReferenceBlock();
}

final class ReferenceHeading extends ReferenceBlock {
  final String id;
  final String number;
  final List<ReferenceRun> runs;

  const ReferenceHeading({
    required this.id,
    required this.number,
    required this.runs,
  });
}

final class ReferenceParagraph extends ReferenceBlock {
  final List<ReferenceRun> runs;

  const ReferenceParagraph(this.runs);
}

final class ReferenceList extends ReferenceBlock {
  final bool ordered;
  final List<List<ReferenceRun>> entries;

  const ReferenceList({required this.ordered, required this.entries});
}

final class ReferenceTable extends ReferenceBlock {
  final List<List<ReferenceRun>> header;
  final List<List<List<ReferenceRun>>> rows;

  const ReferenceTable({required this.header, required this.rows});
}

final class ReferenceFormBlock extends ReferenceBlock {
  final List<List<ReferenceFormSegment>> lines;

  const ReferenceFormBlock(this.lines);
}

final class ReferenceAnatomy extends ReferenceBlock {
  final List<ReferenceAnatomyPart> parts;

  const ReferenceAnatomy(this.parts);
}

final class ReferenceProgramBlock extends ReferenceBlock {
  final ReferenceProgram program;

  const ReferenceProgramBlock(this.program);
}

final class ReferenceFigureBlock extends ReferenceBlock {
  final ReferenceFigure figure;

  const ReferenceFigureBlock(this.figure);
}

final class ReferenceCallout extends ReferenceBlock {
  final ReferenceCalloutKind kind;
  final bool collapsible;
  final List<ReferenceBlock> blocks;

  const ReferenceCallout({
    required this.kind,
    required this.collapsible,
    required this.blocks,
  });
}

final class ReferenceSummary extends ReferenceBlock {
  final List<List<ReferenceRun>> points;

  const ReferenceSummary(this.points);
}

final class ReferenceSeeAlso extends ReferenceBlock {
  final List<ReferenceSectionLink> links;

  const ReferenceSeeAlso(this.links);
}

final class ReferenceSectionLink {
  final String sectionId;
  final String number;
  final String title;

  const ReferenceSectionLink({
    required this.sectionId,
    required this.number,
    required this.title,
  });
}

final class ReferenceListing extends ReferenceBlock {
  final ReferenceListingKind kind;
  final List<String> lines;

  const ReferenceListing({required this.kind, required this.lines});
}

enum ReferenceListingKind { intermediate, trace }
