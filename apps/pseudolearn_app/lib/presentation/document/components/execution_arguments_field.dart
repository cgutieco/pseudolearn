import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/editor/editor_cubit.dart';
import '../../../application/editor/editor_state.dart';
import '../../../domain/model/execution/execution_argument_text.dart';
import '../../../domain/model/execution/execution_configuration.dart';
import '../../components/field/app_text_field.dart';
import '../../l10n/generated/app_localizations.dart';

final class ExecutionArgumentsField extends StatefulWidget {
  final EditorState editor;
  final bool enabled;

  const ExecutionArgumentsField({
    super.key,
    required this.editor,
    required this.enabled,
  });

  @override
  State<ExecutionArgumentsField> createState() =>
      _ExecutionArgumentsFieldState();
}

final class _ExecutionArgumentsFieldState
    extends State<ExecutionArgumentsField> {
  late final TextEditingController _controller;
  bool _isMalformed = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ExecutionArgumentText.format(
        widget.editor.document?.executionArguments ?? const [],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save(String text) {
    final arguments = ExecutionArgumentText.parse(text);
    setState(() => _isMalformed = arguments == null);
    final document = widget.editor.document;
    if (arguments == null || document == null) return;
    context.read<EditorCubit>().updateSourceCode(
      widget.editor.sourceCode,
      executionConfiguration: ExecutionConfiguration(
        documentId: document.id,
        arguments: arguments,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppTextField(
      controller: _controller,
      label: l10n.executionArguments,
      helperText: l10n.executionArgumentsHelp,
      errorText: _isMalformed ? l10n.executionArgumentsInvalid : null,
      enabled: widget.enabled,
      onChanged: _save,
    );
  }
}
