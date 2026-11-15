import '../../domain/model/onboarding/knowledge_highlights.dart';
import '../../domain/model/onboarding/onboarding_exit.dart';
import '../../domain/model/onboarding/onboarding_step.dart';
import '../../domain/model/settings/ui_language_id.dart';

enum KnowledgeHighlightsStatus {
  initial,
  loading,
  ready,
  unavailable,
}

final class OnboardingState {
  final OnboardingStep step;
  final UiLanguageId language;
  final KnowledgeHighlights highlights;
  final KnowledgeHighlightsStatus highlightsStatus;
  final OnboardingExit? exit;
  final bool isCompleted;

  const OnboardingState({
    this.step = OnboardingStep.welcome,
    this.language = UiLanguageId.system,
    this.highlights = const KnowledgeHighlights.empty(),
    this.highlightsStatus = KnowledgeHighlightsStatus.initial,
    this.exit,
    this.isCompleted = false,
  });

  bool get canGoBack => step != OnboardingStep.welcome;

  bool get isLastStep => step == OnboardingStep.completion;

  bool get areHighlightsLoading =>
      highlightsStatus == KnowledgeHighlightsStatus.loading;

  bool get areHighlightsUnavailable =>
      highlightsStatus == KnowledgeHighlightsStatus.unavailable;

  OnboardingState copyWith({
    OnboardingStep? step,
    UiLanguageId? language,
    KnowledgeHighlights? highlights,
    KnowledgeHighlightsStatus? highlightsStatus,
    OnboardingExit? Function()? exit,
    bool? isCompleted,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      language: language ?? this.language,
      highlights: highlights ?? this.highlights,
      highlightsStatus: highlightsStatus ?? this.highlightsStatus,
      exit: exit != null ? exit() : this.exit,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingState &&
          step == other.step &&
          language == other.language &&
          highlights == other.highlights &&
          highlightsStatus == other.highlightsStatus &&
          exit == other.exit &&
          isCompleted == other.isCompleted;

  @override
  int get hashCode => Object.hash(
        step,
        language,
        highlights,
        highlightsStatus,
        exit,
        isCompleted,
      );
}
