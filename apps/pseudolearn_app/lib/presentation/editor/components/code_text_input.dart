import 'package:flutter/material.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/editor_metrics.dart';

final class CodeTextInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool isReadOnly;
  final ValueChanged<String> onChanged;
  final VoidCallback? onExplain;

  const CodeTextInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isReadOnly,
    required this.onChanged,
    this.onExplain,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final style = resolveAppTextStyle(context, AppTextVariant.codeEditor);
    return TextField(
      controller: controller,
      focusNode: focusNode,
      readOnly: isReadOnly,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      autocorrect: false,
      enableSuggestions: false,
      smartDashesType: SmartDashesType.disabled,
      smartQuotesType: SmartQuotesType.disabled,
      textCapitalization: TextCapitalization.none,
      style: style,
      cursorColor: theme.editor.caret,
      cursorWidth: EditorMetricsTokens.editorCaretWidth,
      cursorHeight:
          style.fontSize! * EditorMetricsTokens.editorCaretHeightFactor,
      decoration: _inputDecoration,
      onChanged: onChanged,
      contextMenuBuilder: (_, state) =>
          _ExplainContextMenu(state: state, onExplain: onExplain),
    );
  }
}

const _inputDecoration = InputDecoration(
  border: InputBorder.none,
  enabledBorder: InputBorder.none,
  focusedBorder: InputBorder.none,
  isDense: true,
  contentPadding: EdgeInsets.zero,
);

final class _ExplainContextMenu extends StatelessWidget {
  final EditableTextState state;
  final VoidCallback? onExplain;

  const _ExplainContextMenu({required this.state, required this.onExplain});

  @override
  Widget build(BuildContext context) {
    final explain = onExplain;
    if (explain == null) {
      return AdaptiveTextSelectionToolbar.editableText(editableTextState: state);
    }
    final l10n = AppLocalizations.of(context)!;
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: state.contextMenuAnchors,
      buttonItems: [
        ...state.contextMenuButtonItems,
        ContextMenuButtonItem(
          label: l10n.helpExplainAction,
          onPressed: () {
            state.hideToolbar();
            explain();
          },
        ),
      ],
    );
  }
}
