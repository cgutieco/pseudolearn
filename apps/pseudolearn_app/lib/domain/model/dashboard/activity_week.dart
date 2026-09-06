final class ActivityWeek {
  final DateTime weekStart;
  final int modulesVisited;
  final int exercisesCompleted;
  final int documentsCreated;

  const ActivityWeek({
    required this.weekStart,
    required this.modulesVisited,
    required this.exercisesCompleted,
    required this.documentsCreated,
  });

  int get learningEvents => modulesVisited + exercisesCompleted;

  bool get isEmpty => learningEvents == 0 && documentsCreated == 0;
}
