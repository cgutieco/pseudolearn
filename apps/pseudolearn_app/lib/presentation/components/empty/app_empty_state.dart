import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import '../button/app_button.dart';
import '../typography/app_text.dart';

final class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: SpacingTokens.space12, left: SpacingTokens.space6, right: SpacingTokens.space6),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: theme.colors.text.tertiary),
              const SizedBox(height: SpacingTokens.space4),
              AppText(title, variant: AppTextVariant.heading3, color: theme.colors.text.primary, textAlign: TextAlign.center),
              const SizedBox(height: SpacingTokens.space2),
              AppText(description, variant: AppTextVariant.bodyDefault, color: theme.colors.text.secondary, textAlign: TextAlign.center),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: SpacingTokens.space6),
                AppButton(label: actionLabel!, onPressed: onAction, variant: AppButtonVariant.primary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
