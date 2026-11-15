import 'reference_block.dart';
import 'reference_run.dart';
import 'reference_section_kind.dart';

final class ReferenceSection {
  final String id;
  final String number;
  final ReferenceSectionKind kind;
  final List<ReferenceRun> title;
  final List<ReferenceRun> phrase;
  final List<ReferenceBlock> blocks;

  const ReferenceSection({
    required this.id,
    required this.number,
    required this.kind,
    required this.title,
    required this.phrase,
    required this.blocks,
  });

  List<ReferenceHeading> get headings =>
      blocks.whereType<ReferenceHeading>().toList();
}
