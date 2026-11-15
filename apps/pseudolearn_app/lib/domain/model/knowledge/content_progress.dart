final class ContentProgress {
  final Set<String> visitedModuleIds;
  final Set<String> completedExerciseIds;

  const ContentProgress({
    this.visitedModuleIds = const {},
    this.completedExerciseIds = const {},
  });

  bool isModuleVisited(String moduleId) => visitedModuleIds.contains(moduleId);

  bool isExerciseCompleted(String exerciseId) => completedExerciseIds.contains(exerciseId);
}
