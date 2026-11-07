import '../knowledge/exercise_case.dart';

sealed class RouteAnswer {
  const RouteAnswer();
}

final class TextRouteAnswer extends RouteAnswer {
  final String text;

  const TextRouteAnswer(this.text);
}

final class CellsRouteAnswer extends RouteAnswer {
  final Map<(int, int), String> cells;

  const CellsRouteAnswer(this.cells);
}

final class OrderRouteAnswer extends RouteAnswer {
  final List<int> order;

  const OrderRouteAnswer(this.order);
}

final class InputsRouteAnswer extends RouteAnswer {
  final List<String> inputs;

  const InputsRouteAnswer(this.inputs);
}

final class CasesRouteAnswer extends RouteAnswer {
  final List<ExerciseCase> cases;

  const CasesRouteAnswer(this.cases);
}

final class AssignmentRouteAnswer extends RouteAnswer {
  final Map<int, int> categoryByElement;

  const AssignmentRouteAnswer(this.categoryByElement);
}

final class ChoiceRouteAnswer extends RouteAnswer {
  final int option;

  const ChoiceRouteAnswer(this.option);
}
