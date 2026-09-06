import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/onboarding/onboarding_cubit.dart';
import 'package:pseudolearn_app/application/onboarding/onboarding_state.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_level.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry_type.dart';
import 'package:pseudolearn_app/domain/model/knowledge/learning_track.dart';
import 'package:pseudolearn_app/domain/model/onboarding/onboarding_exit.dart';
import 'package:pseudolearn_app/domain/model/onboarding/onboarding_step.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/domain/ports/knowledge_repository.dart';

import '../../fakes/fake_knowledge_repository.dart';
import '../../fakes/in_memory_preferences_store.dart';

final List<KnowledgeEntry> _catalogue = [
  const KnowledgeEntry(
    id: 'CON-A1',
    type: KnowledgeEntryType.module,
    title: 'Primer modulo',
    summary: '',
    track: LearningTrack.foundations,
    order: 1,
  ),
  const KnowledgeEntry(
    id: 'ESP-1',
    type: KnowledgeEntryType.specificationSection,
    title: 'Lexico',
    summary: '',
  ),
  const KnowledgeEntry(
    id: 'CON-A1-E1',
    type: KnowledgeEntryType.exercise,
    title: 'Ejercicio',
    summary: '',
    level: ExerciseLevel.reproduce,
  ),
];

OnboardingCubit _cubitWith({
  KnowledgeRepository? repository,
  InMemoryPreferencesStore? preferences,
}) {
  return OnboardingCubit(
    preferences: preferences ?? InMemoryPreferencesStore(),
    knowledgeRepository:
        repository ?? FakeKnowledgeRepository(entries: _catalogue),
  );
}

Future<OnboardingCubit> _atStep(
  OnboardingStep step, {
  InMemoryPreferencesStore? preferences,
}) async {
  final cubit = _cubitWith(preferences: preferences);
  await cubit.init();
  while (cubit.state.step != step) {
    await cubit.nextStep();
  }
  return cubit;
}

void main() {
  group('OnboardingCubit.init', () {
    test('starts at welcome and reads the stored language', () async {
      final preferences = InMemoryPreferencesStore();
      final current = await preferences.read();
      await preferences.write(current.copyWith(language: UiLanguageId.english));
      final cubit = _cubitWith(preferences: preferences);

      await cubit.init();

      expect(cubit.state.step, OnboardingStep.welcome);
      expect(cubit.state.language, UiLanguageId.english);
      expect(cubit.state.isCompleted, isFalse);
    });

    test('reports a previously seen onboarding as completed', () async {
      final preferences = InMemoryPreferencesStore();
      final current = await preferences.read();
      await preferences.write(current.copyWith(hasSeenOnboarding: true));
      final cubit = _cubitWith(preferences: preferences);

      await cubit.init();

      expect(cubit.state.isCompleted, isTrue);
    });

    test('a restart puts the flow back at the first step', () async {
      final cubit = await _atStep(OnboardingStep.knowledge);

      cubit.restart();

      expect(cubit.state.step, OnboardingStep.welcome);
      expect(cubit.state.isCompleted, isFalse);
    });

    test('a restart keeps the language already chosen and clears the exit', () async {
      final preferences = InMemoryPreferencesStore();
      final current = await preferences.read();
      await preferences.write(current.copyWith(language: UiLanguageId.english));
      final cubit = await _atStep(OnboardingStep.completion, preferences: preferences);
      await cubit.nextStep();
      expect(cubit.state.exit, OnboardingExit.library);

      cubit.restart();

      expect(cubit.state.language, UiLanguageId.english);
      expect(cubit.state.exit, isNull);
    });
  });

  group('OnboardingCubit navigation', () {
    test('walks the four steps in order', () async {
      final cubit = _cubitWith();
      await cubit.init();
      final visited = <OnboardingStep>[cubit.state.step];

      await cubit.nextStep();
      visited.add(cubit.state.step);
      await cubit.nextStep();
      visited.add(cubit.state.step);
      await cubit.nextStep();
      visited.add(cubit.state.step);

      expect(visited, [
        OnboardingStep.welcome,
        OnboardingStep.liveLab,
        OnboardingStep.knowledge,
        OnboardingStep.completion,
      ]);
    });

    test('walks back through the same steps', () async {
      final cubit = await _atStep(OnboardingStep.completion);

      cubit.previousStep();
      expect(cubit.state.step, OnboardingStep.knowledge);
      cubit.previousStep();
      expect(cubit.state.step, OnboardingStep.liveLab);
      cubit.previousStep();
      expect(cubit.state.step, OnboardingStep.welcome);
    });

    test('the first step has nowhere to go back to', () async {
      final cubit = _cubitWith();
      await cubit.init();

      cubit.previousStep();

      expect(cubit.state.step, OnboardingStep.welcome);
      expect(cubit.state.canGoBack, isFalse);
    });

    test('advancing past the last step finishes at the library', () async {
      final cubit = await _atStep(OnboardingStep.completion);

      await cubit.nextStep();

      expect(cubit.state.isCompleted, isTrue);
      expect(cubit.state.exit, OnboardingExit.library);
    });
  });

  group('OnboardingCubit knowledge highlights', () {
    test('is triggered on reaching the knowledge step', () async {
      final cubit = await _atStep(OnboardingStep.knowledge);

      expect(
        cubit.state.highlightsStatus,
        KnowledgeHighlightsStatus.ready,
      );
      expect(cubit.state.highlights.moduleCount, 1);
      expect(cubit.state.highlights.specificationCount, 1);
      expect(cubit.state.highlights.exerciseCount, 1);
    });

    test('marks the highlights unavailable when the manifest fails', () async {
      final cubit = _cubitWith(repository: FailingKnowledgeRepository());
      await cubit.init();

      await cubit.nextStep();
      await cubit.nextStep();

      expect(
        cubit.state.highlightsStatus,
        KnowledgeHighlightsStatus.unavailable,
      );
      expect(cubit.state.areHighlightsUnavailable, isTrue);
    });

    test('marks the highlights unavailable when the repository throws',
        () async {
      final cubit = _cubitWith(
        repository: FakeKnowledgeRepository(shouldThrow: true),
      );
      await cubit.init();

      await cubit.nextStep();
      await cubit.nextStep();

      expect(
        cubit.state.highlightsStatus,
        KnowledgeHighlightsStatus.unavailable,
      );
    });

    test('an empty catalogue is ready with nothing to show', () async {
      final cubit = _cubitWith(repository: FakeKnowledgeRepository());
      await cubit.init();

      await cubit.nextStep();
      await cubit.nextStep();

      expect(cubit.state.highlightsStatus, KnowledgeHighlightsStatus.ready);
      expect(cubit.state.highlights.hasRoute, isFalse);
    });
  });

  group('OnboardingCubit.finishWith', () {
    test('records the learning route as the chosen exit', () async {
      final preferences = InMemoryPreferencesStore();
      final cubit = _cubitWith(preferences: preferences);
      await cubit.init();

      await cubit.finishWith(OnboardingExit.learningRoute);

      expect(cubit.state.exit, OnboardingExit.learningRoute);
      expect(cubit.state.isCompleted, isTrue);
      expect((await preferences.read()).hasSeenOnboarding, isTrue);
    });

    test('remembers the onboarding as seen even when skipped early', () async {
      final preferences = InMemoryPreferencesStore();
      final cubit = _cubitWith(preferences: preferences);
      await cubit.init();

      await cubit.finishWith(OnboardingExit.library);

      expect((await preferences.read()).hasSeenOnboarding, isTrue);
      expect(cubit.state.exit, OnboardingExit.library);
    });
  });
}
