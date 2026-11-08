import '../exercises/exercise_content.dart';
import '../exercises/exercise_reference.dart';
import '../route/route_kinds.dart';
import 'exercise_case.dart';
import 'list_equality.dart';
import 'structural_assertion.dart';

final class Exercise implements ExerciseContent {
  final String id;
  @override
  final String title;
  @override
  final String statement;
  final RouteLevel level;
  final RouteExerciseKind kind;
  final String? lessonId;
  @override
  final List<ExerciseCase> visibleCases;
  @override
  final List<ExerciseCase> hiddenCases;
  @override
  final List<StructuralAssertion> assertions;
  @override
  final String? starterCode;
  @override
  final List<String> hints;
  final ExerciseOrigin origin;

  const Exercise({
    required this.id,
    required this.title,
    required this.statement,
    required this.level,
    required this.kind,
    required this.visibleCases,
    required this.hiddenCases,
    this.lessonId,
    this.assertions = const [],
    this.starterCode,
    this.hints = const [],
    this.origin = ExerciseOrigin.route,
  });

  @override
  ExerciseReference get reference => ExerciseReference(origin: origin, id: id);

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
          lessonId == other.lessonId &&
          listEquals(visibleCases, other.visibleCases) &&
          listEquals(hiddenCases, other.hiddenCases) &&
          listEquals(assertions, other.assertions) &&
          origin == other.origin &&
          starterCode == other.starterCode;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    statement,
    level,
    kind,
    lessonId,
    Object.hashAll(visibleCases),
    Object.hashAll(hiddenCases),
    Object.hashAll(assertions),
    origin,
    starterCode,
  );
}
