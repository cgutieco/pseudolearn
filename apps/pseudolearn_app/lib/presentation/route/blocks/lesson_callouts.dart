import 'package:material_ui/material_ui.dart';
import '../../../domain/model/reference/reference_callout_kind.dart';
import '../../../domain/model/reference/reference_run.dart';
import '../../../domain/model/route/lesson_block.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../reference/blocks/reference_callout_view.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';
import '../lesson_block_view.dart';
import '../lesson_scope.dart';

final class AccentPanel extends StatelessWidget {
  final Color accent;
  final Widget child;

  const AccentPanel({super.key, required this.accent, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colors.surfaces.subtle,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
        border: Border(left: BorderSide(color: accent, width: SpacingTokens.space1)),
      ),
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.space4,
        SpacingTokens.space3,
        SpacingTokens.space3,
        SpacingTokens.space3,
      ),
      child: child,
    );
  }
}

final class PhraseView extends StatelessWidget {
  final List<ReferenceRun> runs;
  final LessonScope scope;

  const PhraseView({super.key, required this.runs, required this.scope});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return AccentPanel(
      accent: theme.syntax.keywordStructured,
      child: LessonRunsText(runs: runs, scope: scope, variant: AppTextVariant.bodyLarge),
    );
  }
}

final class ProblemView extends StatelessWidget {
  final List<LessonBlock> blocks;
  final LessonScope scope;

  const ProblemView({super.key, required this.blocks, required this.scope});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    return AccentPanel(
      accent: theme.syntax.keywordOop,
      child: ReferenceCalloutBody(
        title: l10n.routeProblemLabel,
        color: theme.syntax.keywordOop,
        child: LessonBlockColumn(blocks: blocks, scope: scope),
      ),
    );
  }
}

final class DeepenView extends StatelessWidget {
  final DeepenLessonBlock deepen;
  final LessonScope scope;

  const DeepenView({super.key, required this.deepen, required this.scope});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    final title = deepen.title.isEmpty ? l10n.routeDeepen : deepen.title;
    return AccentPanel(
      accent: theme.colors.text.tertiary,
      child: ReferenceCollapsible(
        title: title,
        color: theme.colors.text.secondary,
        child: LessonBlockColumn(blocks: deepen.blocks, scope: scope),
      ),
    );
  }
}

final class LessonCalloutView extends StatelessWidget {
  final CalloutLessonBlock callout;
  final LessonScope scope;

  const LessonCalloutView({super.key, required this.callout, required this.scope});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    final accent = calloutAccent(callout.kind, theme);
    final title = callout.kind == ReferenceCalloutKind.inside
        ? l10n.routeUnderTheHood
        : calloutTitle(callout.kind, l10n);
    final body = LessonBlockColumn(blocks: callout.blocks, scope: scope);
    return AccentPanel(
      accent: accent,
      child: callout.collapsible
          ? ReferenceCollapsible(title: title, color: accent, child: body)
          : ReferenceCalloutBody(title: title, color: accent, child: body),
    );
  }
}
