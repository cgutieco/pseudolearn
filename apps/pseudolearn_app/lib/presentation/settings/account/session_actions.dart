import 'package:flutter/material.dart';
import '../../components/button/app_button.dart';
import '../../components/dialog/app_dialog.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/tokens/spacing.dart';

void _showDeleteDataConfirmationDialog({
  required BuildContext context,
  required VoidCallback onConfirm,
}) {
  showAppDialog<void>(
    context,
    builder: (dialogContext) {
      final l10n = AppLocalizations.of(dialogContext)!;
      return AppDialog(
        title: l10n.authDeleteDataDialogTitle,
        body: l10n.authDeleteDataDialogMessage,
        actions: [
          AppButton(
            label: l10n.actionCancel,
            variant: AppButtonVariant.tertiary,
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          AppButton(
            label: l10n.authDeleteDataConfirm,
            variant: AppButtonVariant.primary,
            destructive: true,
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onConfirm();
            },
          ),
        ],
      );
    },
  );
}

void _showDeleteAccountConfirmationDialog({
  required BuildContext context,
  required VoidCallback onConfirm,
}) {
  showAppDialog<void>(
    context,
    builder: (dialogContext) {
      final l10n = AppLocalizations.of(dialogContext)!;
      return AppDialog(
        title: l10n.authDeleteAccountDialogTitle,
        body: l10n.authDeleteAccountDialogMessage,
        actions: [
          AppButton(
            label: l10n.actionCancel,
            variant: AppButtonVariant.tertiary,
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          AppButton(
            label: l10n.authDeleteAccountConfirm,
            variant: AppButtonVariant.primary,
            destructive: true,
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onConfirm();
            },
          ),
        ],
      );
    },
  );
}

final class SessionActions extends StatelessWidget {
  final VoidCallback onSignOut;
  final VoidCallback onSignOutAndDeleteLocalData;
  final VoidCallback onDeleteAccount;
  final bool deletingAccount;

  const SessionActions({
    super.key,
    required this.onSignOut,
    required this.onSignOutAndDeleteLocalData,
    required this.onDeleteAccount,
    this.deletingAccount = false,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final l10n = AppLocalizations.of(context)!;
    final gap = canvas.scaled(SpacingTokens.space3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          label: l10n.authSignOut,
          variant: AppButtonVariant.secondary,
          onPressed: deletingAccount ? null : onSignOut,
        ),
        SizedBox(height: gap),
        _DeleteDataButton(
          onConfirm: onSignOutAndDeleteLocalData,
          enabled: !deletingAccount,
        ),
        SizedBox(height: gap),
        _DeleteAccountButton(
          onConfirm: onDeleteAccount,
          deletingAccount: deletingAccount,
        ),
      ],
    );
  }
}

final class _DeleteDataButton extends StatelessWidget {
  final VoidCallback onConfirm;
  final bool enabled;

  const _DeleteDataButton({required this.onConfirm, required this.enabled});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppButton(
      label: l10n.authSignOutAndDelete,
      variant: AppButtonVariant.tertiary,
      destructive: true,
      onPressed: enabled
          ? () => _showDeleteDataConfirmationDialog(
                context: context,
                onConfirm: onConfirm,
              )
          : null,
    );
  }
}

final class _DeleteAccountButton extends StatelessWidget {
  final VoidCallback onConfirm;
  final bool deletingAccount;

  const _DeleteAccountButton({
    required this.onConfirm,
    required this.deletingAccount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppButton(
      label: deletingAccount ? l10n.authDeletingAccount : l10n.authDeleteAccount,
      variant: AppButtonVariant.tertiary,
      destructive: true,
      onPressed: deletingAccount
          ? null
          : () => _showDeleteAccountConfirmationDialog(
                context: context,
                onConfirm: onConfirm,
              ),
    );
  }
}
