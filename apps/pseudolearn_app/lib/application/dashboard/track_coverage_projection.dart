import '../../domain/model/dashboard/coverage_count.dart';
import '../../domain/model/dashboard/track_coverage.dart';
import '../../domain/model/knowledge/knowledge_entry.dart';
import '../../domain/model/knowledge/learning_track.dart';

List<TrackCoverage> projectTrackCoverage({
  required List<KnowledgeEntry> modules,
  required Set<String> visitedIds,
}) {
  return [
    for (final track in LearningTrack.values)
      TrackCoverage(
        track: track,
        modules: _countOfTrack(modules, track, visitedIds),
      ),
  ];
}

CoverageCount _countOfTrack(
  List<KnowledgeEntry> modules,
  LearningTrack track,
  Set<String> visitedIds,
) {
  final ofTrack = modules.where((module) => module.track == track).toList();
  final visited = ofTrack.where((module) => visitedIds.contains(module.id));
  return CoverageCount(done: visited.length, total: ofTrack.length);
}
