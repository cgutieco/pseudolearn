enum RouteExerciseKind {
  predict('predecir'),
  trace('rastrear'),
  order('ordenar'),
  findError('encontrar-error'),
  breakIt('romperlo'),
  designTests('disenar-pruebas'),
  modify('modificar'),
  solve('resolver'),
  compare('comparar'),
  classify('clasificar'),
  explain('explicar');

  final String slug;

  const RouteExerciseKind(this.slug);

  bool get isAnsweredInEditor =>
      this == solve || this == modify || this == findError;

  static RouteExerciseKind? fromSlug(String slug) {
    for (final kind in values) {
      if (kind.slug == slug) return kind;
    }
    return null;
  }
}

enum RouteLevel {
  seed('semilla'),
  sprout('brote'),
  tree('arbol');

  final String slug;

  const RouteLevel(this.slug);

  static RouteLevel? fromSlug(String slug) {
    for (final level in values) {
      if (level.slug == slug) return level;
    }
    return null;
  }
}

enum RouteLessonKind {
  lesson('leccion'),
  opening('apertura'),
  project('proyecto');

  final String slug;

  const RouteLessonKind(this.slug);

  static RouteLessonKind? fromSlug(String slug) {
    for (final kind in values) {
      if (kind.slug == slug) return kind;
    }
    return null;
  }
}

String routeLessonProgressId(String lessonId) => 'ruta.leccion:$lessonId';

String routeExerciseProgressId(String exerciseId) =>
    'ruta.ejercicio:$exerciseId';
