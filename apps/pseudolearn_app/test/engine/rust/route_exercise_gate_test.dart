import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/route/route_exercise_parser.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/route/route_answer.dart';
import 'package:pseudolearn_app/domain/model/route/route_evaluation.dart';
import 'package:pseudolearn_app/domain/model/route/route_exercise.dart';
import 'package:pseudolearn_app/domain/model/route/route_kinds.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import '../../fakes/native_test_engine.dart';

final class GateExercise {
  final String path;
  final RouteExercise exercise;
  final SyntaxProfileId profile;
  final UiLanguageId language;

  const GateExercise(this.path, this.exercise, this.profile, this.language);
}

List<GateExercise> _load() {
  final files = Directory('assets/route')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.contains('/exercises/'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  return [for (final file in files) _gateOf(file)];
}

GateExercise _gateOf(File file) {
  final segments = file.uri.pathSegments;
  final profile = segments[segments.length - 3];
  final language = segments[segments.length - 4];
  return GateExercise(
    file.path,
    parseRouteExercise(jsonDecode(file.readAsStringSync())),
    profile == 'en' ? SyntaxProfileId.english : SyntaxProfileId.classicSpanish,
    language == 'en' ? UiLanguageId.english : UiLanguageId.spanish,
  );
}

RouteAnswer? _correctAnswer(RouteEvaluation evaluation) => switch (evaluation) {
  PredictEvaluation(:final output) => TextRouteAnswer(output),
  TraceEvaluation(:final rows) => CellsRouteAnswer({
    for (var row = 0; row < rows.length; row++)
      for (var column = 0; column < rows[row].cells.length; column++)
        (row, column): rows[row].cells[column].value,
  }),
  OrderProgramEvaluation(:final solution) => OrderRouteAnswer(solution),
  OrderStepsEvaluation(:final solution) => OrderRouteAnswer(solution),
  ClassifyEvaluation(:final elements) => AssignmentRouteAnswer({
    for (var index = 0; index < elements.length; index++)
      index: elements[index].category,
  }),
  ChoiceEvaluation() => ChoiceRouteAnswer(evaluation.correctIndex),
  _ => null,
};

void main() {
  final exercises = _load();

  test('the bundled route has exercises in the four editions', () {
    expect(exercises.length % 4, 0);
    expect(exercises, isNotEmpty);
  });

  test('every reference solution passes the app checker', () {
    for (final gate in exercises) {
      final evaluation = gate.exercise.evaluation;
      if (evaluation is! CasesEvaluation) continue;
      final result = nativeTestEngine.exerciseChecker.check(
        sourceCode: evaluation.reference,
        profileId: gate.profile,
        languageId: gate.language,
        visibleCases: evaluation.visibleCases,
        hiddenCases: evaluation.hiddenCases,
        assertions: evaluation.assertions,
      );
      expect(result.isSolved, isTrue, reason: '${gate.path}: ${result.outcome}');
    }
  });

  test('every structural modification starts from a program that fails the checker', () {
    for (final gate in exercises) {
      final evaluation = gate.exercise.evaluation;
      final starter = gate.exercise.starterCode;
      if (evaluation is! CasesEvaluation || evaluation.assertions.isEmpty) continue;
      if (gate.exercise.kind != RouteExerciseKind.modify || starter == null) continue;
      final result = nativeTestEngine.exerciseChecker.check(
        sourceCode: starter,
        profileId: gate.profile,
        languageId: gate.language,
        visibleCases: evaluation.visibleCases,
        hiddenCases: evaluation.hiddenCases,
        assertions: evaluation.assertions,
      );
      expect(result.isSolved, isFalse, reason: gate.path);
    }
  });

  test('every published answer key is accepted by its evaluator', () {
    for (final gate in exercises) {
      final answer = _correctAnswer(gate.exercise.evaluation);
      final evaluator = nativeTestEngine.routeEvaluators[gate.exercise.kind];
      if (answer == null || evaluator == null) continue;
      final verdict = evaluator.evaluate(
        exercise: gate.exercise,
        answer: answer,
        profileId: gate.profile,
        languageId: gate.language,
      );
      expect(verdict.solved, isTrue, reason: gate.path);
    }
  });
}
