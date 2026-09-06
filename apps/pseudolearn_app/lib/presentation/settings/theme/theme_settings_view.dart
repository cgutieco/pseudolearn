import 'package:flutter/material.dart';
import '../../../domain/model/settings/app_theme_mode.dart';
import '../../components/layout/app_page.dart';
import '../../components/list/app_radio_list.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import '../widgets/settings_group.dart';
import '../widgets/settings_note.dart';
import '../widgets/settings_sections_layout.dart';

List<AppRadioOption<AppThemeMode>> _themeOptions(AppLocalizations l10n) => [
      AppRadioOption(value: AppThemeMode.system, label: l10n.settingsThemeSystem),
      AppRadioOption(value: AppThemeMode.light, label: l10n.settingsThemeLight),
      AppRadioOption(value: AppThemeMode.dark, label: l10n.settingsThemeDark),
    ];

final class ThemeSettingsView extends StatelessWidget {
  final AppThemeMode selectedThemeMode;
  final ValueChanged<AppThemeMode> onThemeSelected;
  final VoidCallback onBack;

  const ThemeSettingsView({
    super.key,
    required this.selectedThemeMode,
    required this.onThemeSelected,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colors.surfaces.canvas,
      body: AppPage(
        title: l10n.settingsTheme,
        onBack: onBack,
        backSemanticLabel: l10n.settingsBack,
        body: _ThemeBody(view: this),
      ),
    );
  }
}

final class _ThemeBody extends StatelessWidget {
  final ThemeSettingsView view;

  const _ThemeBody({required this.view});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsSectionsLayout(
            primary: SettingsGroup(
              title: l10n.settingsThemeOptions,
              items: [
                AppRadioList<AppThemeMode>(
                  options: _themeOptions(l10n),
                  selectedValue: view.selectedThemeMode,
                  onSelected: view.onThemeSelected,
                ),
              ],
            ),
            secondary: SettingsNote(
              title: l10n.settingsAbout,
              text: l10n.settingsThemeNotice,
            ),
          ),
          SizedBox(height: canvas.scaled(SpacingTokens.space6)),
        ],
      ),
    );
  }
}
