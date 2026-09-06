import 'package:flutter/material.dart';
import '../../../application/account/account_state.dart';
import '../../components/card/app_card.dart';
import '../../components/layout/app_page.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import '../widgets/settings_group.dart';
import '../widgets/settings_note.dart';
import '../widgets/settings_sections_layout.dart';
import 'account_session_card.dart';
import 'account_status_card.dart';
import 'sign_in_options.dart';

final class AccountView extends StatelessWidget {
  final AccountState accountState;
  final VoidCallback onSignInApple;
  final VoidCallback onSignInGoogle;
  final ValueChanged<String> onSignInMagicLink;
  final VoidCallback onSignOut;
  final VoidCallback onSignOutAndDeleteLocalData;
  final VoidCallback onDeleteAccount;
  final VoidCallback onBack;

  const AccountView({
    super.key,
    required this.accountState,
    required this.onSignInApple,
    required this.onSignInGoogle,
    required this.onSignInMagicLink,
    required this.onSignOut,
    required this.onSignOutAndDeleteLocalData,
    required this.onDeleteAccount,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colors.surfaces.canvas,
      body: AppPage(
        title: l10n.settingsAccount,
        onBack: onBack,
        backSemanticLabel: l10n.settingsBack,
        body: _AccountBody(view: this),
      ),
    );
  }
}

final class _AccountBody extends StatelessWidget {
  final AccountView view;

  const _AccountBody({required this.view});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final explanatoryText =
        '${l10n.settingsAccountSyncNotice}\n\n${l10n.settingsAccountOfflineNote}';

    return SingleChildScrollView(
      child: SettingsSectionsLayout(
        primary: _AccountPrimaryContent(view: view),
        secondary: SettingsNote(
          title: l10n.settingsAbout,
          text: explanatoryText,
        ),
      ),
    );
  }
}

final class _AccountPrimaryContent extends StatelessWidget {
  final AccountView view;

  const _AccountPrimaryContent({required this.view});

  @override
  Widget build(BuildContext context) {
    final state = view.accountState;
    return switch (state) {
      AccountAuthenticated(:final session) => AccountSessionCard(
          session: session,
          onSignOut: view.onSignOut,
          onSignOutAndDelete: view.onSignOutAndDeleteLocalData,
          onDeleteAccount: view.onDeleteAccount,
        ),
      AccountAuthenticating() => const AuthenticatingContent(),
      AccountError(:final message) => AccountErrorCard(
          message: message,
          onSignInApple: view.onSignInApple,
          onSignInGoogle: view.onSignInGoogle,
          onSignInMagicLink: view.onSignInMagicLink,
        ),
      AccountUnauthenticated(:final magicLinkSentToEmail) =>
        _UnauthenticatedContent(
          magicLinkSentToEmail: magicLinkSentToEmail,
          onSignInApple: view.onSignInApple,
          onSignInGoogle: view.onSignInGoogle,
          onSignInMagicLink: view.onSignInMagicLink,
        ),
    };
  }
}

final class _MagicLinkSuccessBanner extends StatelessWidget {
  final String email;

  const _MagicLinkSuccessBanner({required this.email});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      child: AppText(
        l10n.authMagicLinkSentNotice(email),
        variant: AppTextVariant.bodyDefault,
        color: theme.colors.severities.success.fg,
      ),
    );
  }
}

final class _UnauthenticatedContent extends StatelessWidget {
  final String? magicLinkSentToEmail;
  final VoidCallback onSignInApple;
  final VoidCallback onSignInGoogle;
  final ValueChanged<String> onSignInMagicLink;

  const _UnauthenticatedContent({
    required this.magicLinkSentToEmail,
    required this.onSignInApple,
    required this.onSignInGoogle,
    required this.onSignInMagicLink,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final l10n = AppLocalizations.of(context)!;
    final email = magicLinkSentToEmail;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (email != null) ...[
          _MagicLinkSuccessBanner(email: email),
          SizedBox(height: canvas.scaled(SpacingTokens.space4)),
        ],
        SettingsGroup(
          title: l10n.settingsAccountSectionOptions,
          items: [
            Padding(
              padding: EdgeInsets.all(canvas.scaled(SpacingTokens.space4)),
              child: SignInOptions(
                onSignInApple: onSignInApple,
                onSignInGoogle: onSignInGoogle,
                onSignInMagicLink: onSignInMagicLink,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
