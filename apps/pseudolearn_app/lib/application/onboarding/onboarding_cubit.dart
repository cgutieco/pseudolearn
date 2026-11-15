import 'package:bloc/bloc.dart';
import '../../domain/model/knowledge/content_load_result.dart';
import '../../domain/model/profiles/syntax_profile_for_language.dart';
import '../../domain/model/reference/reference_edition.dart';
import '../../domain/model/reference/reference_index.dart';
import '../../domain/model/route/route_toc.dart';
import '../../domain/model/onboarding/onboarding_exit.dart';
import '../../domain/model/onboarding/onboarding_step.dart';
import '../../domain/ports/reference_repository.dart';
import '../../domain/ports/route_repository.dart';
import '../../domain/ports/preferences_store.dart';
import 'knowledge_highlights_projection.dart';
import 'onboarding_state.dart';

final class OnboardingCubit extends Cubit<OnboardingState> {
  final PreferencesStore _preferences;
  final RouteRepository _routeRepository;
  final ReferenceRepository _referenceRepository;
  final KnowledgeHighlightsProjection _highlights;

  OnboardingCubit({
    required this._preferences,
    required this._routeRepository,
    required this._referenceRepository,
    this._highlights =
        const KnowledgeHighlightsProjection(),
  })  : super(const OnboardingState());

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
    final edition = ReferenceEdition(
      language: state.language,
      profile: syntaxProfileForLanguage(state.language),
    );
    final toc = await _routeRepository.loadToc(edition);
    final index = await _referenceRepository.loadIndex(edition);
    if (toc is! ContentLoaded<RouteToc>) {
      emit(state.copyWith(
        highlightsStatus: KnowledgeHighlightsStatus.unavailable,
      ));
      return;
    }
    emit(state.copyWith(
      highlights: _highlights.of(
        toc: toc.value,
        index: index is ContentLoaded<ReferenceIndex> ? index.value : null,
      ),
      highlightsStatus: KnowledgeHighlightsStatus.ready,
    ));
  }

  Future<void> finishWith(OnboardingExit exit) async {
    final current = await _preferences.read();
    await _preferences.write(current.copyWith(hasSeenOnboarding: true));
    emit(state.copyWith(exit: () => exit, isCompleted: true));
  }
}
