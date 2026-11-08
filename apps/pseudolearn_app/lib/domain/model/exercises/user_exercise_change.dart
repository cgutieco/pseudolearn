final class UserExerciseChange {
  final String exerciseId;
  final bool deleted;

  const UserExerciseChange({required this.exerciseId, this.deleted = false});

  @override
  bool operator ==(Object other) =>
      other is UserExerciseChange &&
      other.exerciseId == exerciseId &&
      other.deleted == deleted;

  @override
  int get hashCode => Object.hash(exerciseId, deleted);
}
