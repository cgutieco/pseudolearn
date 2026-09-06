import 'list_equality.dart';

final class ExerciseCaseFailure {
  final int caseIndex;
  final bool isHidden;
  final List<String> inputs;
  final List<String> expectedOutputs;
  final List<String> actualOutputs;

  const ExerciseCaseFailure({
    required this.caseIndex,
    required this.isHidden,
    required this.inputs,
    required this.expectedOutputs,
    required this.actualOutputs,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseCaseFailure &&
          runtimeType == other.runtimeType &&
          caseIndex == other.caseIndex &&
          isHidden == other.isHidden &&
          listEquals(inputs, other.inputs) &&
          listEquals(expectedOutputs, other.expectedOutputs) &&
          listEquals(actualOutputs, other.actualOutputs);

  @override
  int get hashCode => Object.hash(
        caseIndex,
        isHidden,
        Object.hashAll(inputs),
        Object.hashAll(expectedOutputs),
        Object.hashAll(actualOutputs),
      );
}
