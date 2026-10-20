import 'package:flutter/material.dart';
import '../../../domain/model/editor/editor_key.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/component_metrics.dart';

final class EditorStopRow extends StatelessWidget {
  final ValueChanged<EditorKey> onKeyPressed;

  const EditorStopRow({super.key, required this.onKeyPressed});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: ComponentMetricsTokens.editorTemplateRowHeight,
      child: Row(
        children: [
          _StopButton(
            icon: Icons.chevron_left,
            label: l10n.editorStopPrevious,
            onPressed: () =>
                onKeyPressed(const EditorKey.stop(EditorKeyKind.stopPrevious)),
          ),
          _StopButton(
            icon: Icons.chevron_right,
            label: l10n.editorStopNext,
            onPressed: () =>
                onKeyPressed(const EditorKey.stop(EditorKeyKind.stopNext)),
          ),
          _StopButton(
            icon: Icons.check,
            label: l10n.editorStopExit,
            onPressed: () =>
                onKeyPressed(const EditorKey.stop(EditorKeyKind.stopExit)),
          ),
        ],
      ),
    );
  }
}

final class _StopButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _StopButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Expanded(
      child: Semantics(
        button: true,
        excludeSemantics: true,
        label: label,
        onTap: onPressed,
        child: InkWell(
          onTap: onPressed,
          child: Center(child: Icon(icon, color: theme.colors.text.secondary)),
        ),
      ),
    );
  }
}
