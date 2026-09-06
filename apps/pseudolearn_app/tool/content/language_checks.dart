import 'package:pseudolearn_app/domain/model/knowledge/content_block.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry_type.dart';
import 'package:pseudolearn_app/engine/mapping/profile_catalog.dart';
import 'example_checks.dart';
import 'exercise_checks.dart';
import 'loaded_content.dart';
import 'module_checks.dart';
import 'spec_checks.dart';

List<String> validateLanguage({required LoadedLanguage language}) {
  final errors = <String>[];
  errors.addAll(_validateExamples(language));
  errors.addAll(_validateModules(language));
  errors.addAll(_validateExercises(language));
  errors.addAll(_validateIllustrations(language));
  errors.addAll(checkSpecificationCoverageAndDiagnostics(language: language));
  errors.addAll(checkExamplesReferenced(language));
  errors.addAll(checkSpecificationExamplesMinimal(language));
  return errors;
}

List<String> _validateExamples(LoadedLanguage language) {
  final profile = ProfileCatalog.toLanguageProfile(language.profileId);
  final errors = <String>[];
  for (final id in language.exampleSources.keys) {
    errors.addAll(checkExampleParses(
      exampleId: id,
      sourceCode: language.exampleSources[id]!,
      profile: profile,
      languageCode: language.code,
    ));
  }
  return errors;
}

List<String> _validateModules(LoadedLanguage language) {
  final declaredExercises = language.exercises.keys.toSet();
  final errors = <String>[];
  for (final module in language.modules.values) {
    errors.addAll(checkModuleShape(module, language.code));
    errors.addAll(checkModuleAnchors(
      module,
      language.code,
      language.specificationAnchors,
    ));
    errors.addAll(checkModuleExerciseReferences(
      module,
      language.code,
      declaredExercises,
    ));
    errors.addAll(checkCitedDiagnostics(
      module: module,
      languageCode: language.code,
      profileId: language.profileId,
      languageId: language.languageId,
    ));
  }
  return errors;
}

List<String> _validateExercises(LoadedLanguage language) {
  final errors = <String>[];
  for (final loaded in language.exercises.values) {
    errors.addAll(checkExercise(
      loaded: loaded,
      languageCode: language.code,
      profileId: language.profileId,
      languageId: language.languageId,
    ));
    errors.addAll(checkLevelHonesty(
      exercise: loaded.exercise,
      languageCode: language.code,
      referenceSolution: loaded.referenceSolution,
      profileId: language.profileId,
      constructsAllowed: _constructsAllowedFor(language, loaded),
    ));
  }
  return errors;
}

Set<String> _constructsAllowedFor(
  LoadedLanguage language,
  LoadedExercise loaded,
) {
  final moduleId = loaded.exercise.moduleId;
  if (moduleId == null) return _allConstructs(language);
  final limit = language.modules[moduleId]?.order ?? 0;
  final allowed = <String>{};
  for (final module in language.modules.values) {
    if (module.order > limit) continue;
    allowed.addAll(language.constructsByModule[module.id] ?? const {});
  }
  return allowed;
}

Set<String> _allConstructs(LoadedLanguage language) {
  final all = <String>{};
  for (final declared in language.constructsByModule.values) {
    all.addAll(declared);
  }
  return all;
}

List<String> _validateIllustrations(LoadedLanguage language) {
  final declared = <String>{};
  for (final entry in language.entries) {
    if (entry.type == KnowledgeEntryType.illustration) declared.add(entry.id);
  }
  final referenced = <String>{};
  for (final module in language.modules.values) {
    for (final section in module.sections) {
      referenced.addAll(_figureIdsIn(section.blocks));
    }
  }
  final errors = <String>[];
  for (final id in referenced.difference(declared)) {
    errors.add('Illustration "$id" (${language.code}) is referenced but not declared');
  }
  for (final id in declared.difference(referenced)) {
    errors.add('Illustration "$id" (${language.code}) is declared but never referenced');
  }
  return errors;
}

Set<String> _figureIdsIn(List<ContentBlock> blocks) {
  final ids = <String>{};
  for (final block in blocks) {
    if (block is FigureBlock) ids.add(block.illustrationId);
  }
  return ids;
}
