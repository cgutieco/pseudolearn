import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/diagram/diagram_cubit.dart';
import '../../../application/diagram/diagram_state.dart';
import '../../../application/editor/editor_cubit.dart';
import '../../../application/editor/editor_state.dart';
import '../../../application/execution/execution_cubit.dart';
import '../../../application/execution/execution_state.dart';
import '../../../application/export/export_cubit.dart';
import '../../../application/export/export_state.dart';
import '../../../application/settings/settings_cubit.dart';
import '../../../application/settings/settings_state.dart';
import '../../../application/trace/trace_cubit.dart';
import '../../../application/trace/trace_state.dart';
import '../../../domain/model/editor/caret_range.dart';
import '../../../domain/model/editor/editor_key.dart';
import '../../../domain/model/profiles/syntax_profile_id.dart';
import '../../diagram/flowchart_tab_view.dart';
import '../../editor/editor_tab_view.dart';
import '../../export/export_tab_view.dart';
import '../../trace/trace_table_tab_view.dart';
import 'companion_layout.dart';
import 'tab_selector.dart';

final class DocumentTabBody extends StatelessWidget {
  final DocumentTabKind activeTab;
  final VoidCallback onRun;

  const DocumentTabBody({super.key, required this.activeTab, required this.onRun});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditorCubit, EditorState>(
      builder: (context, editorState) => BlocBuilder<ExecutionCubit, ExecutionState>(
        builder: (context, execState) => DocumentTabContent(
          activeTab: activeTab,
          editorState: editorState,
          execState: execState,
          onRun: onRun,
        ),
      ),
    );
  }
}

final class DocumentTabContent extends StatelessWidget {
  final DocumentTabKind activeTab;
  final EditorState editorState;
  final ExecutionState execState;
  final VoidCallback onRun;
  final CompanionLayout? paneLayout;

  const DocumentTabContent({
    super.key,
    required this.activeTab,
    required this.editorState,
    required this.execState,
    required this.onRun,
    this.paneLayout,
  });

  @override
  Widget build(BuildContext context) {
    return switch (activeTab) {
      DocumentTabKind.editor => _EditorTabItem(
          editorState: editorState,
          execState: execState,
          onRun: onRun,
          keepsKeys: paneLayout?.keepsEditorKeys ?? true,
        ),
      DocumentTabKind.flowchart => _FlowchartTabItem(
          execState: execState,
          isSharingScreen: paneLayout != null,
        ),
      DocumentTabKind.trace => const _TraceTabItem(),
      DocumentTabKind.equivalentCode => _ExportTabItem(editorState: editorState),
    };
  }
}

final class _FlowchartTabItem extends StatelessWidget {
  final ExecutionState execState;
  final bool isSharingScreen;

  const _FlowchartTabItem({required this.execState, required this.isSharingScreen});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) => BlocBuilder<DiagramCubit, DiagramState>(
        builder: (context, diagState) => FlowchartTabView(
          state: diagState,
          focus: execState.currentStep.focus,
          framesSceneOnLayout: isSharingScreen,
          followsExecutionFocus: settingsState.assistedDiagramZoom,
          onUnitSelected: (unitId) => context.read<DiagramCubit>().selectUnit(unitId),
          onNotationSelected: (notation) =>
              context.read<DiagramCubit>().selectNotation(notation),
        ),
      ),
    );
  }
}

final class _TraceTabItem extends StatelessWidget {
  const _TraceTabItem();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TraceCubit, TraceState>(
      builder: (_, traceState) => TraceTableTabView(state: traceState),
    );
  }
}

final class _ExportTabItem extends StatelessWidget {
  final EditorState editorState;

  const _ExportTabItem({required this.editorState});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExportCubit, ExportState>(
      builder: (context, exportState) => ExportTabView(
        state: exportState,
        onLanguageSelected: (lang) => context.read<ExportCubit>().selectLanguage(
              lang,
              sourceCode: editorState.sourceCode,
              profileId: editorState.document?.profileId ?? SyntaxProfileId.classicSpanish,
            ),
      ),
    );
  }
}

final class _EditorTabItem extends StatelessWidget {
  final EditorState editorState;
  final ExecutionState execState;
  final VoidCallback onRun;
  final bool keepsKeys;

  const _EditorTabItem({
    required this.editorState,
    required this.execState,
    required this.onRun,
    required this.keepsKeys,
  });

  @override
  Widget build(BuildContext context) {
    return EditorTabView(
      editorState: editorState,
      executionState: execState,
      keepsKeyBar: keepsKeys,
      onCodeChanged: (code) => _propagate(context, code),
      onKeyPressed: (key, caret) => _applyKey(context, key, caret),
      onDiagnosticSelected: (d) => context.read<EditorCubit>().selectDiagnostic(d),
      onDismissStatusBanner: () => context.read<ExecutionCubit>().dismissStatusBanner(),
      onRun: onRun,
    );
  }

  void _propagate(BuildContext context, String code) {
    context.read<ExecutionCubit>().stop();
    final languageId = context.read<SettingsCubit>().state.language;
    context.read<EditorCubit>().updateSourceCode(code, languageId: languageId);
    _refreshCompanions(context, code);
  }

  void _applyKey(BuildContext context, EditorKey key, CaretRange caret) {
    context.read<ExecutionCubit>().stop();
    final editor = context.read<EditorCubit>();
    editor.applyKey(key, caret, languageId: context.read<SettingsCubit>().state.language);
    _refreshCompanions(context, editor.state.sourceCode);
  }

  void _refreshCompanions(BuildContext context, String code) {
    final profileId = editorState.document?.profileId ?? SyntaxProfileId.classicSpanish;
    final languageId = context.read<SettingsCubit>().state.language;
    context.read<DiagramCubit>().updateDiagram(
          sourceCode: code,
          profileId: profileId,
          languageId: languageId,
        );
    context.read<ExportCubit>().updateSource(sourceCode: code, profileId: profileId);
  }
}
