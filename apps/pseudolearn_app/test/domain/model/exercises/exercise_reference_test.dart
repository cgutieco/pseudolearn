import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/exercises/exercise_reference.dart';
import 'package:pseudolearn_app/domain/model/exercises/user_exercise_projection.dart';
import '../../../fakes/user_exercise_fixtures.dart';

void main() {
  test('prefixed references round trip', () {
    expect(ExerciseReference.parse('user:ab').origin, ExerciseOrigin.user);
    expect(ExerciseReference.parse('route:x-1'), const ExerciseReference.route('x-1'));
    expect(const ExerciseReference.user('z').encoded, 'user:z');
  });

  test('a legacy bare id is read as a route exercise', () {
    expect(ExerciseReference.parse('con-b1-ej1'), const ExerciseReference.route('con-b1-ej1'));
  });

  test('an empty id and a lone prefix stay well formed', () {
    expect(ExerciseReference.parse('').id, '');
    expect(ExerciseReference.parse('user:').id, '');
  });

  test('a user exercise projects to a solve exercise with narrative first', () {
    final exercise = exerciseOfUser(sumExercise());
    expect(exercise.origin, ExerciseOrigin.user);
    expect(exercise.statement, startsWith('Una tienda'));
    expect(exercise.hints, hasLength(2));
    expect(exercise.reference, const ExerciseReference.user('ux-1'));
  });
}
