import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';

final class SimulatedScenarioHelpButton extends StatelessWidget {
  final bool compact;

  const SimulatedScenarioHelpButton({super.key, required this.compact});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return IconButton(
      tooltip: l10n.simulatedScenarioHelpAction,
      onPressed: () => _showHelp(context, l10n),
      icon: Icon(
        compact ? Icons.help_outline : Icons.info_outline,
        color: AppThemeExtension.of(context).colors.text.secondary,
      ),
    );
  }

  void _showHelp(BuildContext context, AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.simulatedScenarioHelpTitle),
        content: Text(l10n.simulatedScenarioHelpBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.simulatedScenarioHelpClose),
          ),
        ],
      ),
    );
  }
}
