import 'package:flutter/material.dart';
import '../../domain/model/settings/app_theme_mode.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../components/layout/app_page.dart';
import '../l10n/generated/app_localizations.dart';
import '../shell/design_canvas.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/spacing.dart';
import 'widgets/settings_sections.dart';
import 'widgets/settings_sections_layout.dart';

final class SettingsOverviewView extends StatelessWidget {
  final UiLanguageId currentLanguage;
  final AppThemeMode currentThemeMode;
  final bool assistedDiagramZoom;
  final VoidCallback onNavigateAccount;
  final VoidCallback onNavigateLanguage;
  final VoidCallback onNavigateTheme;
  final VoidCallback onNavigateDiagram;
  final VoidCallback onRestartOnboarding;
  final VoidCallback onNavigateContact;

  const SettingsOverviewView({
    super.key,
    required this.currentLanguage,
    required this.currentThemeMode,
    required this.assistedDiagramZoom,
    required this.onNavigateAccount,
    required this.onNavigateLanguage,
    required this.onNavigateTheme,
    required this.onNavigateDiagram,
    required this.onRestartOnboarding,
    required this.onNavigateContact,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colors.surfaces.canvas,
      body: AppPage(
        title: l10n.settingsTitle,
        body: _SettingsOverviewBody(view: this),
      ),
    );
  }
}

final class _SettingsOverviewBody extends StatelessWidget {
  final SettingsOverviewView view;

  const _SettingsOverviewBody({required this.view});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsSectionsLayout(
            primary: GeneralSection(
              language: view.currentLanguage,
              themeMode: view.currentThemeMode,
              assistedDiagramZoom: view.assistedDiagramZoom,
              onNavigateAccount: view.onNavigateAccount,
              onNavigateLanguage: view.onNavigateLanguage,
              onNavigateTheme: view.onNavigateTheme,
              onNavigateDiagram: view.onNavigateDiagram,
              onRestartOnboarding: view.onRestartOnboarding,
            ),
            secondary: InformationSection(onNavigateContact: view.onNavigateContact),
          ),
          SizedBox(height: canvas.scaled(SpacingTokens.space8)),
          const VersionFooter(),
          SizedBox(height: canvas.scaled(SpacingTokens.space6)),
        ],
      ),
    );
  }
}
