import 'package:flutter/material.dart';
import '../../components/button/app_button.dart';
import '../../components/dialog/app_dialog.dart';
import '../../components/field/app_text_field.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/dialog_metrics.dart';
import '../../theme/tokens/spacing.dart';

void _showMagicLinkDialog({
  required BuildContext context,
  required ValueChanged<String> onSubmit,
}) {
  showAppDialog<void>(
    context,
    builder: (dialogContext) => _MagicLinkDialogContent(onSubmit: onSubmit),
  );
}

final class SignInOptions extends StatelessWidget {
  final VoidCallback onSignInApple;
  final VoidCallback onSignInGoogle;
  final ValueChanged<String> onSignInMagicLink;

  const SignInOptions({
    super.key,
    required this.onSignInApple,
    required this.onSignInGoogle,
    required this.onSignInMagicLink,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final l10n = AppLocalizations.of(context)!;
    final gap = SizedBox(height: canvas.scaled(SpacingTokens.space3));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _OAuthButton(
          label: l10n.authSignInWithApple,
          variant: AppButtonVariant.brandApple,
          icon: Icons.apple,
          onPressed: onSignInApple,
        ),
        gap,
        _OAuthButton(
          label: l10n.authSignInWithGoogle,
          variant: AppButtonVariant.secondary,
          icon: Icons.account_circle_outlined,
          onPressed: onSignInGoogle,
        ),
        gap,
        _MagicLinkButton(onSubmit: onSignInMagicLink),
      ],
    );
  }
}

final class _MagicLinkButton extends StatelessWidget {
  final ValueChanged<String> onSubmit;

  const _MagicLinkButton({required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _OAuthButton(
      label: l10n.authSignInWithEmail,
      variant: AppButtonVariant.secondary,
      icon: Icons.email_outlined,
      onPressed: () => _showMagicLinkDialog(context: context, onSubmit: onSubmit),
    );
  }
}

final class _OAuthButton extends StatelessWidget {
  final String label;
  final AppButtonVariant variant;
  final IconData icon;
  final VoidCallback onPressed;

  const _OAuthButton({
    required this.label,
    required this.variant,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      variant: variant,
      icon: icon,
      onPressed: onPressed,
    );
  }
}

final class _MagicLinkDialogContent extends StatefulWidget {
  final ValueChanged<String> onSubmit;

  const _MagicLinkDialogContent({required this.onSubmit});

  @override
  State<_MagicLinkDialogContent> createState() => _MagicLinkDialogContentState();
}

final class _MagicLinkDialogContentState extends State<_MagicLinkDialogContent> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSubmit(text);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);

    return Dialog(
      backgroundColor: theme.colors.surfaces.overlay,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DialogMetricsTokens.radius),
      ),
      constraints: const BoxConstraints(
        minWidth: DialogMetricsTokens.minWidth,
        maxWidth: DialogMetricsTokens.maxWidth,
      ),
      child: _MagicLinkDialogBody(
        controller: _controller,
        onSubmit: _handleSubmit,
      ),
    );
  }
}

final class _MagicLinkDialogBody extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const _MagicLinkDialogBody({
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(DialogMetricsTokens.padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            l10n.authMagicLinkDialogTitle,
            variant: AppTextVariant.heading2,
            color: theme.colors.text.primary,
          ),
          const SizedBox(height: DialogMetricsTokens.gapTitleToBody),
          AppTextField(controller: controller, label: l10n.authMagicLinkEmailLabel),
          const SizedBox(height: DialogMetricsTokens.gapBodyToActions),
          _MagicLinkDialogActions(onSubmit: onSubmit),
        ],
      ),
    );
  }
}

final class _MagicLinkDialogActions extends StatelessWidget {
  final VoidCallback onSubmit;

  const _MagicLinkDialogActions({required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AppButton(
          label: l10n.actionCancel,
          variant: AppButtonVariant.tertiary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: SpacingTokens.space2),
        AppButton(
          label: l10n.authMagicLinkSend,
          variant: AppButtonVariant.primary,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}
