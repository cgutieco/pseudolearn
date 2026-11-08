import 'package:supabase/supabase.dart';
import '../../domain/model/exercises/user_exercise.dart';
import '../../domain/model/exercises/user_exercise_snapshot.dart';
import '../../domain/ports/remote_user_exercise_store.dart';
import 'user_exercise_codec.dart';

final class SupabaseUserExerciseStore implements RemoteUserExerciseStore {
  final SupabaseClient _client;

  const SupabaseUserExerciseStore({required SupabaseClient client})
    : _client = client;

  @override
  Future<bool> push(List<UserExerciseSnapshot> batch) async {
    try {
      await _client.rpc<dynamic>(
        'push_user_exercises',
        params: {'payload': [for (final item in batch) _rowOf(item)]},
      );
      return true;
    } on Object {
      return false;
    }
  }

  @override
  Future<List<UserExerciseSnapshot>?> pullSince(int cursor) async {
    try {
      final rows = await _client
          .from('user_exercises')
          .select()
          .gt('server_revision', cursor)
          .order('server_revision', ascending: true);
      return [
        for (final row in rows) ?_snapshotOf(row),
      ];
    } on Object {
      return null;
    }
  }

  Map<String, Object?> _rowOf(UserExerciseSnapshot snapshot) {
    final exercise = snapshot.exercise;
    return {
      'id': snapshot.id,
      'payload': exercise == null ? null : encodeUserExerciseDraft(exercise.draft),
      'revision': exercise?.revision ?? 0,
      'created_at': (exercise?.createdAt ?? snapshot.updatedAt).toIso8601String(),
      'updated_at': snapshot.updatedAt.toIso8601String(),
      'deleted_at': exercise == null ? snapshot.updatedAt.toIso8601String() : null,
    };
  }

  UserExerciseSnapshot? _snapshotOf(Map<String, dynamic> row) {
    final updated = DateTime.tryParse(row['updated_at'] as String? ?? '');
    if (updated == null) return null;
    final deleted = row['deleted_at'] != null;
    final UserExercise? exercise = deleted
        ? null
        : userExerciseOfRow(
            id: row['id'] as String,
            payload: userExercisePayloadText(row['payload']) ?? '',
            revision: (row['revision'] as num?)?.toInt() ?? 1,
            createdAt: row['created_at'] as String? ?? '',
            updatedAt: row['updated_at'] as String,
          );
    if (!deleted && exercise == null) return null;
    return UserExerciseSnapshot(
      id: row['id'] as String,
      exercise: exercise,
      updatedAt: updated,
      serverRevision: (row['server_revision'] as num?)?.toInt() ?? 0,
    );
  }
}
