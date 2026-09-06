import 'package:flutter/material.dart';
import '../../../domain/model/account/account_session.dart';
import '../../../domain/model/account/private_relay_email.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import '../widgets/settings_group.dart';
import 'account_avatar.dart';
import 'session_actions.dart';

final class AccountSessionCard extends StatelessWidget {
  final AccountSession session;
  final VoidCallback onSignOut;
  final VoidCallback onSignOutAndDelete;
  final VoidCallback onDeleteAccount;

  const AccountSessionCard({
    super.key,
    required this.session,
    required this.onSignOut,
    required this.onSignOutAndDelete,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsGroup(
          title: l10n.settingsAccountSectionSession,
          items: [_SessionProfileTile(session: session)],
        ),
        SizedBox(height: canvas.scaled(SpacingTokens.space4)),
        SessionActions(
          onSignOut: onSignOut,
          onSignOutAndDeleteLocalData: onSignOutAndDelete,
          onDeleteAccount: onDeleteAccount,
        ),
      ],
    );
  }
}

final class _SessionProfileTile extends StatelessWidget {
  final AccountSession session;

  const _SessionProfileTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);

    return Padding(
      padding: EdgeInsets.all(canvas.scaled(SpacingTokens.space4)),
      child: Row(
        children: [
          AccountAvatar(session: session, size: 56),
          SizedBox(width: canvas.scaled(SpacingTokens.space3)),
          Expanded(child: _SessionProfileText(session: session)),
        ],
      ),
    );
  }
}

final class _SessionProfileText extends StatelessWidget {
  final AccountSession session;

  const _SessionProfileText({required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    final primaryName =
        session.displayName ?? session.email ?? l10n.settingsAccountLinked;
    final email = session.displayName == null ? null : session.email;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          primaryName,
          variant: AppTextVariant.heading3,
          color: theme.colors.text.primary,
        ),
        if (email != null) _SessionCaption(text: email),
        if (isApplePrivateRelayEmail(session.email))
          _SessionCaption(text: l10n.settingsAccountPrivateRelay),
      ],
    );
  }
}

final class _SessionCaption extends StatelessWidget {
  final String text;

  const _SessionCaption({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);

    return AppText(
      text,
      variant: AppTextVariant.caption,
      color: theme.colors.text.secondary,
    );
  }
}
