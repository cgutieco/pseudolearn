import '../domain/model/route/route_kinds.dart';
import '../domain/ports/program_analyzer.dart';
import '../domain/ports/program_execution.dart';
import '../domain/ports/route_answer_evaluator.dart';
import '../engine/exercise/behaviour_checker.dart';
import '../engine/exercise/program_runner.dart';
import '../engine/route_exercise/break_evaluator.dart';
import '../engine/route_exercise/choice_evaluator.dart';
import '../engine/route_exercise/classify_evaluator.dart';
import '../engine/route_exercise/design_tests_evaluator.dart';
import '../engine/route_exercise/order_evaluator.dart';
import '../engine/route_exercise/prediction_evaluator.dart';
import '../engine/route_exercise/trace_evaluator.dart';

Map<RouteExerciseKind, RouteAnswerEvaluator> buildRouteEvaluators({
  required ProgramExecution execution,
  required ProgramAnalyzer analyzer,
}) {
  final runner = ProgramRunner(execution: execution, analyzer: analyzer);
  return {
    RouteExerciseKind.predict: const PredictionEvaluator(),
    RouteExerciseKind.trace: const TraceEvaluator(),
    RouteExerciseKind.order: OrderEvaluator(
      behaviour: BehaviourChecker(execution: execution, analyzer: analyzer),
    ),
    RouteExerciseKind.breakIt: BreakEvaluator(runner: runner),
    RouteExerciseKind.designTests: DesignTestsEvaluator(runner: runner),
    RouteExerciseKind.classify: const ClassifyEvaluator(),
    RouteExerciseKind.compare: const ChoiceEvaluator(),
    RouteExerciseKind.explain: const ChoiceEvaluator(),
  };
}
