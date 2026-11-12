enum ExerciseOrigin {
  route('route'),
  user('user');

  final String prefix;

  const ExerciseOrigin(this.prefix);
}

final class ExerciseReference {
  final ExerciseOrigin origin;
  final String id;

  const ExerciseReference({required this.origin, required this.id});

  const ExerciseReference.route(this.id) : origin = ExerciseOrigin.route;

  const ExerciseReference.user(this.id) : origin = ExerciseOrigin.user;

  static ExerciseReference parse(String encoded) {
    for (final origin in ExerciseOrigin.values) {
      final prefix = '${origin.prefix}:';
      if (encoded.startsWith(prefix)) {
        return ExerciseReference(
          origin: origin,
          id: encoded.substring(prefix.length),
        );
      }
    }
    return ExerciseReference.route(encoded);
  }

  String get encoded => '${origin.prefix}:$id';

  @override
  bool operator ==(Object other) =>
      other is ExerciseReference && other.origin == origin && other.id == id;

  @override
  int get hashCode => Object.hash(origin, id);
}

String userExerciseProgressId(String exerciseId) =>
    'usuario.ejercicio:$exerciseId';
