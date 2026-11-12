import '../knowledge/exercise_case_failure.dart';
import '../knowledge/exercise_check_outcome.dart';

sealed class RouteFeedback {
  const RouteFeedback();
}

final class NoFeedback extends RouteFeedback {
  const NoFeedback();
}

final class LineMismatchFeedback extends RouteFeedback {
  final int line;

  const LineMismatchFeedback(this.line);
}

final class WrongCellsFeedback extends RouteFeedback {
  final Set<(int, int)> cells;

  const WrongCellsFeedback(this.cells);
}

final class CaseFailureFeedback extends RouteFeedback {
  final ExerciseCheckOutcome outcome;
  final ExerciseCaseFailure? failure;

  const CaseFailureFeedback({required this.outcome, this.failure});
}

final class UnbrokenFeedback extends RouteFeedback {
  final List<String> defectiveOutput;
  final List<String> referenceOutput;

  const UnbrokenFeedback({
    required this.defectiveOutput,
    required this.referenceOutput,
  });
}

final class WrongCountFeedback extends RouteFeedback {
  final int minimum;
  final int maximum;

  const WrongCountFeedback({required this.minimum, required this.maximum});
}

final class ReferenceRejectsFeedback extends RouteFeedback {
  final int caseIndex;
  final List<String> referenceOutput;

  const ReferenceRejectsFeedback({
    required this.caseIndex,
    required this.referenceOutput,
  });
}

final class SurvivorsFeedback extends RouteFeedback {
  final int survivors;

  const SurvivorsFeedback(this.survivors);
}

final class MisplacedFeedback extends RouteFeedback {
  final Set<int> elements;

  const MisplacedFeedback(this.elements);
}

final class RouteVerdict {
  final bool solved;
  final RouteFeedback feedback;

  const RouteVerdict({required this.solved, required this.feedback});

  const RouteVerdict.solved() : solved = true, feedback = const NoFeedback();

  const RouteVerdict.failed(this.feedback) : solved = false;
}
