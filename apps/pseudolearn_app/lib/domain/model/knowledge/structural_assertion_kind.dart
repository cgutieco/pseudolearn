enum StructuralAssertionKind {
  containsConstruct('contiene'),
  omitsConstruct('no-contiene'),
  declaresSubprogram('declara-subprograma'),
  declaresClassMember('declara-miembro'),
  repeatsAtMost('repite-como-mucho');

  final String slug;

  const StructuralAssertionKind(this.slug);

  static StructuralAssertionKind? fromSlug(String slug) {
    for (final kind in values) {
      if (kind.slug == slug) return kind;
    }
    return null;
  }
}
