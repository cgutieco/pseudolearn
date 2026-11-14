import 'dart:convert';
import 'dart:math' as math;
import '../../domain/model/agent/knowledge_hit.dart';
import '../../domain/ports/knowledge_index.dart';
import 'knowledge_document.dart';
import 'knowledge_parsers.dart';
import 'knowledge_text.dart';

typedef KnowledgeAssetLoader = Future<String> Function(String path);

final class AssetKnowledgeIndex implements KnowledgeIndex {
  static const List<String> languageCodes = ['es', 'en'];

  final KnowledgeAssetLoader _loader;
  final Map<String, Future<List<KnowledgeDocument>>> _documents = {};

  AssetKnowledgeIndex({required KnowledgeAssetLoader assetLoader}) : _loader = assetLoader;

  @override
  Future<List<KnowledgeHit>> search({
    required String query,
    required String languageCode,
    int limit = 5,
  }) async {
    final tokens = knowledgeTokens(query);
    if (tokens.isEmpty || limit < 1) return const [];
    final own = _rank(await _documentsOf(languageCode), tokens, limit);
    if (own.isNotEmpty) return own;
    final other = languageCodes.firstWhere((code) => code != languageCode, orElse: () => 'es');
    return _rank(await _documentsOf(other), tokens, limit);
  }

  @override
  Future<String> manualSummary(String languageCode) async {
    final manual = await _loader(_manualPath(languageCode));
    final entries = (jsonDecode(manual) as Map<String, dynamic>)['entries'] as List<dynamic>;
    return [
      for (final entry in entries)
        '- ${(entry as Map<String, dynamic>)['id']} (${entry['route']}): ${entry['title']}',
    ].join('\n');
  }

  Future<List<KnowledgeDocument>> _documentsOf(String languageCode) =>
      _documents.putIfAbsent(languageCode, () => _load(languageCode));

  Future<List<KnowledgeDocument>> _load(String languageCode) async {
    final code = languageCodes.contains(languageCode) ? languageCode : 'es';
    return [
      ...manualDocuments(await _loader(_manualPath(code)), code),
      ...specificationDocuments(await _loader('assets/reference/$code/keywords-$code/search.json'), code),
      ...sheetDocuments(await _loader('assets/agent/$code/language-sheet.md'), code),
    ];
  }

  List<KnowledgeHit> _rank(List<KnowledgeDocument> documents, List<String> tokens, int limit) {
    final weights = _inverseFrequencies(documents, tokens);
    final hits = [
      for (final document in documents)
        if (document.scoreFor(tokens, weights) case final score when score > 0)
          document.hit(score),
    ]..sort((left, right) {
        final byScore = right.score.compareTo(left.score);
        return byScore != 0 ? byScore : left.citation.compareTo(right.citation);
      });
    return hits.take(limit).toList();
  }

  Map<String, double> _inverseFrequencies(List<KnowledgeDocument> documents, List<String> tokens) {
    final weights = <String, double>{};
    for (final token in tokens.toSet()) {
      final frequency = documents.where((document) => document.mentions(token)).length;
      weights[token] = frequency == 0 ? 0 : math.log(1 + documents.length / frequency);
    }
    return weights;
  }

  String _manualPath(String languageCode) => 'assets/manual/$languageCode/manual.json';
}
