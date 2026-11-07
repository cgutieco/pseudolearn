import 'package:flutter/material.dart';
import '../../components/card/app_card_surface.dart';
import '../../components/layout/app_page.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import '../widgets/settings_sections_layout.dart';
import 'contact_cards.dart';
import 'contact_channel_tile.dart';

final class ContactSupportView extends StatelessWidget {
  final VoidCallback onBack;

  const ContactSupportView({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: theme.colors.surfaces.canvas,
      body: AppPage(
        title: l10n.settingsContactTitle,
        onBack: onBack,
        backSemanticLabel: l10n.settingsBack,
        body: const _ContactSheet(),
      ),
    );
  }
}

final class _ContactSheet extends StatelessWidget {
  const _ContactSheet();

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SettingsSectionsLayout(
            primary: _PrimarySection(),
            secondary: _SecondarySection(),
          ),
          SizedBox(height: canvas.scaled(SpacingTokens.space6)),
        ],
      ),
    );
  }
}

final class _PrimarySection extends StatelessWidget {
  const _PrimarySection();

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ContactHeroCard(introText: l10n.settingsContactIntro),
        SizedBox(height: canvas.scaled(SpacingTokens.space4)),
        AppCardSurface(
          padding: EdgeInsets.all(canvas.scaled(SpacingTokens.space5)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ContactChannelTile(item: l10n.settingsContactChannelEmail),
              ContactChannelTile(item: l10n.settingsContactChannelWebsite),
              ContactChannelTile(item: l10n.settingsContactChannelSupport),
            ],
          ),
        ),
      ],
    );
  }
}

final class _SecondarySection extends StatelessWidget {
  const _SecondarySection();

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ContactPedagogicalCard(),
        SizedBox(height: canvas.scaled(SpacingTokens.space4)),
        const ContactTipsCard(),
      ],
    );
  }
}
