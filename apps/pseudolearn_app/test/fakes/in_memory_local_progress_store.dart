import 'package:pseudolearn_app/domain/model/knowledge/content_progress.dart';
import 'package:pseudolearn_app/domain/ports/local_progress_store.dart';

final class InMemoryLocalProgressStore implements LocalProgressStore {
  final Set<String> _visitedModules = {};
  final Set<String> _completedExercises = {};

  @override
  Future<bool> isModuleVisited(String moduleId) async {
    return _visitedModules.contains(moduleId);
  }

  @override
  Future<void> markModuleVisited(String moduleId) async {
    _visitedModules.add(moduleId);
  }

  @override
  Future<bool> isExerciseCompleted(String exerciseId) async {
    return _completedExercises.contains(exerciseId);
  }

  @override
  Future<void> markExerciseCompleted(String exerciseId) async {
    _completedExercises.add(exerciseId);
  }

  @override
  Future<ContentProgress> readProgress() async {
    return ContentProgress(
      visitedModuleIds: Set.from(_visitedModules),
      completedExerciseIds: Set.from(_completedExercises),
    );
  }
}
