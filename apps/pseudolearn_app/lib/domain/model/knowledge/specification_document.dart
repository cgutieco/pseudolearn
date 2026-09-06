enum SpecificationDocument {
  imperative('esp-i'),
  objectOriented('esp-o');

  final String slug;

  const SpecificationDocument(this.slug);

  static SpecificationDocument? fromSlug(String slug) {
    for (final document in values) {
      if (document.slug == slug) return document;
    }
    return null;
  }
}
