import 'expected_value_kind.dart';
import 'list_equality.dart';

final class ExerciseCase {
  final List<String> inputs;
  final List<String> expectedOutputs;
  final ExpectedValueKind expectedValueKind;

  const ExerciseCase({
    required this.inputs,
    required this.expectedOutputs,
    required this.expectedValueKind,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseCase &&
          runtimeType == other.runtimeType &&
          expectedValueKind == other.expectedValueKind &&
          listEquals(inputs, other.inputs) &&
          listEquals(expectedOutputs, other.expectedOutputs);

  @override
  int get hashCode => Object.hash(
        expectedValueKind,
        Object.hashAll(inputs),
        Object.hashAll(expectedOutputs),
      );
}
