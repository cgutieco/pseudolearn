import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/diagram/diagram_cubit.dart';
import '../../../application/editor/editor_cubit.dart';
import '../../../application/editor/editor_state.dart';
import '../../../application/editor/help/syntax_help_cubit.dart';
import '../../../application/editor/help/syntax_help_state.dart';
import '../../../application/execution/execution_cubit.dart';
import '../../../application/execution/execution_state.dart';
import '../../../application/export/export_cubit.dart';
import '../../../application/settings/settings_cubit.dart';
import '../../../domain/model/editor/caret_range.dart';
import '../../../domain/model/editor/editor_key.dart';
import '../../../domain/model/profiles/syntax_profile_id.dart';
import '../../../domain/model/settings/ui_language_id.dart';
import '../../editor/editor_tab_view.dart';
import '../../editor/help/syntax_help_panel.dart';

final class EditorTabItem extends StatelessWidget {
  final EditorState editorState;
  final ExecutionState execState;
  final VoidCallback onRun;
  final bool keepsKeys;

  const EditorTabItem({
    super.key,
    required this.editorState,
    required this.execState,
    required this.onRun,
    required this.keepsKeys,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyntaxHelpCubit, SyntaxHelpState>(
      builder: (context, helpState) => EditorTabView(
        editorState: editorState,
        executionState: execState,
        keepsKeyBar: keepsKeys,
        assistanceEnabled: context.select<SettingsCubit, bool>(
          (cubit) => cubit.state.editorAssistance,
        ),
        onCodeChanged: (code, cursor) => _propagate(context, code, cursor),
        onCursorMoved: (cursor) =>
            context.read<EditorCubit>().updateCompletionCursor(cursor),
        onKeyPressed: (key, caret) => _applyKey(context, key, caret),
        onDiagnosticSelected: (d) =>
            context.read<EditorCubit>().selectDiagnostic(d),
        onDismissStatusBanner: () =>
            context.read<ExecutionCubit>().dismissStatusBanner(),
        onRun: onRun,
        onHelpRequested: (caret) => _requestHelp(context, caret),
        helpPanel: _HelpPanelSlot(state: helpState),
      ),
    );
  }

  void _requestHelp(BuildContext context, CaretRange caret) {
    final configured = context.read<SettingsCubit>().state.language;
    final code = configured.resolveLocaleCode(
      Localizations.localeOf(context).languageCode,
    );
    context.read<SyntaxHelpCubit>().request(
      sourceCode: editorState.sourceCode,
      profileId:
          editorState.document?.profileId ?? SyntaxProfileId.classicSpanish,
      languageId: code == 'en' ? UiLanguageId.english : UiLanguageId.spanish,
      cursorUtf16: caret.lower,
      revision: editorState.completionRevision,
    );
  }

  void _propagate(BuildContext context, String code, int cursorUtf16) {
    context.read<ExecutionCubit>().stop();
    final languageId = context.read<SettingsCubit>().state.language;
    context.read<EditorCubit>().updateSourceCode(
      code,
      cursorUtf16: cursorUtf16,
      languageId: languageId,
      assisted: context.read<SettingsCubit>().state.editorAssistance,
    );
    _refreshCompanions(context, context.read<EditorCubit>().state.sourceCode);
    context.read<SyntaxHelpCubit>().documentChanged(
      context.read<EditorCubit>().state.completionRevision,
    );
  }

  void _applyKey(BuildContext context, EditorKey key, CaretRange caret) {
    context.read<ExecutionCubit>().stop();
    final editor = context.read<EditorCubit>();
    editor.applyKey(
      key,
      caret,
      languageId: context.read<SettingsCubit>().state.language,
    );
    _refreshCompanions(context, editor.state.sourceCode);
    context.read<SyntaxHelpCubit>().documentChanged(
      editor.state.completionRevision,
    );
  }

  void _refreshCompanions(BuildContext context, String code) {
    final profileId =
        editorState.document?.profileId ?? SyntaxProfileId.classicSpanish;
    final languageId = context.read<SettingsCubit>().state.language;
    context.read<DiagramCubit>().updateDiagram(
      sourceCode: code,
      profileId: profileId,
      languageId: languageId,
    );
    context.read<ExportCubit>().updateSource(
      sourceCode: code,
      profileId: profileId,
    );
  }
}

final class _HelpPanelSlot extends StatelessWidget {
  final SyntaxHelpState state;

  const _HelpPanelSlot({required this.state});

  @override
  Widget build(BuildContext context) {
    final result = state.visibleResult;
    if (result == null) return const SizedBox.shrink();
    return SyntaxHelpPanel(
      result: result,
      onClose: context.read<SyntaxHelpCubit>().dismiss,
    );
  }
}
