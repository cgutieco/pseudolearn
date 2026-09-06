import 'package:flutter/material.dart';
import '../../../domain/model/analysis/app_diagnostic.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/color_semantic.dart';
import '../../theme/tokens/spacing.dart';

final class SeverityChip extends StatelessWidget {
  final AppSeverity severity;

  const SeverityChip({
    super.key,
    required this.severity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final spec = _resolveSpec(severity, theme.colors);
    final label = _labelOf(severity, AppLocalizations.of(context)!);

    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space1),
      decoration: BoxDecoration(
        color: spec.$1,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(spec.$3, size: 12, color: spec.$2),
          const SizedBox(width: SpacingTokens.spaceHalf),
          AppText(label, variant: AppTextVariant.caption, color: spec.$2),
        ],
      ),
    );
  }

  (Color, Color, IconData) _resolveSpec(AppSeverity s, AppSemanticColors colors) {
    return switch (s) {
      AppSeverity.error =>
        (colors.severities.error.surface, colors.severities.error.fg, Icons.error_outline),
      AppSeverity.warning => (
          colors.severities.warning.surface,
          colors.severities.warning.fg,
          Icons.warning_amber_outlined,
        ),
      AppSeverity.info =>
        (colors.severities.info.surface, colors.severities.info.fg, Icons.info_outline),
      AppSeverity.hint =>
        (colors.severities.hint.surface, colors.severities.hint.fg, Icons.lightbulb_outline),
      AppSeverity.success => (
          colors.severities.success.surface,
          colors.severities.success.fg,
          Icons.check_circle_outline,
        ),
    };
  }

  String _labelOf(AppSeverity s, AppLocalizations l10n) {
    return switch (s) {
      AppSeverity.error => l10n.severityError,
      AppSeverity.warning => l10n.severityWarning,
      AppSeverity.info => l10n.severityInfo,
      AppSeverity.hint => l10n.severityHint,
      AppSeverity.success => l10n.severitySuccess,
    };
  }
}
