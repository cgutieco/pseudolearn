import 'package:flutter/material.dart';
import '../../application/editor/editor_state.dart';
import '../../application/execution/execution_state.dart';
import '../../domain/model/analysis/app_diagnostic.dart';
import '../l10n/generated/app_localizations.dart';
import '../components/status_banner.dart';
import 'editor_surface.dart';

final class EditorTabView extends StatelessWidget {
  final EditorState editorState;
  final ExecutionState executionState;
  final ValueChanged<String> onCodeChanged;
  final EditorKeyPressed onKeyPressed;
  final ValueChanged<AppDiagnostic> onDiagnosticSelected;
  final VoidCallback onDismissStatusBanner;
  final VoidCallback onRun;
  final bool keepsKeyBar;

  const EditorTabView({
    super.key,
    required this.editorState,
    required this.executionState,
    required this.onCodeChanged,
    required this.onKeyPressed,
    required this.onDiagnosticSelected,
    required this.onDismissStatusBanner,
    required this.onRun,
    this.keepsKeyBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!executionState.isStatusBannerDismissed)
          _EditorExecutionStatusBanner(
            status: executionState.status,
            haltMessage: executionState.haltMessage,
            onDismiss: onDismissStatusBanner,
          ),
        Expanded(
          child: EditorSurface(
            editorState: editorState,
            executionState: executionState,
            onCodeChanged: onCodeChanged,
            onDiagnosticSelected: onDiagnosticSelected,
            onKeyPressed: onKeyPressed,
            onRun: onRun,
            keepsKeyBar: keepsKeyBar,
          ),
        ),
      ],
    );
  }
}

final class _EditorExecutionStatusBanner extends StatelessWidget {
  final ExecutionStatus status;
  final String? haltMessage;
  final VoidCallback onDismiss;

  const _EditorExecutionStatusBanner({
    required this.status,
    required this.haltMessage,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return switch (status) {
      ExecutionStatus.stepLimitReached => StatusBanner(
          severity: AppSeverity.warning,
          title: l10n.bannerStepLimitTitle,
          message: l10n.bannerStepLimitBody,
          onDismiss: onDismiss,
        ),
      ExecutionStatus.haltedWithError => StatusBanner(
          severity: AppSeverity.error,
          title: l10n.bannerErrorTitle,
          message: haltMessage ?? l10n.executionRuntimeError,
          onDismiss: onDismiss,
        ),
      ExecutionStatus.finishedSuccess => StatusBanner(
          severity: AppSeverity.success,
          title: l10n.bannerSuccessTitle,
          onDismiss: onDismiss,
        ),
      _ => const SizedBox.shrink(),
    };
  }
}
