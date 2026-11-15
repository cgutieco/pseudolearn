import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/review/review_prompting_progress_store.dart';
import 'package:pseudolearn_app/domain/model/review/review_prompt_policy.dart';
import 'package:pseudolearn_app/domain/ports/store_review_prompt.dart';

import '../../fakes/fake_store_review_prompt.dart';
import '../../fakes/in_memory_local_progress_store.dart';

final class _FailingStoreReviewPrompt implements StoreReviewPrompt {
  @override
  Future<void> request() async => throw StateError('store unavailable');
}

void main() {
  late InMemoryLocalProgressStore inner;
  late FakeStoreReviewPrompt prompt;
  late ReviewPromptingProgressStore store;

  setUp(() {
    inner = InMemoryLocalProgressStore();
    prompt = FakeStoreReviewPrompt();
    store = ReviewPromptingProgressStore(inner: inner, prompt: prompt);
  });

  Future<void> solve(Iterable<String> ids) async {
    for (final id in ids) {
      await store.markExerciseCompleted(id);
    }
  }

  group('ReviewPromptingProgressStore', () {
    test('requests a review on the first solved exercise', () async {
      await store.markExerciseCompleted('ex-01');

      expect(prompt.requests, equals(1));
      expect(await inner.isExerciseCompleted('ex-01'), isTrue);
    });

    test('requests a review only at each standard milestone', () async {
      await solve(List.generate(30, (i) => 'ex-$i'));

      expect(prompt.requests, equals(3));
    });

    test('does not prompt between milestones', () async {
      await solve(List.generate(9, (i) => 'ex-$i'));

      expect(prompt.requests, equals(1));
    });

    test('solving an already solved exercise again does not prompt', () async {
      await store.markExerciseCompleted('ex-01');
      await store.markExerciseCompleted('ex-01');

      expect(prompt.requests, equals(1));
    });

    test('an exercise solved again at a milestone count does not prompt', () async {
      await solve(List.generate(10, (i) => 'ex-$i'));
      await store.markExerciseCompleted('ex-9');

      expect(prompt.requests, equals(2));
    });

    test('visiting modules never prompts', () async {
      await store.markModuleVisited('module-01');

      expect(prompt.requests, equals(0));
      expect(await store.isModuleVisited('module-01'), isTrue);
    });

    test('honours an injected policy', () async {
      store = ReviewPromptingProgressStore(
        inner: inner,
        prompt: prompt,
        policy: const ReviewPromptPolicy({2}),
      );

      await solve(['ex-a', 'ex-b']);

      expect(prompt.requests, equals(1));
    });

    test('persists the solved exercise before the prompt fails', () async {
      store = ReviewPromptingProgressStore(
        inner: inner,
        prompt: _FailingStoreReviewPrompt(),
      );

      await expectLater(store.markExerciseCompleted('ex-01'), throwsStateError);
      expect(await inner.isExerciseCompleted('ex-01'), isTrue);
    });

    test('delegates reads to the inner store', () async {
      await inner.markExerciseCompleted('ex-01');

      expect(await store.isExerciseCompleted('ex-01'), isTrue);
      expect((await store.readProgress()).completedExerciseIds, equals({'ex-01'}));
    });
  });
}
