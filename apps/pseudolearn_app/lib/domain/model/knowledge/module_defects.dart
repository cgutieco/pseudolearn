import 'content_defect.dart';
import 'learning_module.dart';
import 'module_part.dart';

List<ModulePart> missingModuleParts(LearningModule module) {
  final missing = <ModulePart>[];
  for (final part in ModulePart.values) {
    if (module.sectionOf(part) == null) missing.add(part);
  }
  return missing;
}

bool moduleKeepsPartOrder(LearningModule module) {
  var previousIndex = -1;
  for (final section in module.sections) {
    final index = section.part.index;
    if (index <= previousIndex) return false;
    previousIndex = index;
  }
  return true;
}

List<ContentDefect> findModuleDefects(LearningModule module) {
  final defects = <ContentDefect>[];
  if (module.id.trim().isEmpty) defects.add(ContentDefect.emptyIdentifier);
  if (module.title.trim().isEmpty) defects.add(ContentDefect.emptyTitle);
  if (module.sections.isEmpty) {
    defects.add(ContentDefect.moduleWithoutSections);
    return defects;
  }
  if (missingModuleParts(module).isNotEmpty) {
    defects.add(ContentDefect.moduleMissingPart);
  }
  if (!moduleKeepsPartOrder(module)) {
    defects.add(ContentDefect.modulePartsOutOfOrder);
  }
  for (final section in module.sections) {
    if (section.blocks.isEmpty) {
      defects.add(ContentDefect.sectionWithoutBlocks);
      break;
    }
  }
  return defects;
}
