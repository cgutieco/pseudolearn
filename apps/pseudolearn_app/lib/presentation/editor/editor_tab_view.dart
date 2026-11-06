import 'package:flutter/material.dart';
import '../../application/editor/editor_state.dart';
import '../../application/execution/execution_state.dart';
import '../../domain/model/analysis/app_diagnostic.dart';
import '../../domain/model/editor/caret_range.dart';
import '../../domain/model/analysis/source_range.dart';
import 'editor_surface.dart';

final class EditorTabView extends StatelessWidget {
  final EditorState editorState;
  final ExecutionState executionState;
  final EditorCodeChanged onCodeChanged;
  final ValueChanged<int>? onCursorMoved;
  final EditorKeyPressed onKeyPressed;
  final ValueChanged<AppDiagnostic> onDiagnosticSelected;
  final VoidCallback onRun;
  final bool keepsKeyBar;
  final bool assistanceEnabled;
  final ValueChanged<CaretRange>? onHelpRequested;
  final SourceRange? helpKeyword;

  const EditorTabView({
    super.key,
    required this.editorState,
    required this.executionState,
    required this.onCodeChanged,
    this.onCursorMoved,
    required this.onKeyPressed,
    required this.onDiagnosticSelected,
    required this.onRun,
    this.keepsKeyBar = true,
    this.assistanceEnabled = false,
    this.onHelpRequested,
    this.helpKeyword,
  });

  @override
  Widget build(BuildContext context) => _EditorTabContent(view: this);
}

final class _EditorTabContent extends StatelessWidget {
  final EditorTabView view;

  const _EditorTabContent({required this.view});

  @override
  Widget build(BuildContext context) => EditorSurface(
    editorState: view.editorState,
    executionState: view.executionState,
    onCodeChanged: view.onCodeChanged,
    onCursorMoved: view.onCursorMoved,
    onDiagnosticSelected: view.onDiagnosticSelected,
    onKeyPressed: view.onKeyPressed,
    onRun: view.onRun,
    keepsKeyBar: view.keepsKeyBar,
    assistanceEnabled: view.assistanceEnabled,
    onHelpRequested: view.onHelpRequested,
    helpKeyword: view.helpKeyword,
  );
}
