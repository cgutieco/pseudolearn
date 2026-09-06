import 'package:flutter/material.dart';
import '../../components/card/app_card.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import '../widgets/settings_group.dart';
import 'sign_in_options.dart';

final class AuthenticatingContent extends StatelessWidget {
  const AuthenticatingContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      child: Center(
        child: AppText(
          l10n.authAuthenticating,
          variant: AppTextVariant.bodyDefault,
          color: theme.colors.text.secondary,
        ),
      ),
    );
  }
}

final class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final text = message == 'no_connection'
        ? l10n.authErrorNoConnection
        : l10n.authErrorGeneric;

    return AppCard(
      child: AppText(
        text,
        variant: AppTextVariant.bodyDefault,
        color: theme.colors.severities.error.fg,
      ),
    );
  }
}

final class AccountErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onSignInApple;
  final VoidCallback onSignInGoogle;
  final ValueChanged<String> onSignInMagicLink;

  const AccountErrorCard({
    super.key,
    required this.message,
    required this.onSignInApple,
    required this.onSignInGoogle,
    required this.onSignInMagicLink,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final l10n = AppLocalizations.of(context)!;
    final padding = EdgeInsets.all(canvas.scaled(SpacingTokens.space4));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ErrorBanner(message: message),
        SizedBox(height: canvas.scaled(SpacingTokens.space4)),
        SettingsGroup(
          title: l10n.settingsAccountSectionOptions,
          items: [
            Padding(
              padding: padding,
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
