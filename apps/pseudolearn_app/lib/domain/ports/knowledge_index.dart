import '../model/agent/knowledge_hit.dart';

abstract interface class KnowledgeIndex {
  Future<List<KnowledgeHit>> search({
    required String query,
    required String languageCode,
    int limit = 5,
  });

  Future<String> manualSummary(String languageCode);
}
