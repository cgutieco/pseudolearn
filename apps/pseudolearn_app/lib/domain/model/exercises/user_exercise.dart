import '../knowledge/exercise_case.dart';
import '../knowledge/structural_assertion.dart';
import 'exercise_content.dart';
import 'exercise_reference.dart';
import 'user_exercise_draft.dart';

final class UserExercise implements ExerciseContent {
  final String id;
  final UserExerciseDraft draft;
  final int revision;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserExercise({
    required this.id,
    required this.draft,
    required this.revision,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  ExerciseReference get reference => ExerciseReference.user(id);

  @override
  String get title => draft.title;

  @override
  String get statement => draft.statement;

  @override
  List<String> get hints => draft.hints;

  @override
  List<ExerciseCase> get visibleCases => draft.visibleCases;

  @override
  List<ExerciseCase> get hiddenCases => draft.hiddenCases;

  @override
  List<StructuralAssertion> get assertions => draft.assertions;

  @override
  String? get starterCode => draft.starterCode.isEmpty ? null : draft.starterCode;

  UserExercise revised(UserExerciseDraft next, DateTime at) => UserExercise(
    id: id,
    draft: next,
    revision: revision + 1,
    createdAt: createdAt,
    updatedAt: at,
  );
}
