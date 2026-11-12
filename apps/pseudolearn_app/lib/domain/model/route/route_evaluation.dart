import '../knowledge/exercise_case.dart';
import '../knowledge/structural_assertion.dart';
import '../reference/reference_run.dart';

final class TraceCell {
  final String value;
  final bool editable;

  const TraceCell({required this.value, required this.editable});
}

final class TraceRow {
  final String label;
  final List<TraceCell> cells;

  const TraceRow({required this.label, required this.cells});
}

final class ClassifiedEntry {
  final List<ReferenceRun> runs;
  final int category;

  const ClassifiedEntry({required this.runs, required this.category});
}

final class ChoiceOption {
  final List<ReferenceRun> runs;
  final List<ReferenceRun> justification;
  final bool correct;

  const ChoiceOption({
    required this.runs,
    required this.justification,
    required this.correct,
  });
}

sealed class RouteEvaluation {
  const RouteEvaluation();
}

final class PredictEvaluation extends RouteEvaluation {
  final String output;

  const PredictEvaluation(this.output);
}

final class TraceEvaluation extends RouteEvaluation {
  final List<String> columns;
  final List<TraceRow> rows;

  const TraceEvaluation({required this.columns, required this.rows});
}

final class OrderProgramEvaluation extends RouteEvaluation {
  final String head;
  final String tail;
  final List<String> blocks;
  final List<int> solution;
  final List<ExerciseCase> cases;

  const OrderProgramEvaluation({
    required this.head,
    required this.tail,
    required this.blocks,
    required this.solution,
    required this.cases,
  });
}

final class OrderStepsEvaluation extends RouteEvaluation {
  final List<List<ReferenceRun>> steps;
  final List<int> solution;

  const OrderStepsEvaluation({required this.steps, required this.solution});
}

final class CasesEvaluation extends RouteEvaluation {
  final List<ExerciseCase> visibleCases;
  final List<ExerciseCase> hiddenCases;
  final List<StructuralAssertion> assertions;
  final String reference;

  const CasesEvaluation({
    required this.visibleCases,
    required this.hiddenCases,
    required this.assertions,
    required this.reference,
  });
}

final class BreakEvaluation extends RouteEvaluation {
  final String defective;
  final String reference;
  final int reads;
  final List<ExerciseCase> cases;

  const BreakEvaluation({
    required this.defective,
    required this.reference,
    required this.reads,
    required this.cases,
  });
}

final class DesignTestsEvaluation extends RouteEvaluation {
  final String reference;
  final List<String> mutants;
  final int reads;
  final int minimum;
  final int maximum;

  const DesignTestsEvaluation({
    required this.reference,
    required this.mutants,
    required this.reads,
    required this.minimum,
    required this.maximum,
  });
}

final class ClassifyEvaluation extends RouteEvaluation {
  final List<String> categories;
  final List<ClassifiedEntry> elements;

  const ClassifyEvaluation({required this.categories, required this.elements});
}

final class ChoiceEvaluation extends RouteEvaluation {
  final List<ChoiceOption> options;

  const ChoiceEvaluation(this.options);

  int get correctIndex => options.indexWhere((option) => option.correct);
}
