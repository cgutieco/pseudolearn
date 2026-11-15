import '../model/exercises/user_exercise_snapshot.dart';

abstract interface class RemoteUserExerciseStore {
  Future<bool> push(List<UserExerciseSnapshot> batch);
  Future<List<UserExerciseSnapshot>?> pullSince(int cursor);
}
