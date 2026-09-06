enum ExpectedValueKind {
  numeric('numerico'),
  text('texto');

  final String slug;

  const ExpectedValueKind(this.slug);

  static ExpectedValueKind? fromSlug(String slug) {
    for (final kind in values) {
      if (kind.slug == slug) return kind;
    }
    return null;
  }
}
