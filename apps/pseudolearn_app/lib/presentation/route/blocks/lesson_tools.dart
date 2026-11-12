import 'package:material_ui/material_ui.dart';
import '../../../domain/model/reference/reference_run.dart';
import '../../../domain/model/route/lesson_block.dart';
import '../../components/button/app_button.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../reference/blocks/reference_callout_view.dart';
import '../../reference/blocks/reference_figure_view.dart';
import '../../reference/reference_runs_text.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import '../lesson_block_view.dart';
import '../lesson_scope.dart';
import 'brief_view.dart';
import 'lesson_callouts.dart';

final class ParadigmView extends StatelessWidget {
  final ParadigmLessonBlock paradigm;
  final LessonScope scope;

  const ParadigmView({super.key, required this.paradigm, required this.scope});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accent = AppThemeExtension.of(context).syntax.keywordProcedural;
    return AccentPanel(
      accent: accent,
      child: ReferenceCalloutBody(
        title: l10n.routeParadigmTitle,
        color: accent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BriefZone(label: l10n.routeParadigmQuestion, entries: [paradigm.question], scope: scope),
            BriefZone(label: l10n.routeParadigmMetaphor, entries: [paradigm.metaphor], scope: scope),
            BriefZone(label: l10n.routeParadigmHistory, entries: [paradigm.history], scope: scope),
            BriefZone(label: l10n.routeParadigmCost, entries: [paradigm.cost], scope: scope),
          ],
        ),
      ),
    );
  }
}

final class RolesView extends StatelessWidget {
  final List<RouteRole> roles;
  final LessonScope scope;

  const RolesView({super.key, required this.roles, required this.scope});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accent = AppThemeExtension.of(context).syntax.keywordOop;
    return AccentPanel(
      accent: accent,
      child: ReferenceCalloutBody(
        title: l10n.routeRolesTitle,
        color: accent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [for (final role in roles) RoleTile(role: role, scope: scope)],
        ),
      ),
    );
  }
}

final class RoleTile extends StatelessWidget {
  final RouteRole role;
  final LessonScope scope;

  const RoleTile({super.key, required this.role, required this.scope});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.space2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(role.name, variant: AppTextVariant.label),
          ReferenceFigureView(figure: role.figure, onOpenSection: scope.onOpenLink),
        ],
      ),
    );
  }
}

final class RecallView extends StatelessWidget {
  final RecallLessonBlock recall;
  final LessonScope scope;

  const RecallView({super.key, required this.recall, required this.scope});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final List<ReferenceRun> runs = recall.runs;
    return AccentPanel(
      accent: theme.colors.text.link,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(l10n.routeRecallTitle, variant: AppTextVariant.overline, color: theme.colors.text.link),
          LessonRunsText(runs: runs, scope: scope),
          AppButton(
            label: l10n.routeRecallLesson(recall.lesson.number),
            variant: AppButtonVariant.tertiary,
            onPressed: () => scope.onOpenLink('$lessonLinkPrefix${recall.lesson.id}'),
          ),
        ],
      ),
    );
  }
}
