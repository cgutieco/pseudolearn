import 'package:flutter/material.dart';
import '../../../domain/model/route/route_toc.dart';
import '../../components/card/app_card_surface.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import '../lesson_block_view.dart';
import '../lesson_scope.dart';
import '../route_labels.dart';

final class PracticeView extends StatelessWidget {
  final List<String> ids;
  final LessonScope scope;

  const PracticeView({super.key, required this.ids, required this.scope});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (scope.hasRequiredExercises) const PracticeRequiredHint(),
        for (final id in ids)
          if (scope.exercise(id) case final entry?)
            PracticeTile(entry: entry, scope: scope),
      ],
    );
  }
}

final class PracticeRequiredHint extends StatelessWidget {
  const PracticeRequiredHint({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.space2),
      child: AppText(l10n.routePracticeRequiredHint, variant: AppTextVariant.bodySmall, color: theme.colors.text.secondary),
    );
  }
}

final class PracticeTile extends StatelessWidget {
  final RouteExerciseEntry entry;
  final LessonScope scope;

  const PracticeTile({super.key, required this.entry, required this.scope});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final done = scope.completedExerciseIds.contains(entry.id);
    final badges = [
      routeKindLabel(entry.kind, l10n),
      routeLevelLabel(entry.level, l10n),
      if (entry.required) l10n.routePracticeRequired,
      if (done) l10n.routePracticeDone,
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.space2),
      child: InkWell(
        onTap: () => scope.onOpenExercise(entry.id),
        child: AppCardSurface(
          padding: const EdgeInsets.all(SpacingTokens.space3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LessonRunsText(runs: entry.title, scope: scope, variant: AppTextVariant.label),
              AppText(badges, variant: AppTextVariant.caption, color: done ? theme.colors.severities.success.fg : theme.colors.text.secondary),
            ],
          ),
        ),
      ),
    );
  }
}
