import 'package:material_ui/material_ui.dart';
import '../../../domain/model/reference/reference_block.dart';
import '../../../domain/model/route/lesson_block.dart';
import '../../components/button/app_button.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../reference/blocks/reference_figure_view.dart';
import '../../reference/reference_runs_text.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import '../lesson_block_view.dart';
import '../lesson_scope.dart';
import 'lesson_callouts.dart';

final class SpecLinksView extends StatelessWidget {
  final List<ReferenceSectionLink> links;
  final LessonScope scope;

  const SpecLinksView({super.key, required this.links, required this.scope});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: SpacingTokens.space2,
      runSpacing: SpacingTokens.space2,
      children: [for (final link in links) SpecLinkPill(link: link, scope: scope)],
    );
  }
}

final class SpecLinkPill extends StatelessWidget {
  final ReferenceSectionLink link;
  final LessonScope scope;

  const SpecLinkPill({super.key, required this.link, required this.scope});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppButton(
      label: '${l10n.routeSpecLinkLabel(link.number)} · ${link.title}',
      variant: AppButtonVariant.secondary,
      icon: Icons.menu_book_outlined,
      onPressed: () => scope.onOpenLink(link.sectionId),
    );
  }
}

final class NextView extends StatelessWidget {
  final NextLessonBlock next;
  final LessonScope scope;

  const NextView({super.key, required this.next, required this.scope});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final lesson = next.lesson;
    return AccentPanel(
      accent: theme.colors.severities.success.fg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(l10n.routeNextTitle, variant: AppTextVariant.overline, color: theme.colors.severities.success.fg),
          LessonRunsText(runs: next.runs, scope: scope),
          if (lesson != null)
            AppButton(
              label: '${lesson.number} ${lesson.title}',
              variant: AppButtonVariant.primary,
              icon: Icons.arrow_forward_rounded,
              onPressed: () => scope.onOpenLink('$lessonLinkPrefix${lesson.id}'),
            ),
        ],
      ),
    );
  }
}

final class SpecFigureView extends StatelessWidget {
  final SpecFigureLessonBlock figure;
  final LessonScope scope;

  const SpecFigureView({super.key, required this.figure, required this.scope});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReferenceFigureView(figure: figure.figure, onOpenSection: scope.onOpenLink),
        Align(
          alignment: Alignment.centerLeft,
          child: AppButton(
            label: l10n.routeSpecFigureOrigin(figure.number),
            variant: AppButtonVariant.tertiary,
            onPressed: () => scope.onOpenLink(figure.sectionId),
          ),
        ),
        AppText(figure.figure.alt, variant: AppTextVariant.caption, color: theme.colors.text.tertiary),
      ],
    );
  }
}
