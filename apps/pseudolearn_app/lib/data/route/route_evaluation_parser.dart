import '../../domain/model/knowledge/exercise_case.dart';
import '../../domain/model/knowledge/expected_value_kind.dart';
import '../../domain/model/route/route_evaluation.dart';
import '../reference/reference_json.dart';
import '../reference/reference_run_parser.dart';
import 'structural_assertion_reader.dart';

RouteEvaluation parseRouteEvaluation(Map<String, Object?> source) {
  return switch (textOf(source, 'type')) {
    'predict' => PredictEvaluation(textOf(source, 'output')),
    'trace' => TraceEvaluation(
      columns: mappedList(source['columns'], (column) => '$column'),
      rows: mappedList(source['rows'], _traceRow),
    ),
    'order_program' => OrderProgramEvaluation(
      head: textOf(source, 'head'),
      tail: textOf(source, 'tail'),
      blocks: mappedList(source['blocks'], (block) => '$block'),
      solution: mappedList(source['solution'], _integer),
      cases: _cases(source['cases']),
    ),
    'order_steps' => OrderStepsEvaluation(
      steps: parseRunGroups(source['steps']),
      solution: mappedList(source['solution'], _integer),
    ),
    'cases' => _casesEvaluation(source),
    _ => _programEvaluation(textOf(source, 'type'), source),
  };
}

RouteEvaluation _programEvaluation(String type, Map<String, Object?> source) {
  return switch (type) {
    'break' => BreakEvaluation(
      defective: textOf(source, 'defective'),
      reference: textOf(source, 'reference'),
      reads: numberOf(source, 'reads'),
      cases: _cases(source['cases']),
    ),
    'design_tests' => DesignTestsEvaluation(
      reference: textOf(source, 'reference'),
      mutants: mappedList(source['mutants'], (mutant) => '$mutant'),
      reads: numberOf(source, 'reads'),
      minimum: numberOf(source, 'minimum'),
      maximum: numberOf(source, 'maximum'),
    ),
    _ => _choiceEvaluation(type, source),
  };
}

RouteEvaluation _choiceEvaluation(String type, Map<String, Object?> source) {
  return switch (type) {
    'classify' => ClassifyEvaluation(
      categories: mappedList(source['categories'], (category) => '$category'),
      elements: mappedList(source['elements'], _element),
    ),
    'choice' => ChoiceEvaluation(mappedList(source['options'], _option)),
    final other => throw FormatException('unknown evaluation $other'),
  };
}

RouteEvaluation _casesEvaluation(Map<String, Object?> source) {
  final all = mappedList(source['cases'], objectOf);
  final assertions = readStructuralAssertions(
    mappedList(source['assertions'], (raw) => _assertionMap(objectOf(raw))),
  );
  if (assertions == null) {
    throw const FormatException('an assertion is outside the catalog');
  }
  return CasesEvaluation(
    visibleCases: [for (final entry in all) if (!flagOf(entry, 'hidden')) _case(entry)],
    hiddenCases: [for (final entry in all) if (flagOf(entry, 'hidden')) _case(entry)],
    assertions: assertions,
    reference: optionalTextOf(source, 'reference'),
  );
}

Map<String, dynamic> _assertionMap(Map<String, Object?> source) => {
  for (final entry in source.entries)
    entry.key: switch (entry.key) {
      'arity' || 'max' => int.tryParse('${entry.value}'),
      _ => entry.value,
    },
};

List<ExerciseCase> _cases(Object? value) =>
    mappedList(value, (entry) => _case(objectOf(entry)));

ExerciseCase _case(Map<String, Object?> source) {
  final expected = textOf(source, 'expected');
  return ExerciseCase(
    inputs: mappedList(source['inputs'], (input) => '$input'),
    expectedOutputs: expected.isEmpty ? const [] : expected.split('\n'),
    expectedValueKind: ExpectedValueKind.numeric,
  );
}

TraceRow _traceRow(Object? value) {
  final source = objectOf(value);
  return TraceRow(
    label: textOf(source, 'label'),
    cells: mappedList(source['cells'], (cell) {
      final entry = objectOf(cell);
      return TraceCell(
        value: textOf(entry, 'value'),
        editable: flagOf(entry, 'editable'),
      );
    }),
  );
}

ClassifiedEntry _element(Object? value) {
  final source = objectOf(value);
  return ClassifiedEntry(
    runs: parseRuns(source['runs']),
    category: _integer(source['category']),
  );
}

ChoiceOption _option(Object? value) {
  final source = objectOf(value);
  return ChoiceOption(
    runs: parseRuns(source['runs']),
    justification: parseRuns(source['justification']),
    correct: flagOf(source, 'correct'),
  );
}

int _integer(Object? value) {
  if (value is int) return value;
  throw FormatException('expected a whole number, found $value');
}
