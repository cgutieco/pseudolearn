import 'package:pseudolearn_app/domain/model/knowledge/content_block.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_case.dart';
import 'package:pseudolearn_app/domain/model/knowledge/learning_module.dart';
import 'package:pseudolearn_app/domain/model/knowledge/module_section.dart';
import 'loaded_content.dart';

List<String> checkModuleParity(LoadedLanguage a, LoadedLanguage b) {
  final errors = <String>[];
  for (final id in a.modules.keys) {
    final other = b.modules[id];
    if (other == null) {
      errors.add('Module "$id" exists in "${a.code}" but not in "${b.code}"');
      continue;
    }
    errors.addAll(_compareModules(id, a, b, a.modules[id]!, other));
  }
  return errors;
}

List<String> _compareModules(
  String id,
  LoadedLanguage a,
  LoadedLanguage b,
  LearningModule one,
  LearningModule other,
) {
  final where = '"$id" between "${a.code}" and "${b.code}"';
  final errors = <String>[];
  if (!_sameParts(one, other)) {
    errors.add('Module $where does not declare the same parts in the same order');
    return errors;
  }
  for (var index = 0; index < one.sections.length; index++) {
    errors.addAll(
      _compareSections(where, one.sections[index], other.sections[index]),
    );
  }
  if (!_sameSet(one.exerciseIds, other.exerciseIds)) {
    errors.add('Module $where does not reference the same exercises');
  }
  if (!_sameSet(one.anchorIds, other.anchorIds)) {
    errors.add('Module $where does not reference the same specification anchors');
  }
  return errors;
}

List<String> _compareSections(
  String where,
  ModuleSection one,
  ModuleSection other,
) {
  final part = one.part.slug;
  final errors = <String>[];
  if (!_sameHeadings(one.blocks, other.blocks)) {
    errors.add('Part "$part" of module $where has a different heading tree');
  }
  if (_countOf<CodeBlock>(one.blocks) != _countOf<CodeBlock>(other.blocks)) {
    errors.add('Part "$part" of module $where has a different number of code blocks');
  }
  if (!_sameSet(_figureIds(one.blocks), _figureIds(other.blocks))) {
    errors.add('Part "$part" of module $where references different illustrations');
  }
  return errors;
}

bool _sameParts(LearningModule one, LearningModule other) {
  if (one.sections.length != other.sections.length) return false;
  for (var index = 0; index < one.sections.length; index++) {
    if (one.sections[index].part != other.sections[index].part) return false;
  }
  return true;
}

bool _sameHeadings(List<ContentBlock> one, List<ContentBlock> other) {
  final levelsOne = _headingLevels(one);
  final levelsOther = _headingLevels(other);
  if (levelsOne.length != levelsOther.length) return false;
  for (var index = 0; index < levelsOne.length; index++) {
    if (levelsOne[index] != levelsOther[index]) return false;
  }
  return true;
}

List<int> _headingLevels(List<ContentBlock> blocks) {
  final levels = <int>[];
  for (final block in blocks) {
    if (block is HeadingBlock) levels.add(block.level);
  }
  return levels;
}

int _countOf<T extends ContentBlock>(List<ContentBlock> blocks) {
  var count = 0;
  for (final block in blocks) {
    if (block is T) count++;
  }
  return count;
}

List<String> _figureIds(List<ContentBlock> blocks) {
  final ids = <String>[];
  for (final block in blocks) {
    if (block is FigureBlock) ids.add(block.illustrationId);
  }
  return ids;
}

bool _sameSet(List<String> one, List<String> other) {
  return one.toSet().difference(other.toSet()).isEmpty &&
      other.toSet().difference(one.toSet()).isEmpty;
}

List<String> checkSpecificationParity(LoadedLanguage a, LoadedLanguage b) {
  final errors = <String>[];
  for (final id in a.specificationBlocks.keys) {
    final other = b.specificationBlocks[id];
    if (other == null) {
      errors.add('Specification section "$id" exists in "${a.code}" but not in "${b.code}"');
      continue;
    }
    final where = '"$id" between "${a.code}" and "${b.code}"';
    final one = a.specificationBlocks[id]!;
    if (!_sameHeadings(one, other)) {
      errors.add('Specification section $where has a different heading tree');
    }
    if (_countOf<CodeBlock>(one) != _countOf<CodeBlock>(other)) {
      errors.add('Specification section $where has a different number of code blocks');
    }
    if (_countOf<TableBlock>(one) != _countOf<TableBlock>(other)) {
      errors.add('Specification section $where has a different number of tables');
    }
  }
  return errors;
}

List<String> checkExerciseParity(LoadedLanguage a, LoadedLanguage b) {
  final errors = <String>[];
  for (final id in a.exercises.keys) {
    final other = b.exercises[id];
    if (other == null) {
      errors.add('Exercise "$id" exists in "${a.code}" but not in "${b.code}"');
      continue;
    }
    final where = '"$id" between "${a.code}" and "${b.code}"';
    errors.addAll(_compareExercises(
      where,
      a.exercises[id]!.exercise,
      other.exercise,
    ));
  }
  return errors;
}

List<String> _compareExercises(String where, Exercise one, Exercise other) {
  final errors = <String>[];
  if (one.level != other.level || one.kind != other.kind) {
    errors.add('Exercise $where is declared with a different level or kind');
  }
  if (!_sameCases(one.visibleCases, other.visibleCases)) {
    errors.add('Exercise $where does not declare the same visible cases');
  }
  if (!_sameCases(one.hiddenCases, other.hiddenCases)) {
    errors.add('Exercise $where does not declare the same hidden cases');
  }
  if (one.assertions.length != other.assertions.length) {
    errors.add('Exercise $where does not declare the same number of assertions');
  }
  return errors;
}

bool _sameCases(List<ExerciseCase> one, List<ExerciseCase> other) {
  if (one.length != other.length) return false;
  for (var index = 0; index < one.length; index++) {
    if (one[index] != other[index]) return false;
  }
  return true;
}
