import 'content_defect.dart';
import 'specification_section.dart';

List<ContentDefect> findSpecificationSectionDefects(
  SpecificationSection section,
) {
  final defects = <ContentDefect>[];
  if (section.id.trim().isEmpty) defects.add(ContentDefect.emptyIdentifier);
  if (section.title.trim().isEmpty) defects.add(ContentDefect.emptyTitle);
  if (section.anchor.trim().isEmpty) defects.add(ContentDefect.emptyAnchor);
  if (section.blocks.isEmpty) defects.add(ContentDefect.sectionWithoutBlocks);
  return defects;
}
