import 'package:flutter/material.dart';
import '../../domain/model/analysis/app_diagnostic.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/color_semantic.dart';
import '../theme/tokens/radii.dart';
import '../theme/tokens/spacing.dart';
import 'button/app_button.dart';
import 'button/app_icon_button.dart';
import 'typography/app_text.dart';

final class StatusBanner extends StatelessWidget {
  final AppSeverity severity;
  final String title;
  final String? message;
  final VoidCallback? onDismiss;
  final Widget? action;

  const StatusBanner({
    super.key,
    required this.severity,
    required this.title,
    this.message,
    this.onDismiss,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final (surface, fg, icon) = _resolveColors(severity, theme.colors);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.space3,
        vertical: SpacingTokens.space2,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.space3,
        vertical: SpacingTokens.space2,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
        border: Border(left: BorderSide(color: fg, width: 4)),
      ),
      child: _BannerContent(
        icon: icon,
        fg: fg,
        title: title,
        message: message,
        action: action,
        onDismiss: onDismiss,
      ),
    );
  }

  (Color, Color, IconData) _resolveColors(AppSeverity s, AppSemanticColors colors) {
    return switch (s) {
      AppSeverity.error => (colors.severities.error.surface, colors.severities.error.fg, Icons.error_outline),
      AppSeverity.warning => (colors.severities.warning.surface, colors.severities.warning.fg, Icons.warning_amber_outlined),
      AppSeverity.info => (colors.severities.info.surface, colors.severities.info.fg, Icons.info_outline),
      AppSeverity.hint => (colors.severities.hint.surface, colors.severities.hint.fg, Icons.lightbulb_outline),
      AppSeverity.success => (colors.severities.success.surface, colors.severities.success.fg, Icons.check_circle_outline),
    };
  }
}

final class _BannerContent extends StatelessWidget {
  final IconData icon;
  final Color fg;
  final String title;
  final String? message;
  final Widget? action;
  final VoidCallback? onDismiss;

  const _BannerContent({
    required this.icon,
    required this.fg,
    required this.title,
    required this.message,
    this.action,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          message == null ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: fg),
        const SizedBox(width: SpacingTokens.space2),
        Expanded(child: _BannerText(fg: fg, title: title, message: message)),
        if (action != null) ...[
          const SizedBox(width: SpacingTokens.space2),
          action!,
        ],
        if (onDismiss != null) ...[
          const SizedBox(width: SpacingTokens.space2),
          _DismissControl(onDismiss: onDismiss!),
        ],
      ],
    );
  }
}

final class _BannerText extends StatelessWidget {
  final Color fg;
  final String title;
  final String? message;

  const _BannerText({required this.fg, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final body = message;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(title, variant: AppTextVariant.label, color: fg),
        if (body != null) ...[
          const SizedBox(height: SpacingTokens.spaceHalf),
          AppText(body, variant: AppTextVariant.bodySmall, color: theme.colors.text.primary),
        ],
      ],
    );
  }
}

final class _DismissControl extends StatelessWidget {
  final VoidCallback onDismiss;

  const _DismissControl({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
      icon: Icons.close,
      semanticLabel: AppLocalizations.of(context)!.bannerDismiss,
      variant: AppButtonVariant.tertiary,
      onPressed: onDismiss,
    );
  }
}
