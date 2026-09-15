import 'package:flutter/material.dart';
import '../../../domain/model/settings/app_theme_mode.dart';
import '../../../domain/model/settings/ui_language_id.dart';
import '../../brand/brand_lockup.dart';
import '../../components/list/app_list_item.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/brand_metrics.dart';
import 'settings_group.dart';

String _languageName(UiLanguageId language, AppLocalizations l10n) => switch (language) {
      UiLanguageId.system => l10n.languageSystem,
      UiLanguageId.spanish => l10n.languageSpanish,
      UiLanguageId.english => l10n.languageEnglish,
    };

String _themeName(AppThemeMode themeMode, AppLocalizations l10n) => switch (themeMode) {
      AppThemeMode.system => l10n.settingsThemeSystem,
      AppThemeMode.light => l10n.settingsThemeLight,
      AppThemeMode.dark => l10n.settingsThemeDark,
    };

String _diagramAssistName(bool isAssisted, AppLocalizations l10n) =>
    isAssisted ? l10n.settingsDiagramAssistOn : l10n.settingsDiagramAssistOff;

final class GeneralSection extends StatelessWidget {
  final UiLanguageId language;
  final AppThemeMode themeMode;
  final bool assistedDiagramZoom;
  final VoidCallback onNavigateAccount;
  final VoidCallback onNavigateLanguage;
  final VoidCallback onNavigateTheme;
  final VoidCallback onNavigateDiagram;
  final VoidCallback onRestartOnboarding;

  const GeneralSection({
    super.key,
    required this.language,
    required this.themeMode,
    required this.assistedDiagramZoom,
    required this.onNavigateAccount,
    required this.onNavigateLanguage,
    required this.onNavigateTheme,
    required this.onNavigateDiagram,
    required this.onRestartOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SettingsGroup(
      title: l10n.settingsSectionGeneral,
      items: [
        AppListItem(icon: Icons.person_outline, label: l10n.settingsAccount, trailing: AppListItemTrailingKind.chevron, onTap: onNavigateAccount),
        AppListItem(icon: Icons.language, label: l10n.settingsLanguage, trailing: AppListItemTrailingKind.value, trailingValueText: _languageName(language, l10n), onTap: onNavigateLanguage),
        AppListItem(icon: Icons.palette_outlined, label: l10n.settingsTheme, trailing: AppListItemTrailingKind.value, trailingValueText: _themeName(themeMode, l10n), onTap: onNavigateTheme),
        AppListItem(icon: Icons.center_focus_strong, label: l10n.settingsDiagramAssist, trailing: AppListItemTrailingKind.value, trailingValueText: _diagramAssistName(assistedDiagramZoom, l10n), onTap: onNavigateDiagram),
        AppListItem(icon: Icons.restart_alt, label: l10n.settingsRestartOnboarding, trailing: AppListItemTrailingKind.chevron, onTap: onRestartOnboarding),
      ],
    );
  }
}

final class InformationSection extends StatelessWidget {
  final VoidCallback onNavigateContact;

  const InformationSection({super.key, required this.onNavigateContact});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SettingsGroup(
      title: l10n.settingsSectionInformation,
      items: [
        AppListItem(icon: Icons.help_outline, label: l10n.settingsContact, trailing: AppListItemTrailingKind.chevron, onTap: onNavigateContact),
      ],
    );
  }
}

final class VersionFooter extends StatelessWidget {
  const VersionFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const BrandLockup(typeSize: BrandMetricsTokens.lockupTypeSizeFooter),
        AppText(
          l10n.settingsVersion('1.0.0'),
          variant: AppTextVariant.caption,
          color: theme.colors.text.tertiary,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
