import 'package:bloc/bloc.dart';
import '../../domain/model/knowledge/content_load_result.dart';
import '../../domain/model/knowledge/knowledge_entry.dart';
import '../../domain/model/onboarding/onboarding_exit.dart';
import '../../domain/model/onboarding/onboarding_step.dart';
import '../../domain/ports/knowledge_repository.dart';
import '../../domain/ports/preferences_store.dart';
import 'knowledge_highlights_projection.dart';
import 'onboarding_state.dart';

final class OnboardingCubit extends Cubit<OnboardingState> {
  final PreferencesStore _preferences;
  final KnowledgeRepository _knowledgeRepository;
  final KnowledgeHighlightsProjection _highlights;

  OnboardingCubit({
    required PreferencesStore preferences,
    required KnowledgeRepository knowledgeRepository,
    KnowledgeHighlightsProjection highlights =
        const KnowledgeHighlightsProjection(),
  })  : _preferences = preferences,
        _knowledgeRepository = knowledgeRepository,
        _highlights = highlights,
        super(const OnboardingState());

  Future<void> init() async {
    final prefs = await _preferences.read();
    emit(state.copyWith(
      language: prefs.language,
      isCompleted: prefs.hasSeenOnboarding,
    ));
  }

  void restart() => emit(OnboardingState(language: state.language));

  Future<void> nextStep() async {
    switch (state.step) {
      case OnboardingStep.welcome:
        emit(state.copyWith(step: OnboardingStep.liveLab));
      case OnboardingStep.liveLab:
        emit(state.copyWith(step: OnboardingStep.knowledge));
        await _loadHighlights();
      case OnboardingStep.knowledge:
        emit(state.copyWith(step: OnboardingStep.completion));
      case OnboardingStep.completion:
        await finishWith(OnboardingExit.library);
    }
  }

  void previousStep() {
    switch (state.step) {
      case OnboardingStep.welcome:
        break;
      case OnboardingStep.liveLab:
        emit(state.copyWith(step: OnboardingStep.welcome));
      case OnboardingStep.knowledge:
        emit(state.copyWith(step: OnboardingStep.liveLab));
      case OnboardingStep.completion:
        emit(state.copyWith(step: OnboardingStep.knowledge));
    }
  }

  Future<void> _loadHighlights() async {
    if (state.highlightsStatus == KnowledgeHighlightsStatus.loading) return;
    emit(state.copyWith(highlightsStatus: KnowledgeHighlightsStatus.loading));
    try {
      final result = await _knowledgeRepository.getEntries(state.language);
      if (result is ContentLoadFailed<List<KnowledgeEntry>>) {
        emit(state.copyWith(
          highlightsStatus: KnowledgeHighlightsStatus.unavailable,
        ));
        return;
      }
      final entries = (result as ContentLoaded<List<KnowledgeEntry>>).value;
      emit(state.copyWith(
        highlights: _highlights.of(entries),
        highlightsStatus: KnowledgeHighlightsStatus.ready,
      ));
    } catch (_) {
      emit(state.copyWith(
        highlightsStatus: KnowledgeHighlightsStatus.unavailable,
      ));
    }
  }

  Future<void> finishWith(OnboardingExit exit) async {
    final current = await _preferences.read();
    await _preferences.write(current.copyWith(hasSeenOnboarding: true));
    emit(state.copyWith(exit: () => exit, isCompleted: true));
  }
}
