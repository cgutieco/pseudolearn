import 'package:flutter/material.dart';
import '../../components/card/app_card.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';

const Set<String> _appleFailureCodes = {
  'apple_reauthentication_required',
  'apple_identity_mismatch',
  'apple_token_exchange_failed',
  'apple_revoke_failed',
};

final class AccountDeletionFailureBanner extends StatelessWidget {
  final String code;

  const AccountDeletionFailureBanner({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      child: AppText(
        _messageFor(l10n),
        variant: AppTextVariant.bodyDefault,
        color: theme.colors.severities.error.fg,
      ),
    );
  }

  String _messageFor(AppLocalizations l10n) {
    if (code == 'no_connection') return l10n.authDeleteAccountErrorNoConnection;
    if (_appleFailureCodes.contains(code)) return l10n.authDeleteAccountErrorApple;
    return l10n.authDeleteAccountErrorGeneric;
  }
}
