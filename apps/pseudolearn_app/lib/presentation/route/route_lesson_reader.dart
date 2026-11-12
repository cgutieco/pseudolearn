import 'package:material_ui/material_ui.dart';
import '../../domain/model/route/route_lesson.dart';
import '../components/layout/app_content_column.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/spacing.dart';
import 'lesson_block_view.dart';
import 'lesson_scope.dart';

final class RouteLessonReader extends StatelessWidget {
  final RouteLesson lesson;
  final LessonScope scope;

  const RouteLessonReader({super.key, required this.lesson, required this.scope});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.space4,
        vertical: SpacingTokens.space4,
      ),
      child: AppContentColumn(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RouteLessonHeader(lesson: lesson, scope: scope),
            const SizedBox(height: SpacingTokens.space4),
            LessonBlockColumn(blocks: lesson.blocks, scope: scope),
          ],
        ),
      ),
    );
  }
}

final class RouteLessonHeader extends StatelessWidget {
  final RouteLesson lesson;
  final LessonScope scope;

  const RouteLessonHeader({super.key, required this.lesson, required this.scope});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final needs = lesson.needs.isEmpty
        ? l10n.routeLessonNeedsNothing
        : lesson.needs.map((need) => '${need.number} ${need.title}').join(' · ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          '${lesson.number} · ${l10n.routeLessonMinutes(lesson.minutes)}',
          variant: AppTextVariant.caption,
          color: theme.colors.text.tertiary,
        ),
        LessonRunsText(runs: lesson.title, scope: scope, variant: AppTextVariant.heading1),
        const SizedBox(height: SpacingTokens.space2),
        AppText('${l10n.routeLessonNeeds}: $needs', variant: AppTextVariant.bodySmall, color: theme.colors.text.secondary),
        if (lesson.introducedLabels.isNotEmpty)
          AppText(
            '${l10n.routeLessonLearn}: ${lesson.introducedLabels.join(', ')}',
            variant: AppTextVariant.bodySmall,
            color: theme.colors.text.secondary,
          ),
      ],
    );
  }
}
