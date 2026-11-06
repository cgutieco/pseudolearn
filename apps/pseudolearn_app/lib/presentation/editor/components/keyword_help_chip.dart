import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/component_metrics.dart';
import '../../theme/tokens/icon_metrics.dart';

final class KeywordHelpChip extends StatelessWidget {
  final VoidCallback onPressed;

  const KeywordHelpChip({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Semantics(
      container: true,
      button: true,
      label: AppLocalizations.of(context)!.helpExplainSemantic,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Container(
          width: ComponentMetricsTokens.keywordHelpChipSize,
          height: ComponentMetricsTokens.keywordHelpChipSize,
          decoration: BoxDecoration(
            color: theme.colors.surfaces.raised,
            shape: BoxShape.circle,
            border: Border.all(color: theme.colors.borders.subtle),
            boxShadow: theme.elevation.level2,
          ),
          child: Icon(
            Icons.question_mark_rounded,
            size: IconMetricsTokens.iconXs,
            color: theme.colors.actions.primary.bgDefault,
          ),
        ),
      ),
    );
  }
}
