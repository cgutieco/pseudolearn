enum ExerciseKind {
  predict('predecir'),
  complete('completar'),
  modify('modificar'),
  create('crear');

  final String slug;

  const ExerciseKind(this.slug);

  static ExerciseKind? fromSlug(String slug) {
    for (final kind in values) {
      if (kind.slug == slug) return kind;
    }
    return null;
  }
}
