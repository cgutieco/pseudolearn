import 'package:flutter/material.dart';
import '../../../domain/model/analysis/app_diagnostic.dart';
import '../diagnostics_panel.dart';
import 'keyboard_exit_actions.dart';

final class EditorDiagnosticsStrip extends StatelessWidget {
  final List<AppDiagnostic> diagnostics;
  final ValueChanged<AppDiagnostic> onDiagnosticTap;
  final bool offersExitActions;
  final bool canRun;
  final VoidCallback onRun;
  final VoidCallback onHideKeyboard;

  const EditorDiagnosticsStrip({
    super.key,
    required this.diagnostics,
    required this.onDiagnosticTap,
    required this.offersExitActions,
    required this.canRun,
    required this.onRun,
    required this.onHideKeyboard,
  });

  @override
  Widget build(BuildContext context) {
    final panel = DiagnosticsPanel(
      diagnostics: diagnostics,
      onDiagnosticTap: onDiagnosticTap,
      isCollapsed: offersExitActions,
      trailing: offersExitActions
          ? KeyboardExitActions(
              canRun: canRun,
              onRun: onRun,
              onHideKeyboard: onHideKeyboard,
            )
          : null,
    );
    if (!offersExitActions) return panel;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onHideKeyboard,
      child: panel,
    );
  }
}
