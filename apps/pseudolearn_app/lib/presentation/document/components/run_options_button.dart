import 'package:flutter/material.dart';
import '../../components/button/app_button.dart';
import '../../components/button/app_icon_button.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/component_metrics.dart';
import '../../theme/tokens/spacing.dart';

final class RunOptionsButton extends StatelessWidget {
  final bool hasArguments;
  final VoidCallback onPressed;

  const RunOptionsButton({
    super.key,
    required this.hasArguments,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AppIconButton(
          icon: Icons.more_horiz,
          semanticLabel: hasArguments
              ? l10n.runOptionsOpenWithArguments
              : l10n.runOptionsOpen,
          variant: AppButtonVariant.tertiary,
          onPressed: onPressed,
        ),
        if (hasArguments) const _ArgumentsMark(),
      ],
    );
  }
}

final class _ArgumentsMark extends StatelessWidget {
  const _ArgumentsMark();

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Positioned(
      top: SpacingTokens.space2,
      right: SpacingTokens.space2,
      child: IgnorePointer(
        child: Container(
          width: ComponentMetricsTokens.runOptionsBadgeDotSize,
          height: ComponentMetricsTokens.runOptionsBadgeDotSize,
          decoration: BoxDecoration(
            color: theme.colors.actions.primary.bgDefault,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
