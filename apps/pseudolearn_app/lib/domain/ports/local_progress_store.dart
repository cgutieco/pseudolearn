import '../model/knowledge/content_progress.dart';

abstract interface class LocalProgressStore {
  Future<bool> isModuleVisited(String moduleId);
  Future<void> markModuleVisited(String moduleId);
  Future<bool> isExerciseCompleted(String exerciseId);
  Future<void> markExerciseCompleted(String exerciseId);
  Future<ContentProgress> readProgress();
}
