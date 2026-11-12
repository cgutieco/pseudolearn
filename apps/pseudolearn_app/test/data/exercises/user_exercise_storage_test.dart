import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/exercises/sqflite_user_exercise_repository.dart';
import 'package:pseudolearn_app/data/exercises/user_exercise_codec.dart';
import 'package:pseudolearn_app/data/exercises/user_exercise_sync_drainer.dart';
import 'package:pseudolearn_app/data/exercises/user_exercise_sync_state.dart';
import 'package:pseudolearn_app/data/index/index_schema.dart';
import 'package:pseudolearn_app/domain/model/exercises/user_exercise_change.dart';
import 'package:pseudolearn_app/domain/model/exercises/user_exercise_snapshot.dart';
import 'package:pseudolearn_app/domain/ports/remote_user_exercise_store.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../fakes/fake_clock.dart';
import '../../fakes/user_exercise_fixtures.dart';

final class _Remote implements RemoteUserExerciseStore {
  List<UserExerciseSnapshot>? pulled = const [];
  bool accepts = true;
  final List<List<UserExerciseSnapshot>> pushed = [];

  @override
  Future<List<UserExerciseSnapshot>?> pullSince(int cursor) async => pulled;

  @override
  Future<bool> push(List<UserExerciseSnapshot> batch) async {
    pushed.add(batch);
    return accepts;
  }
}

void main() {
  setUpAll(sqfliteFfiInit);
  late Database database;
  late SqfliteUserExerciseRepository repository;
  late UserExerciseSyncState state;
  late _Remote remote;
  late UserExerciseSyncDrainer drainer;

  setUp(() async {
    database = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await IndexSchema.createAllTables(database);
    repository = SqfliteUserExerciseRepository(database, clock: FakeClock(DateTime.utc(2026, 11, 8)));
    state = UserExerciseSyncState(database);
    remote = _Remote();
    drainer = UserExerciseSyncDrainer(remote: remote, repository: repository, state: state);
  });

  tearDown(() => database.close());

  test('the codec keeps every field and rejects garbage', () {
    final draft = sumDraft(assertions: const [loopForbidden, loopRequired]);
    final decoded = decodeUserExerciseDraft(encodeUserExerciseDraft(draft))!;
    expect(decoded.title, draft.title);
    expect(decoded.hints, draft.hints);
    expect(decoded.restrictions, draft.restrictions);
    expect(decoded.visibleCases, draft.visibleCases);
    expect(decoded.hiddenCases, draft.hiddenCases);
    expect(decoded.assertions, draft.assertions);
    expect(decoded.referenceSolution, draft.referenceSolution);
    expect(decodeUserExerciseDraft('not json'), isNull);
    expect(decodeUserExerciseDraft('{}'), isNull);
  });

  test('saved exercises are listed, loaded, announced and soft deleted', () async {
    final changes = <UserExerciseChange>[];
    final subscription = repository.changes.listen(changes.add);
    await repository.saveExercise(sumExercise());
    expect((await repository.listExercises()).single.id, 'ux-1');
    expect((await repository.loadExercise('ux-1'))!.title, sumDraft().title);
    await repository.deleteExercise('ux-1');
    expect(await repository.listExercises(), isEmpty);
    expect(await repository.loadExercise('ux-1'), isNull);
    await Future<void>.delayed(Duration.zero);
    expect(changes.last, const UserExerciseChange(exerciseId: 'ux-1', deleted: true));
    await subscription.cancel();
  });

  test('an empty library lists nothing and a missing id loads null', () async {
    expect(await repository.listExercises(), isEmpty);
    expect(await repository.loadExercise('x'), isNull);
  });

  test('dirty rows are pushed once and become clean', () async {
    await repository.saveExercise(sumExercise());
    expect(await drainer.drainPush(), isTrue);
    expect(remote.pushed.single.single.id, 'ux-1');
    expect(await drainer.drainPush(), isTrue);
    expect(remote.pushed, hasLength(1));
  });

  test('a rejected push keeps the rows dirty', () async {
    await repository.saveExercise(sumExercise());
    remote.accepts = false;
    expect(await drainer.drainPush(), isFalse);
    expect((await state.dirtyRows()).single.id, 'ux-1');
  });

  test('pulled rows are applied clean and move the cursor', () async {
    remote.pulled = [
      UserExerciseSnapshot(
        id: 'ux-1',
        exercise: sumExercise(),
        updatedAt: sumExercise().updatedAt,
        serverRevision: 7,
      ),
    ];
    expect(await drainer.drainPull(), isTrue);
    expect((await repository.loadExercise('ux-1'))!.id, 'ux-1');
    expect(await state.dirtyRows(), isEmpty);
    expect(await state.cursor(), 7);
  });

  test('a newer local edit wins over an older remote one', () async {
    await repository.saveExercise(sumExercise(revision: 3, at: DateTime.utc(2026, 11, 9)));
    remote.pulled = [
      UserExerciseSnapshot(id: 'ux-1', exercise: null, updatedAt: DateTime.utc(2026, 11, 8), serverRevision: 2),
    ];
    await drainer.drainPull();
    expect((await repository.loadExercise('ux-1'))!.revision, 3);
  });

  test('a remote deletion removes a clean local row and a failed pull is reported', () async {
    await repository.saveExercise(sumExercise());
    await drainer.drainPush();
    remote.pulled = [
      UserExerciseSnapshot(id: 'ux-1', exercise: null, updatedAt: DateTime.utc(2026, 12), serverRevision: 3),
    ];
    await drainer.drainPull();
    expect(await repository.loadExercise('ux-1'), isNull);
    remote.pulled = null;
    expect(await drainer.drainPull(), isFalse);
  });
}
