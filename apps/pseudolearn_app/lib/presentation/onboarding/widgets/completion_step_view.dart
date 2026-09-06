import 'package:flutter/material.dart';
import '../../components/button/app_button.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/icon_metrics.dart';
import '../../theme/tokens/spacing.dart';

final class CompletionStepView extends StatelessWidget {
  final VoidCallback onCreateFirstDocument;
  final VoidCallback onExploreRoute;

  const CompletionStepView({
    super.key,
    required this.onCreateFirstDocument,
    required this.onExploreRoute,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _CompletionHeading(),
        SizedBox(height: canvas.scaled(SpacingTokens.space6)),
        _CompletionActions(
          onCreateFirstDocument: onCreateFirstDocument,
          onExploreRoute: onExploreRoute,
        ),
      ],
    );
  }
}

final class _CompletionHeading extends StatelessWidget {
  const _CompletionHeading();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canvas = DesignCanvasScope.of(context);
    final theme = AppThemeExtension.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.check_circle_outline,
          size: IconMetricsTokens.iconXl,
          color: theme.colors.severities.success.fg,
        ),
        SizedBox(height: canvas.scaled(SpacingTokens.space3)),
        AppText(
          l10n.onboardingCompletionTitle,
          variant: AppTextVariant.heading2,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: canvas.scaled(SpacingTokens.space2)),
        AppText(
          l10n.onboardingCompletionSubtitle,
          variant: AppTextVariant.bodyDefault,
          color: theme.colors.text.secondary,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

final class _CompletionActions extends StatelessWidget {
  final VoidCallback onCreateFirstDocument;
  final VoidCallback onExploreRoute;

  const _CompletionActions({
    required this.onCreateFirstDocument,
    required this.onExploreRoute,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: SpacingTokens.space3,
      runSpacing: SpacingTokens.space3,
      children: [
        AppButton(
          label: l10n.onboardingActionCreateFirst,
          icon: Icons.add,
          variant: AppButtonVariant.primary,
          onPressed: onCreateFirstDocument,
        ),
        AppButton(
          label: l10n.onboardingActionExploreRoute,
          icon: Icons.route_outlined,
          variant: AppButtonVariant.secondary,
          onPressed: onExploreRoute,
        ),
      ],
    );
  }
}
