import '../knowledge/learning_track.dart';
import 'coverage_count.dart';

final class TrackCoverage {
  final LearningTrack track;
  final CoverageCount modules;

  const TrackCoverage({required this.track, required this.modules});
}
