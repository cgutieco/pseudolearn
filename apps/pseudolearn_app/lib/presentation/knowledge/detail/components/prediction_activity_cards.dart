import 'package:flutter/material.dart';
import '../../../../domain/model/execution/execution_focus.dart';
import '../../../components/typography/app_text.dart';
import '../../../editor/components/code_preview.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/tokens/border_metrics.dart';
import '../../../theme/tokens/radii.dart';
import '../../../theme/tokens/spacing.dart';

final class PredictionCard extends StatelessWidget {
  final String? sourceCode;
  final ExecutionFocus? currentStepFocus;
  final String prompt;
  final Widget action;

  const PredictionCard({
    super.key,
    required this.sourceCode,
    required this.currentStepFocus,
    required this.prompt,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.space3),
      decoration: BoxDecoration(
        color: theme.colors.surfaces.subtle,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusSm),
        border: Border.all(
          color: theme.colors.borders.subtle,
          width: BorderMetricsTokens.widthHairline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sourceCode != null && sourceCode!.isNotEmpty) ...[
            _CodePreview(sourceCode: sourceCode!, focus: currentStepFocus),
            const SizedBox(height: SpacingTokens.space3),
          ],
          AppText(prompt, variant: AppTextVariant.bodyDefault),
          const SizedBox(height: SpacingTokens.space3),
          action,
        ],
      ),
    );
  }
}

final class _CodePreview extends StatelessWidget {
  final String sourceCode;
  final ExecutionFocus? focus;

  const _CodePreview({required this.sourceCode, required this.focus});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colors.surfaces.defaultSurface,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusSm),
        border: Border.all(
          color: theme.colors.borders.subtle,
          width: BorderMetricsTokens.widthHairline,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: CodePreview(
        text: sourceCode,
        focus: focus,
      ),
    );
  }
}

final class PredictionOutcomeCard extends StatelessWidget {
  final bool matches;
  final String predicted;
  final String actual;

  const PredictionOutcomeCard({
    super.key,
    required this.matches,
    required this.predicted,
    required this.actual,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    final sev = matches ? theme.colors.severities.success : theme.colors.severities.warning;
    final text = matches ? l10n.knowledgePredictionMatch : l10n.knowledgePredictionMismatch(predicted, actual);
    final icon = matches ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded;

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.space3),
      decoration: BoxDecoration(
        color: sev.surface,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusSm),
      ),
      child: Row(
        children: [
          Icon(icon, color: sev.fg, size: 20),
          const SizedBox(width: SpacingTokens.space2),
          Expanded(child: AppText(text, variant: AppTextVariant.bodyDefault, color: sev.fg)),
        ],
      ),
    );
  }
}
