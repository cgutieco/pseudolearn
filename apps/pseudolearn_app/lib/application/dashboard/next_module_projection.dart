import '../../domain/model/dashboard/next_module.dart';
import '../../domain/model/knowledge/knowledge_entry.dart';
import '../../domain/model/knowledge/learning_track.dart';

NextModule? projectNextModule({
  required List<KnowledgeEntry> modules,
  required Set<String> visitedIds,
}) {
  final ordered = List<KnowledgeEntry>.from(modules)..sort(_canonicalOrder);
  for (final module in ordered) {
    final track = module.track;
    if (track == null || visitedIds.contains(module.id)) continue;
    return NextModule(id: module.id, title: module.title, track: track);
  }
  return null;
}

int _canonicalOrder(KnowledgeEntry a, KnowledgeEntry b) {
  final trackComparison = _trackIndex(a.track).compareTo(_trackIndex(b.track));
  if (trackComparison != 0) return trackComparison;
  return a.order.compareTo(b.order);
}

int _trackIndex(LearningTrack? track) =>
    track == null ? LearningTrack.values.length : track.index;
