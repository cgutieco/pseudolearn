import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';

final class AppDestinationSpec {
  final String path;
  final IconData icon;
  final IconData selectedIcon;
  final String Function(AppLocalizations l10n) label;

  const AppDestinationSpec({
    required this.path,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

const List<AppDestinationSpec> appDestinations = <AppDestinationSpec>[
  AppDestinationSpec(
    path: '/biblioteca',
    icon: Icons.folder_outlined,
    selectedIcon: Icons.folder_rounded,
    label: _libraryLabel,
  ),
  AppDestinationSpec(
    path: '/conocimiento',
    icon: Icons.menu_book_outlined,
    selectedIcon: Icons.menu_book_rounded,
    label: _knowledgeLabel,
  ),
  AppDestinationSpec(
    path: '/progreso',
    icon: Icons.insights_outlined,
    selectedIcon: Icons.insights_rounded,
    label: _progressLabel,
  ),
  AppDestinationSpec(
    path: '/ajustes',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings_rounded,
    label: _settingsLabel,
  ),
];

String _libraryLabel(AppLocalizations l10n) => l10n.navLibrary;

String _knowledgeLabel(AppLocalizations l10n) => l10n.navKnowledge;

String _progressLabel(AppLocalizations l10n) => l10n.navProgress;

String _settingsLabel(AppLocalizations l10n) => l10n.navSettings;
