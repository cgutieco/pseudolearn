import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/editor/editor_cubit.dart';
import '../../../application/editor/editor_state.dart';
import '../../../application/execution/execution_cubit.dart';
import '../../../application/execution/execution_state.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/border_metrics.dart';
import 'companion_layout.dart';
import 'document_tab_body.dart';
import 'tab_selector.dart';

final class DocumentWorkspace extends StatelessWidget {
  final DocumentTabKind activeTab;
  final CompanionLayout? companionLayout;
  final VoidCallback onRun;

  const DocumentWorkspace({
    super.key,
    required this.activeTab,
    required this.companionLayout,
    required this.onRun,
  });

  @override
  Widget build(BuildContext context) {
    final layout = companionLayout;
    if (layout == null) {
      return DocumentTabBody(activeTab: activeTab, onRun: onRun);
    }

    return BlocBuilder<EditorCubit, EditorState>(
      builder: (context, editorState) => BlocBuilder<ExecutionCubit, ExecutionState>(
        builder: (context, execState) => _SplitPanes(
          layout: layout,
          companionTab: activeTab,
          editorState: editorState,
          execState: execState,
          onRun: onRun,
        ),
      ),
    );
  }
}

final class _SplitPanes extends StatelessWidget {
  final CompanionLayout layout;
  final DocumentTabKind companionTab;
  final EditorState editorState;
  final ExecutionState execState;
  final VoidCallback onRun;

  const _SplitPanes({
    required this.layout,
    required this.companionTab,
    required this.editorState,
    required this.execState,
    required this.onRun,
  });

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: layout.direction,
      children: [
        Expanded(
          flex: layout.editorFlex,
          child: DocumentTabContent(
            activeTab: DocumentTabKind.editor,
            editorState: editorState,
            execState: execState,
            onRun: onRun,
            paneLayout: layout,
          ),
        ),
        _PaneDivider(direction: layout.direction),
        Expanded(
          flex: layout.companionFlex,
          child: DocumentTabContent(
            activeTab: companionTab,
            editorState: editorState,
            execState: execState,
            onRun: onRun,
            paneLayout: layout,
          ),
        ),
      ],
    );
  }
}

final class _PaneDivider extends StatelessWidget {
  final Axis direction;

  const _PaneDivider({required this.direction});

  @override
  Widget build(BuildContext context) {
    final color = AppThemeExtension.of(context).colors.borders.subtle;

    return switch (direction) {
      Axis.horizontal => VerticalDivider(
          width: BorderMetricsTokens.widthHairline,
          thickness: BorderMetricsTokens.widthHairline,
          color: color,
        ),
      Axis.vertical => Divider(
          height: BorderMetricsTokens.widthHairline,
          thickness: BorderMetricsTokens.widthHairline,
          color: color,
        ),
    };
  }
}
