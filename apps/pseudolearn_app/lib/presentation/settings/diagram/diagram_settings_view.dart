import 'package:flutter/material.dart';
import '../../components/layout/app_page.dart';
import '../../components/list/app_radio_list.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import '../widgets/settings_group.dart';
import '../widgets/settings_note.dart';
import '../widgets/settings_sections_layout.dart';

List<AppRadioOption<bool>> _assistOptions(AppLocalizations l10n) => [
      AppRadioOption(value: true, label: l10n.settingsDiagramAssistOn),
      AppRadioOption(value: false, label: l10n.settingsDiagramAssistOff),
    ];

final class DiagramSettingsView extends StatelessWidget {
  final bool isAssisted;
  final ValueChanged<bool> onAssistSelected;
  final VoidCallback onBack;

  const DiagramSettingsView({
    super.key,
    required this.isAssisted,
    required this.onAssistSelected,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colors.surfaces.canvas,
      body: AppPage(
        title: l10n.settingsDiagramAssist,
        onBack: onBack,
        backSemanticLabel: l10n.settingsBack,
        body: _DiagramBody(view: this),
      ),
    );
  }
}

final class _DiagramBody extends StatelessWidget {
  final DiagramSettingsView view;

  const _DiagramBody({required this.view});

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
              title: l10n.settingsDiagramAssistOptions,
              items: [
                AppRadioList<bool>(
                  options: _assistOptions(l10n),
                  selectedValue: view.isAssisted,
                  onSelected: view.onAssistSelected,
                ),
              ],
            ),
            secondary: SettingsNote(
              title: l10n.settingsAbout,
              text: l10n.settingsDiagramAssistNotice,
            ),
          ),
          SizedBox(height: canvas.scaled(SpacingTokens.space6)),
        ],
      ),
    );
  }
}
