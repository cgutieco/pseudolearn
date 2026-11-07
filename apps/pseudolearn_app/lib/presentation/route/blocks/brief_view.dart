import 'package:flutter/material.dart';
import '../../../domain/model/reference/reference_run.dart';
import '../../../domain/model/route/lesson_block.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../reference/blocks/reference_callout_view.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import '../lesson_block_view.dart';
import '../lesson_scope.dart';
import 'lesson_callouts.dart';

final class BriefView extends StatelessWidget {
  final BriefLessonBlock brief;
  final LessonScope scope;

  const BriefView({super.key, required this.brief, required this.scope});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accent = AppThemeExtension.of(context).syntax.keywordStructured;
    return AccentPanel(
      accent: accent,
      child: ReferenceCalloutBody(
        title: l10n.routeBriefTitle,
        color: accent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BriefZone(label: l10n.routeBriefInputs, entries: [brief.inputs], scope: scope),
            BriefZone(label: l10n.routeBriefOutputs, entries: [brief.outputs], scope: scope),
            BriefZone(label: l10n.routeBriefRelation, entries: [brief.relation], scope: scope),
            BriefZone(label: l10n.routeBriefExamples, entries: brief.examples, scope: scope),
          ],
        ),
      ),
    );
  }
}

final class BriefZone extends StatelessWidget {
  final String label;
  final List<List<ReferenceRun>> entries;
  final LessonScope scope;

  const BriefZone({
    super.key,
    required this.label,
    required this.entries,
    required this.scope,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.space2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(label, variant: AppTextVariant.label, color: theme.colors.text.secondary),
          for (final entry in entries) LessonRunsText(runs: entry, scope: scope),
        ],
      ),
    );
  }
}
