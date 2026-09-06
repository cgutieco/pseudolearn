import 'exercise_case.dart';
import 'exercise_kind.dart';
import 'exercise_level.dart';
import 'list_equality.dart';
import 'structural_assertion.dart';

final class Exercise {
  final String id;
  final String title;
  final String statement;
  final ExerciseLevel level;
  final ExerciseKind kind;
  final String? moduleId;
  final List<ExerciseCase> visibleCases;
  final List<ExerciseCase> hiddenCases;
  final List<StructuralAssertion> assertions;
  final String? starterCode;

  const Exercise({
    required this.id,
    required this.title,
    required this.statement,
    required this.level,
    required this.kind,
    required this.visibleCases,
    required this.hiddenCases,
    this.moduleId,
    this.assertions = const [],
    this.starterCode,
  });

  List<ExerciseCase> get allCases => [...visibleCases, ...hiddenCases];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Exercise &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          statement == other.statement &&
          level == other.level &&
          kind == other.kind &&
          moduleId == other.moduleId &&
          listEquals(visibleCases, other.visibleCases) &&
          listEquals(hiddenCases, other.hiddenCases) &&
          listEquals(assertions, other.assertions) &&
          starterCode == other.starterCode;

  @override
  int get hashCode => Object.hash(
        id,
        title,
        statement,
        level,
        kind,
        moduleId,
        Object.hashAll(visibleCases),
        Object.hashAll(hiddenCases),
        Object.hashAll(assertions),
        starterCode,
      );
}
