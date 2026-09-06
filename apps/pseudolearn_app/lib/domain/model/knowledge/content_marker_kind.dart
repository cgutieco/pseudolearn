enum ContentMarkerKind {
  lexeme('lexema'),
  table('tabla'),
  signature('firma'),
  example('ejemplo'),
  diagnostic('diagnostico'),
  figure('figura'),
  diagram('diagrama');

  final String slug;

  const ContentMarkerKind(this.slug);

  static ContentMarkerKind? fromSlug(String slug) {
    for (final kind in values) {
      if (kind.slug == slug) return kind;
    }
    return null;
  }
}
