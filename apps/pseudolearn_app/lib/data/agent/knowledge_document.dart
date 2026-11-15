import '../../domain/model/agent/knowledge_hit.dart';
import 'knowledge_text.dart';

final class KnowledgeDocument {
  final KnowledgeSource source;
  final String id;
  final String title;
  final String text;
  final String languageCode;
  final List<String> titleTokens;
  final List<String> textTokens;

  KnowledgeDocument({
    required this.source,
    required this.id,
    required this.title,
    required this.text,
    required this.languageCode,
  }) : titleTokens = knowledgeTokens(title),
       textTokens = knowledgeTokens(text);

  bool mentions(String query) =>
      _matches(titleTokens, query) > 0 || _matches(textTokens, query) > 0;

  double scoreFor(List<String> query, Map<String, double> weights) {
    var score = 0.0;
    for (final token in query) {
      final text = _matches(textTokens, token);
      final saturated = text > 3 ? 3.0 : text;
      score += (weights[token] ?? 0) * (3 * _matches(titleTokens, token) + saturated);
    }
    return score;
  }

  KnowledgeHit hit(double score) => KnowledgeHit(
    source: source,
    id: id,
    title: title,
    excerpt: text.length > 480 ? '${text.substring(0, 480)}…' : text,
    languageCode: languageCode,
    score: score,
  );

  double _matches(List<String> tokens, String query) {
    var matches = 0.0;
    for (final token in tokens) {
      if (token == query) {
        matches += 1;
      } else if (query.length >= 4 && token.startsWith(query)) {
        matches += 0.5;
      }
    }
    return matches;
  }
}
