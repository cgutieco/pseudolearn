import 'package:flutter/material.dart';
import '../../../domain/model/settings/ui_language_id.dart';
import '../../components/layout/app_page.dart';
import '../../components/list/app_radio_list.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import '../widgets/settings_group.dart';
import '../widgets/settings_note.dart';
import '../widgets/settings_sections_layout.dart';

List<AppRadioOption<UiLanguageId>> _languageOptions(AppLocalizations l10n) => [
      AppRadioOption(value: UiLanguageId.system, label: l10n.languageSystem),
      AppRadioOption(value: UiLanguageId.spanish, label: l10n.languageSpanish),
      AppRadioOption(value: UiLanguageId.english, label: l10n.languageEnglish),
    ];

final class LanguageSettingsView extends StatelessWidget {
  final UiLanguageId selectedLanguage;
  final ValueChanged<UiLanguageId> onLanguageSelected;
  final VoidCallback onBack;

  const LanguageSettingsView({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageSelected,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colors.surfaces.canvas,
      body: AppPage(
        title: l10n.settingsLanguage,
        onBack: onBack,
        backSemanticLabel: l10n.settingsBack,
        body: _LanguageBody(view: this),
      ),
    );
  }
}

final class _LanguageBody extends StatelessWidget {
  final LanguageSettingsView view;

  const _LanguageBody({required this.view});

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
              title: l10n.settingsLanguageOptions,
              items: [
                AppRadioList<UiLanguageId>(
                  options: _languageOptions(l10n),
                  selectedValue: view.selectedLanguage,
                  onSelected: view.onLanguageSelected,
                ),
              ],
            ),
            secondary: SettingsNote(
              title: l10n.settingsAbout,
              text: l10n.settingsLanguageNotice,
            ),
          ),
          SizedBox(height: canvas.scaled(SpacingTokens.space6)),
        ],
      ),
    );
  }
}
