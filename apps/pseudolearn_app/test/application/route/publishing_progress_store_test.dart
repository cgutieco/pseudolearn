import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/route/progress_updates.dart';
import 'package:pseudolearn_app/application/route/publishing_progress_store.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_progress.dart';
import 'package:pseudolearn_app/domain/ports/local_progress_store.dart';

import '../../fakes/in_memory_local_progress_store.dart';

final class _FailingProgressStore implements LocalProgressStore {
  @override
  Future<bool> isModuleVisited(String moduleId) async => false;

  @override
  Future<void> markModuleVisited(String moduleId) async => throw StateError('disk full');

  @override
  Future<bool> isExerciseCompleted(String exerciseId) async => false;

  @override
  Future<void> markExerciseCompleted(String exerciseId) async => throw StateError('disk full');

  @override
  Future<ContentProgress> readProgress() async => throw StateError('disk full');
}

void main() {
  late InMemoryLocalProgressStore inner;
  late ProgressUpdates updates;
  late PublishingProgressStore store;
  late List<void> published;

  setUp(() {
    inner = InMemoryLocalProgressStore();
    updates = ProgressUpdates();
    store = PublishingProgressStore(inner: inner, updates: updates);
    published = [];
    updates.stream.listen(published.add);
  });

  test('publishes after a solved exercise is stored', () async {
    await store.markExerciseCompleted('ex-01');
    await Future<void>.delayed(Duration.zero);

    expect(await inner.isExerciseCompleted('ex-01'), isTrue);
    expect(published.length, 1);
  });

  test('publishes after a visited lesson is stored', () async {
    await store.markModuleVisited('lesson-01');
    await Future<void>.delayed(Duration.zero);

    expect(await store.isModuleVisited('lesson-01'), isTrue);
    expect(published.length, 1);
  });

  test('reads pass through without publishing', () async {
    await inner.markExerciseCompleted('ex-01');

    expect(await store.isExerciseCompleted('ex-01'), isTrue);
    expect(await store.isModuleVisited('unknown'), isFalse);
    expect((await store.readProgress()).completedExerciseIds, contains('ex-01'));
    await Future<void>.delayed(Duration.zero);
    expect(published, isEmpty);
  });

  test('a failed write does not publish', () async {
    final failing = PublishingProgressStore(inner: _FailingProgressStore(), updates: updates);

    await expectLater(failing.markExerciseCompleted('ex-01'), throwsStateError);
    await expectLater(failing.markModuleVisited('lesson-01'), throwsStateError);
    await Future<void>.delayed(Duration.zero);

    expect(published, isEmpty);
  });

  test('publishing without listeners is harmless', () {
    expect(ProgressUpdates().publish, returnsNormally);
  });
}
