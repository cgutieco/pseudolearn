import 'activity_week.dart';

final class ActivityTimeline {
  final List<ActivityWeek> weeks;
  final int peakLearningEvents;
  final int peakDocumentsCreated;
  final int peakTotalEvents;
  final int activeWeeks;

  const ActivityTimeline({
    required this.weeks,
    required this.peakLearningEvents,
    required this.peakDocumentsCreated,
    required this.peakTotalEvents,
    required this.activeWeeks,
  });

  const ActivityTimeline.empty()
      : weeks = const [],
        peakLearningEvents = 0,
        peakDocumentsCreated = 0,
        peakTotalEvents = 0,
        activeWeeks = 0;

  factory ActivityTimeline.of(List<ActivityWeek> weeks) {
    var learningPeak = 0;
    var creationPeak = 0;
    var totalPeak = 0;
    for (final week in weeks) {
      learningPeak = _larger(learningPeak, week.learningEvents);
      creationPeak = _larger(creationPeak, week.documentsCreated);
      totalPeak = _larger(totalPeak, week.totalEvents);
    }
    return ActivityTimeline(
      weeks: weeks,
      peakLearningEvents: learningPeak,
      peakDocumentsCreated: creationPeak,
      peakTotalEvents: totalPeak,
      activeWeeks: weeks.where((week) => !week.isEmpty).length,
    );
  }

  static int _larger(int current, int candidate) =>
      candidate > current ? candidate : current;

  bool get hasActivity => peakTotalEvents > 0;
}
