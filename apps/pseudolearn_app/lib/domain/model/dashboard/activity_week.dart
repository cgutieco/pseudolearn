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

  int get totalEvents => learningEvents + documentsCreated;

  bool get isEmpty => totalEvents == 0;
}
