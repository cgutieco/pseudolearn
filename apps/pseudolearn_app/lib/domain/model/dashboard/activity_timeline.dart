import 'activity_week.dart';

final class ActivityTimeline {
  final List<ActivityWeek> weeks;
  final int peakLearningEvents;
  final int peakDocumentsCreated;

  const ActivityTimeline({
    required this.weeks,
    required this.peakLearningEvents,
    required this.peakDocumentsCreated,
  });

  const ActivityTimeline.empty()
      : weeks = const [],
        peakLearningEvents = 0,
        peakDocumentsCreated = 0;

  factory ActivityTimeline.of(List<ActivityWeek> weeks) {
    var learningPeak = 0;
    var creationPeak = 0;
    for (final week in weeks) {
      if (week.learningEvents > learningPeak) {
        learningPeak = week.learningEvents;
      }
      if (week.documentsCreated > creationPeak) {
        creationPeak = week.documentsCreated;
      }
    }
    return ActivityTimeline(
      weeks: weeks,
      peakLearningEvents: learningPeak,
      peakDocumentsCreated: creationPeak,
    );
  }

  bool get hasActivity => peakLearningEvents > 0 || peakDocumentsCreated > 0;
}
