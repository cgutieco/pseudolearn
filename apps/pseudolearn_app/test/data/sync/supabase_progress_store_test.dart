import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/sync/supabase_progress_store.dart';
import 'package:pseudolearn_app/domain/model/progress/progress_entry.dart';
import 'package:pseudolearn_app/domain/model/progress/pull_progress_result.dart';
import 'package:pseudolearn_app/domain/model/progress/push_progress_result.dart';
import 'package:supabase/supabase.dart';

void main() {
  group('SupabaseProgressStore', () {
    late SupabaseClient client;
    late SupabaseProgressStore store;

    setUp(() {
      client = SupabaseClient(
        'https://fake.supabase.co',
        'fake-anon-key',
      );
      store = SupabaseProgressStore(client: client);
    });

    test('pushProgress returns PushProgressFailure when network is unavailable', () async {
      const entry = ProgressEntry(
        contentId: 'mod-1',
        visited: true,
        completed: false,
      );

      final result = await store.pushProgress([entry]);
      expect(result, isA<PushProgressFailure>());
    });

    test('pullProgressSince returns PullProgressFailure when network is unavailable', () async {
      final result = await store.pullProgressSince(0);
      expect(result, isA<PullProgressFailure>());
    });
  });
}
