import 'package:flutter/material.dart';
import '../../application/route/route_bank_state.dart';
import '../../domain/model/reference/reference_run.dart';
import '../../domain/model/route/route_kinds.dart';
import '../../domain/model/route/route_toc.dart';
import '../components/card/app_card_surface.dart';
import '../components/chip/app_chip_filter.dart';
import '../components/empty/app_empty_state.dart';
import '../components/progress/app_skeleton_list.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/spacing.dart';
import 'route_labels.dart';

final class RouteBankView extends StatelessWidget {
  final RouteBankState state;
  final ValueChanged<RouteBankFilter> onFilter;
  final ValueChanged<RouteExerciseEntry> onOpenExercise;

  const RouteBankView({
    super.key,
    required this.state,
    required this.onFilter,
    required this.onOpenExercise,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (state.status != RouteBankStatus.success) {
      return const AppSkeletonList(itemExtent: 72);
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RouteBankFilters(state: state, onFilter: onFilter),
          const SizedBox(height: SpacingTokens.space3),
          if (state.visible.isEmpty)
            AppEmptyState(
              icon: Icons.filter_alt_off_outlined,
              title: l10n.exerciseBankEmptyFilterTitle,
              description: l10n.exerciseBankEmptyFilterDescription,
            ),
          for (final exercise in state.visible)
            RouteBankTile(
              exercise: exercise,
              done: state.completedIds.contains(exercise.id),
              onTap: () => onOpenExercise(exercise),
            ),
        ],
      ),
    );
  }
}

final class RouteBankFilters extends StatelessWidget {
  final RouteBankState state;
  final ValueChanged<RouteBankFilter> onFilter;

  const RouteBankFilters({
    super.key,
    required this.state,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filter = state.filter;
    return Wrap(
      spacing: SpacingTokens.space2,
      runSpacing: SpacingTokens.space2,
      children: [
        for (final part in state.parts)
          AppChipFilter(
            label: part.number,
            isSelected: filter.partId == part.id,
            onTap: () => onFilter(filter.togglePart(part.id)),
          ),
        for (final level in RouteLevel.values)
          AppChipFilter(
            label: routeLevelLabel(level, l10n),
            isSelected: filter.level == level,
            onTap: () => onFilter(filter.toggleLevel(level)),
          ),
        for (final kind in RouteExerciseKind.values)
          AppChipFilter(
            label: routeKindLabel(kind, l10n),
            isSelected: filter.kind == kind,
            onTap: () => onFilter(filter.toggleKind(kind)),
          ),
      ],
    );
  }
}

final class RouteBankTile extends StatelessWidget {
  final RouteExerciseEntry exercise;
  final bool done;
  final VoidCallback onTap;

  const RouteBankTile({
    super.key,
    required this.exercise,
    required this.done,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.space2),
      child: InkWell(
        onTap: onTap,
        child: AppCardSurface(
          padding: const EdgeInsets.all(SpacingTokens.space3),
          child: RouteBankTileBody(exercise: exercise, done: done),
        ),
      ),
    );
  }
}

final class RouteBankTileBody extends StatelessWidget {
  final RouteExerciseEntry exercise;
  final bool done;

  const RouteBankTileBody({super.key, required this.exercise, required this.done});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final badges = [
      routeKindLabel(exercise.kind, l10n),
      routeLevelLabel(exercise.level, l10n),
      if (done) l10n.routePracticeDone,
    ].join(' · ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(plainTextOf(exercise.title), variant: AppTextVariant.label),
        AppText(
          badges,
          variant: AppTextVariant.caption,
          color: done ? theme.colors.severities.success.fg : theme.colors.text.secondary,
        ),
      ],
    );
  }
}
