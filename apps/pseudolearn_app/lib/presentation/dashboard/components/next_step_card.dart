import 'package:flutter/material.dart';
import '../../../domain/model/dashboard/next_module.dart';
import '../../components/button/app_button.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import 'dashboard_card.dart';
import 'dashboard_labels.dart';

final class NextStepCard extends StatelessWidget {
  final NextModule? nextModule;
  final ValueChanged<String> onOpenModule;

  const NextStepCard({
    super.key,
    required this.nextModule,
    required this.onOpenModule,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final module = nextModule;

    return DashboardCard(
      title: l10n.dashboardNextStepTitle,
      child: module == null
          ? const _RouteCompleted()
          : _NextModuleContent(module: module, onOpenModule: onOpenModule),
    );
  }
}

final class _RouteCompleted extends StatelessWidget {
  const _RouteCompleted();

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AppText(
      l10n.dashboardNextStepDone,
      variant: AppTextVariant.bodyDefault,
      color: theme.colors.text.secondary,
    );
  }
}

final class _NextModuleContent extends StatelessWidget {
  final NextModule module;
  final ValueChanged<String> onOpenModule;

  const _NextModuleContent({required this.module, required this.onOpenModule});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(
          trackLabelOf(module.track, l10n),
          variant: AppTextVariant.caption,
          color: theme.colors.text.tertiary,
        ),
        SizedBox(height: canvas.scaled(SpacingTokens.space1)),
        AppText(
          module.title,
          variant: AppTextVariant.heading3,
          color: theme.colors.text.primary,
        ),
        SizedBox(height: canvas.scaled(SpacingTokens.space4)),
        AppButton(
          label: l10n.dashboardNextStepOpen,
          variant: AppButtonVariant.secondary,
          icon: Icons.arrow_forward_rounded,
          onPressed: () => onOpenModule(module.id),
        ),
      ],
    );
  }
}
