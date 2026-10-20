import 'package:flutter/material.dart';
import '../../components/typography/app_text.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/editor_metrics.dart';

final class CodeTextInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool isReadOnly;
  final ValueChanged<String> onChanged;

  const CodeTextInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isReadOnly,
    required this.onChanged,
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
      decoration: const InputDecoration(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
      onChanged: onChanged,
    );
  }
}
