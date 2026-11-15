import '../model/exercises/user_exercise.dart';
import '../model/exercises/user_exercise_change.dart';

abstract interface class UserExerciseRepository {
  Future<List<UserExercise>> listExercises();
  Future<UserExercise?> loadExercise(String id);
  Future<UserExercise> saveExercise(UserExercise exercise);
  Future<void> deleteExercise(String id);
  Stream<UserExerciseChange> get changes;
}
