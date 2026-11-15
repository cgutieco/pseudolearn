import '../knowledge/exercise_case.dart';
import '../knowledge/structural_assertion.dart';
import 'exercise_reference.dart';

abstract interface class ExerciseContent {
  ExerciseReference get reference;
  String get title;
  String get statement;
  List<String> get hints;
  List<ExerciseCase> get visibleCases;
  List<ExerciseCase> get hiddenCases;
  List<StructuralAssertion> get assertions;
  String? get starterCode;
}
