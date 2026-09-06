import 'package:pseudolearn_app/domain/model/knowledge/exercise.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_case.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_check_outcome.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_defects.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_level.dart';
import 'package:pseudolearn_app/domain/model/knowledge/expected_value_kind.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/analysis/core_program_analyzer.dart';
import 'package:pseudolearn_app/engine/execution/core_program_execution.dart';
import 'package:pseudolearn_app/engine/exercise/behaviour_checker.dart';
import 'package:pseudolearn_app/engine/exercise/exercise_check_runner.dart';
import 'package:pseudolearn_app/engine/exercise/program_structure.dart';
import 'package:pseudolearn_app/engine/exercise/structural_assertion_checker.dart';
import 'loaded_content.dart';

ExerciseCheckRunner _runner() {
  return ExerciseCheckRunner(
    behaviour: BehaviourChecker(
      execution: CoreProgramExecution(),
      analyzer: CoreProgramAnalyzer(),
      stepLimit: 20000,
    ),
    structure: StructuralAssertionChecker(),
  );
}

List<String> checkExercise({
  required LoadedExercise loaded,
  required String languageCode,
  required SyntaxProfileId profileId,
  required UiLanguageId languageId,
}) {
  final exercise = loaded.exercise;
  final errors = <String>[];
  for (final defect in findExerciseDefects(exercise)) {
    errors.add('Exercise "${exercise.id}" ($languageCode): ${defect.name}');
  }
  errors.addAll(_checkReferenceSolution(
    loaded: loaded,
    languageCode: languageCode,
    profileId: profileId,
    languageId: languageId,
  ));
  errors.addAll(_checkDiscrimination(
    exercise: exercise,
    languageCode: languageCode,
    profileId: profileId,
    languageId: languageId,
  ));
  return errors;
}

List<String> _checkReferenceSolution({
  required LoadedExercise loaded,
  required String languageCode,
  required SyntaxProfileId profileId,
  required UiLanguageId languageId,
}) {
  final exercise = loaded.exercise;
  if (loaded.referenceSolution.trim().isEmpty) {
    return ['Exercise "${exercise.id}" ($languageCode) has no reference solution'];
  }
  final result = _runner().check(
    sourceCode: loaded.referenceSolution,
    profileId: profileId,
    languageId: languageId,
    visibleCases: exercise.visibleCases,
    hiddenCases: exercise.hiddenCases,
    assertions: exercise.assertions,
  );
  if (result.isSolved) return const [];
  return [
    'Exercise "${exercise.id}" ($languageCode): the reference solution does not solve it '
        '(${result.outcome.name}, ${result.passedCases}/${result.totalCases} cases, '
        '${result.unmetAssertions.length} unmet assertions)',
  ];
}

List<String> _checkDiscrimination({
  required Exercise exercise,
  required String languageCode,
  required SyntaxProfileId profileId,
  required UiLanguageId languageId,
}) {
  if (exercise.hiddenCases.isEmpty) return const [];
  final impostor = impostorProgramFor(
    visibleCases: exercise.visibleCases,
    profileId: profileId,
  );
  final result = _runner().check(
    sourceCode: impostor,
    profileId: profileId,
    languageId: languageId,
    visibleCases: const [],
    hiddenCases: exercise.hiddenCases,
    assertions: const [],
  );
  if (result.outcome != ExerciseCheckOutcome.allCasesPassed) return const [];
  return [
    'Exercise "${exercise.id}" ($languageCode): its hidden cases do not discriminate a '
        'program that writes the visible answers as constants',
  ];
}

String impostorProgramFor({
  required List<ExerciseCase> visibleCases,
  required SyntaxProfileId profileId,
}) {
  final isEnglish = profileId == SyntaxProfileId.english;
  final lines = <String>[isEnglish ? 'algorithm Impostor' : 'Algoritmo Impostor'];
  final write = isEnglish ? 'write' : 'Escribir';
  for (final output in _visibleOutputs(visibleCases)) {
    lines.add('  $write $output');
  }
  lines.add(isEnglish ? 'endAlgorithm' : 'FinAlgoritmo');
  return lines.join('\n');
}

List<String> _visibleOutputs(List<ExerciseCase> visibleCases) {
  if (visibleCases.isEmpty) return const [];
  final first = visibleCases.first;
  return [
    for (final output in first.expectedOutputs)
      first.expectedValueKind == ExpectedValueKind.numeric
          ? output
          : '"$output"',
  ];
}

List<String> checkLevelHonesty({
  required Exercise exercise,
  required String languageCode,
  required String referenceSolution,
  required SyntaxProfileId profileId,
  required Set<String> constructsAllowed,
}) {
  if (exercise.level != ExerciseLevel.reproduce) return const [];
  if (referenceSolution.trim().isEmpty) return const [];
  final used = constructsUsedIn(referenceSolution, profileId);
  final beyond = used.difference(constructsAllowed);
  if (beyond.isEmpty) return const [];
  return [
    'Exercise "${exercise.id}" ($languageCode) is declared level 1 but its reference '
        'solution uses constructs beyond its module: ${beyond.join(', ')}',
  ];
}

Set<String> constructsUsedIn(String sourceCode, SyntaxProfileId profileId) {
  final unit = StructuralAssertionChecker().sourceUnitOf(sourceCode, profileId);
  if (unit == null) return const {};
  final structure = ProgramStructure.of(unit);
  return structure.usedConstructs.map((construct) => construct.slug).toSet();
}
