enum KnowledgeSource { manual, specification, languageSheet }

final class KnowledgeHit {
  final KnowledgeSource source;
  final String id;
  final String title;
  final String excerpt;
  final String languageCode;
  final double score;

  const KnowledgeHit({
    required this.source,
    required this.id,
    required this.title,
    required this.excerpt,
    required this.languageCode,
    required this.score,
  });

  String get citation => '${source.name}:$id';
}
