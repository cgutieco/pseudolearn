import 'package:pseudolearn_app/domain/model/knowledge/learning_module.dart';
import 'package:pseudolearn_app/domain/model/knowledge/module_defects.dart';
import 'package:pseudolearn_app/domain/model/knowledge/module_part.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'spec_checks.dart';

const String moduleWithoutExercises = 'CON-A1';

List<String> checkModuleShape(LearningModule module, String languageCode) {
  final errors = <String>[];
  final missing = missingModuleParts(module);
  for (final part in missing) {
    if (part == ModulePart.exercises && module.id == moduleWithoutExercises) {
      continue;
    }
    errors.add(
      'Module "${module.id}" ($languageCode) is missing its "${part.slug}" part',
    );
  }
  if (!moduleKeepsPartOrder(module)) {
    errors.add(
      'Module "${module.id}" ($languageCode) declares its parts out of order',
    );
  }
  return errors;
}

List<String> checkModuleAnchors(
  LearningModule module,
  String languageCode,
  Set<String> declaredAnchors,
) {
  final errors = <String>[];
  for (final anchor in module.anchorIds) {
    if (declaredAnchors.contains(anchor)) continue;
    errors.add(
      'Module "${module.id}" ($languageCode) anchors "$anchor", which no '
      'specification section declares',
    );
  }
  return errors;
}

List<String> checkModuleExerciseReferences(
  LearningModule module,
  String languageCode,
  Set<String> declaredExercises,
) {
  final errors = <String>[];
  for (final exerciseId in module.exerciseIds) {
    if (declaredExercises.contains(exerciseId)) continue;
    errors.add(
      'Module "${module.id}" ($languageCode) lists exercise "$exerciseId", '
      'which the manifest does not declare',
    );
  }
  return errors;
}

List<String> checkCitedDiagnostics({
  required LearningModule module,
  required String languageCode,
  required SyntaxProfileId profileId,
  required UiLanguageId languageId,
}) {
  final section = module.sectionOf(ModulePart.commonErrors);
  if (section == null) return const [];
  final cited = citedCodesOf(section.blocks);
  if (cited.isEmpty) return const [];
  final produced = producedDiagnosticCodes(
    programs: programsOf(section.blocks),
    profileId: profileId,
    languageId: languageId,
  );
  final errors = <String>[];
  for (final code in cited) {
    if (produced.contains(code)) continue;
    errors.add(
      'Module "${module.id}" ($languageCode) cites diagnostic "$code", but no '
      'program in its common errors part produces it',
    );
  }
  return errors;
}
