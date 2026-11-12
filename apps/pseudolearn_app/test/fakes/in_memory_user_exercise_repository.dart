import 'dart:async';
import 'package:pseudolearn_app/domain/model/exercises/user_exercise.dart';
import 'package:pseudolearn_app/domain/model/exercises/user_exercise_change.dart';
import 'package:pseudolearn_app/domain/ports/user_exercise_repository.dart';

final class InMemoryUserExerciseRepository implements UserExerciseRepository {
  final Map<String, UserExercise> exercises = {};
  bool failing = false;
  final StreamController<UserExerciseChange> _changes =
      StreamController<UserExerciseChange>.broadcast(sync: true);

  @override
  Stream<UserExerciseChange> get changes => _changes.stream;

  @override
  Future<void> deleteExercise(String id) async {
    _guard();
    exercises.remove(id);
    _changes.add(UserExerciseChange(exerciseId: id, deleted: true));
  }

  @override
  Future<List<UserExercise>> listExercises() async {
    _guard();
    return exercises.values.toList();
  }

  @override
  Future<UserExercise?> loadExercise(String id) async {
    _guard();
    return exercises[id];
  }

  @override
  Future<UserExercise> saveExercise(UserExercise exercise) async {
    _guard();
    exercises[exercise.id] = exercise;
    _changes.add(UserExerciseChange(exerciseId: exercise.id));
    return exercise;
  }

  void _guard() {
    if (failing) throw StateError('storage');
  }
}
