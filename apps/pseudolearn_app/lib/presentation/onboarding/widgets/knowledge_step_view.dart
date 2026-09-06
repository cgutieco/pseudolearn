import 'package:flutter/material.dart';
import '../../../application/onboarding/onboarding_state.dart';
import '../../../domain/model/knowledge/learning_track.dart';
import '../../../domain/model/onboarding/knowledge_highlights.dart';
import '../../components/progress/app_skeleton_list.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/grid_metrics.dart';
import '../../theme/tokens/spacing.dart';
import 'knowledge_cards_layout.dart';
import 'knowledge_value_card.dart';
import 'onboarding_step_header.dart';

String _trackLabel(AppLocalizations l10n, LearningTrack track) {
  return switch (track) {
    LearningTrack.foundations => l10n.onboardingKnowledgeTrackFoundations,
    LearningTrack.imperative => l10n.onboardingKnowledgeTrackImperative,
    LearningTrack.objectOriented =>
      l10n.onboardingKnowledgeTrackObjectOriented,
  };
}

final class KnowledgeStepView extends StatelessWidget {
  final OnboardingState state;

  const KnowledgeStepView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canvas = DesignCanvasScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OnboardingStepHeader(
          title: l10n.onboardingKnowledgeTitle,
          subtitle: l10n.onboardingKnowledgeSubtitle,
        ),
        SizedBox(height: canvas.scaled(SpacingTokens.space4)),
        if (state.areHighlightsLoading)
          const _HighlightsPlaceholder()
        else if (state.areHighlightsUnavailable)
          const _HighlightsUnavailableNotice()
        else
          _HighlightCards(highlights: state.highlights),
      ],
    );
  }
}

final class _HighlightCards extends StatelessWidget {
  final KnowledgeHighlights highlights;

  const _HighlightCards({required this.highlights});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return KnowledgeCardsLayout(
      cards: [
        KnowledgeValueCard(
          icon: Icons.route_outlined,
          title: l10n.onboardingKnowledgeRouteTitle,
          description: l10n.onboardingKnowledgeRouteDescription,
          facts: _trackFacts(l10n, highlights.tracks),
        ),
        KnowledgeValueCard(
          icon: Icons.menu_book_outlined,
          title: l10n.onboardingKnowledgeSpecificationTitle,
          description: l10n.onboardingKnowledgeSpecificationDescription,
          facts: _specificationFacts(l10n, highlights.specificationCount),
        ),
        KnowledgeValueCard(
          icon: Icons.fitness_center_outlined,
          title: l10n.onboardingKnowledgeExercisesTitle,
          description: l10n.onboardingKnowledgeExercisesDescription,
          facts: _exerciseFacts(l10n, highlights),
        ),
      ],
    );
  }

  List<String> _trackFacts(
    AppLocalizations l10n,
    List<LearningTrackHighlight> tracks,
  ) {
    final facts = <String>[];
    for (final track in tracks) {
      facts.add(
        '${_trackLabel(l10n, track.track)} · '
        '${l10n.onboardingKnowledgeModuleCount(track.moduleCount)}',
      );
    }
    return facts;
  }

  List<String> _specificationFacts(AppLocalizations l10n, int count) {
    if (count == 0) return const [];
    return [l10n.onboardingKnowledgeSpecificationCount(count)];
  }

  List<String> _exerciseFacts(
    AppLocalizations l10n,
    KnowledgeHighlights highlights,
  ) {
    if (!highlights.hasExercises) return const [];
    final facts = <String>[
      l10n.onboardingKnowledgeExerciseCount(highlights.exerciseCount),
    ];
    for (final level in highlights.exerciseLevels) {
      facts.add(
        l10n.onboardingKnowledgeLevelCount(level.level.number, level.count),
      );
    }
    return facts;
  }
}

final class _HighlightsPlaceholder extends StatelessWidget {
  const _HighlightsPlaceholder();

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final gap = canvas.scaled(GridMetricsTokens.cardGap);
    final extent = canvas.scaled(GridMetricsTokens.cardExtentKnowledge);

    return SizedBox(
      height: extent * 3 + gap * 3,
      child: const AppSkeletonList(
        itemExtent: GridMetricsTokens.cardExtentKnowledge,
      ),
    );
  }
}

final class _HighlightsUnavailableNotice extends StatelessWidget {
  const _HighlightsUnavailableNotice();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);

    return AppText(
      l10n.onboardingKnowledgeUnavailable,
      variant: AppTextVariant.bodyDefault,
      color: theme.colors.text.secondary,
      textAlign: TextAlign.center,
    );
  }
}
