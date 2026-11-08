import 'package:flutter/material.dart';
import '../../application/route/route_index_state.dart';
import '../../application/route/route_progress.dart';
import '../../domain/model/dashboard/coverage_count.dart';
import '../../domain/model/reference/reference_run.dart';
import '../../domain/model/route/route_toc.dart';
import '../components/card/app_card_surface.dart';
import '../components/empty/app_empty_state.dart';
import '../components/progress/app_skeleton_list.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/spacing.dart';

final class RouteIndexView extends StatelessWidget {
  final RouteIndexState state;
  final ValueChanged<String> onOpenLesson;
  final VoidCallback onRetry;

  const RouteIndexView({
    super.key,
    required this.state,
    required this.onOpenLesson,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return switch (state.status) {
      RouteIndexStatus.error => AppEmptyState(
        icon: Icons.error_outline_rounded,
        title: l10n.routeIndexErrorTitle,
        description: l10n.knowledgeErrorDescription,
        actionLabel: l10n.knowledgeActionRetry,
        onAction: onRetry,
      ),
      RouteIndexStatus.success => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final part in state.toc.parts)
              RoutePartSection(part: part, state: state, onOpenLesson: onOpenLesson),
          ],
        ),
      ),
      _ => const AppSkeletonList(itemExtent: 88),
    };
  }
}

final class RoutePartSection extends StatelessWidget {
  final RoutePartEntry part;
  final RouteIndexState state;
  final ValueChanged<String> onOpenLesson;

  const RoutePartSection({
    super.key,
    required this.part,
    required this.state,
    required this.onOpenLesson,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText('${part.number} · ${part.title}', variant: AppTextVariant.heading3),
          if (part.motto.isNotEmpty)
            AppText(part.motto, variant: AppTextVariant.bodySmall, color: theme.colors.text.secondary),
          const SizedBox(height: SpacingTokens.space2),
          for (final lesson in part.lessons)
            RouteLessonTile(
              lesson: lesson,
              progress: state.progressOf(lesson.id),
              required: state.requiredOf(lesson.id),
              isNext: state.nextLessonId == lesson.id,
              onTap: () => onOpenLesson(lesson.id),
            ),
        ],
      ),
    );
  }
}

final class RouteLessonTile extends StatelessWidget {
  final RouteLessonEntry lesson;
  final LessonProgress progress;
  final CoverageCount required;
  final bool isNext;
  final VoidCallback onTap;

  const RouteLessonTile({
    super.key,
    required this.lesson,
    required this.progress,
    this.required = const CoverageCount.empty(),
    required this.isNext,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final status = switch (progress) {
      LessonProgress.completed => l10n.routeLessonCompleted,
      LessonProgress.visited => l10n.routeLessonVisited,
      LessonProgress.notStarted => isNext ? l10n.routeNextLesson : '',
    };
    final pending = progress != LessonProgress.completed && required.total > 0;
    final caption = [
      if (status.isNotEmpty) status,
      if (pending) l10n.routeLessonRequired(required.done, required.total),
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.space2),
      child: InkWell(
        onTap: onTap,
        child: AppCardSurface(
          padding: const EdgeInsets.all(SpacingTokens.space3),
          focused: isNext,
          child: RouteLessonTileBody(lesson: lesson, status: caption, color: progress == LessonProgress.completed ? theme.colors.severities.success.fg : theme.colors.text.link),
        ),
      ),
    );
  }
}

final class RouteLessonTileBody extends StatelessWidget {
  final RouteLessonEntry lesson;
  final String status;
  final Color color;

  const RouteLessonTileBody({
    super.key,
    required this.lesson,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          '${lesson.number} · ${plainTextOf(lesson.title)}',
          variant: AppTextVariant.label,
        ),
        AppText(lesson.briefProblem, variant: AppTextVariant.bodySmall, color: theme.colors.text.secondary),
        AppText(
          [l10n.routeLessonMinutes(lesson.minutes), if (status.isNotEmpty) status].join(' · '),
          variant: AppTextVariant.caption,
          color: color,
        ),
      ],
    );
  }
}
