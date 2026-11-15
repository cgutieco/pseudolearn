enum MemberVisibility {
  publicMember('publico'),
  privateMember('privado');

  final String slug;

  const MemberVisibility(this.slug);

  static MemberVisibility? fromSlug(String slug) {
    for (final visibility in values) {
      if (visibility.slug == slug) return visibility;
    }
    return null;
  }
}
