import '../../../domain/model/knowledge/knowledge_entry.dart';
import '../../../domain/model/knowledge/learning_module.dart';

enum LearningRouteStatus {
  initial,
  loading,
  success,
  error,
  moduleNotFound,
}

final class LearningRouteState {
  final LearningRouteStatus status;
  final List<KnowledgeEntry> trackA;
  final List<KnowledgeEntry> trackB;
  final List<KnowledgeEntry> trackC;
  final List<KnowledgeEntry> filteredTrackA;
  final List<KnowledgeEntry> filteredTrackB;
  final List<KnowledgeEntry> filteredTrackC;
  final Set<String> visitedModuleIds;
  final String searchQuery;
  final LearningModule? activeModule;
  final String? errorMessage;

  const LearningRouteState({
    this.status = LearningRouteStatus.initial,
    this.trackA = const [],
    this.trackB = const [],
    this.trackC = const [],
    this.filteredTrackA = const [],
    this.filteredTrackB = const [],
    this.filteredTrackC = const [],
    this.visitedModuleIds = const {},
    this.searchQuery = '',
    this.activeModule,
    this.errorMessage,
  });

  bool isModuleVisited(String moduleId) => visitedModuleIds.contains(moduleId);

  bool get isRouteEmpty =>
      status == LearningRouteStatus.success &&
      trackA.isEmpty &&
      trackB.isEmpty &&
      trackC.isEmpty;

  bool get isRouteSearchEmpty =>
      status == LearningRouteStatus.success &&
      (trackA.isNotEmpty || trackB.isNotEmpty || trackC.isNotEmpty) &&
      filteredTrackA.isEmpty &&
      filteredTrackB.isEmpty &&
      filteredTrackC.isEmpty;

  LearningRouteState copyWith({
    LearningRouteStatus? status,
    List<KnowledgeEntry>? trackA,
    List<KnowledgeEntry>? trackB,
    List<KnowledgeEntry>? trackC,
    List<KnowledgeEntry>? filteredTrackA,
    List<KnowledgeEntry>? filteredTrackB,
    List<KnowledgeEntry>? filteredTrackC,
    Set<String>? visitedModuleIds,
    String? searchQuery,
    LearningModule? Function()? activeModule,
    String? Function()? errorMessage,
  }) {
    return LearningRouteState(
      status: status ?? this.status,
      trackA: trackA ?? this.trackA,
      trackB: trackB ?? this.trackB,
      trackC: trackC ?? this.trackC,
      filteredTrackA: filteredTrackA ?? this.filteredTrackA,
      filteredTrackB: filteredTrackB ?? this.filteredTrackB,
      filteredTrackC: filteredTrackC ?? this.filteredTrackC,
      visitedModuleIds: visitedModuleIds ?? this.visitedModuleIds,
      searchQuery: searchQuery ?? this.searchQuery,
      activeModule: activeModule != null ? activeModule() : this.activeModule,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}
