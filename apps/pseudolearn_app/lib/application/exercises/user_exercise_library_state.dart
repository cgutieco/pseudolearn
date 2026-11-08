import 'package:equatable/equatable.dart';
import '../../domain/model/exercises/user_exercise.dart';

enum UserExerciseLibraryStatus { initial, loading, ready, failure }

final class UserExerciseLibraryState extends Equatable {
  final UserExerciseLibraryStatus status;
  final List<UserExercise> exercises;

  const UserExerciseLibraryState({
    this.status = UserExerciseLibraryStatus.initial,
    this.exercises = const [],
  });

  bool get isEmpty =>
      status == UserExerciseLibraryStatus.ready && exercises.isEmpty;

  @override
  List<Object?> get props => [status, exercises];
}
