import '../../theme/tokens/component_metrics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/editor/editor_cubit.dart';
import '../../../application/editor/editor_state.dart';
import '../../../application/execution/execution_cubit.dart';
import '../../../application/execution/execution_state.dart';
import '../../../application/execution/step_pace.dart';
import '../../../application/settings/settings_cubit.dart';
import '../../../domain/model/execution/execution_argument_text.dart';
import '../../../domain/model/execution/execution_configuration.dart';
import '../../../domain/model/profiles/syntax_profile_id.dart';
import '../../l10n/generated/app_localizations.dart';

final class ExecutionConfigurationControls extends StatelessWidget {
  const ExecutionConfigurationControls({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<EditorCubit, EditorState>(
    builder: (context, editor) => BlocBuilder<ExecutionCubit, ExecutionState>(
      builder: (context, execution) =>
          _Controls(editor: editor, execution: execution),
    ),
  );
}

final class _Controls extends StatelessWidget {
  final EditorState editor;
  final ExecutionState execution;

  const _Controls({required this.editor, required this.execution});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _Strictness(editor: editor, enabled: !execution.isInFlight),
            _Arguments(editor: editor, enabled: !execution.isInFlight),
            TextButton.icon(
              icon: const Icon(Icons.replay),
              label: Text(l10n.executionReplay),
              onPressed: !execution.isInFlight && execution.recordedTape != null
                  ? () => _replay(context)
                  : null,
            ),
          ],
        ),
        if (execution.workingDirectory case final directory?)
          SelectableText(l10n.executionWorkingDirectory(directory)),
        if (execution.replayRejection != null)
          Text(l10n.executionReplayRejected),
      ],
    );
  }

  void _replay(BuildContext context) {
    final document = editor.document;
    context.read<ExecutionCubit>().advance(
      pace: StepPace.toEnd,
      sourceCode: editor.sourceCode,
      profileId: document?.profileId ?? SyntaxProfileId.classicSpanish,
      languageId: context.read<SettingsCubit>().state.language,
      replay: true,
      configuration: ExecutionConfiguration(
        documentId: document?.id ?? 'untitled',
        strictness: document?.strictness ?? 'flexible',
        arguments: document?.executionArguments ?? const [],
      ),
    );
  }
}

final class _Arguments extends StatelessWidget {
  final EditorState editor;
  final bool enabled;

  const _Arguments({required this.editor, required this.enabled});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: ComponentMetricsTokens.executionArgumentsWidth,
    child: TextFormField(
      key: ValueKey(editor.document?.id),
      enabled: enabled,
      initialValue: ExecutionArgumentText.format(
        editor.document?.executionArguments ?? const [],
      ),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.executionArguments,
      ),
      validator: (text) => ExecutionArgumentText.parse(text ?? '') == null
          ? AppLocalizations.of(context)!.executionArgumentsInvalid
          : null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (text) => _save(context, text),
    ),
  );
  void _save(BuildContext context, String text) {
    final arguments = ExecutionArgumentText.parse(text);
    final document = editor.document;
    if (arguments == null || document == null) return;
    context.read<EditorCubit>().updateSourceCode(
      editor.sourceCode,
      executionConfiguration: ExecutionConfiguration(
        documentId: document.id,
        strictness: document.strictness,
        arguments: arguments,
      ),
    );
  }
}

final class _Strictness extends StatelessWidget {
  final EditorState editor;
  final bool enabled;
  const _Strictness({required this.editor, required this.enabled});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      label: l10n.executionStrictness,
      child: DropdownButton<String>(
        value: editor.document?.strictness ?? 'flexible',
        hint: Text(l10n.executionStrictness),
        items: [
          DropdownMenuItem(value: 'strict', child: Text(l10n.executionStrict)),
          DropdownMenuItem(
            value: 'flexible',
            child: Text(l10n.executionFlexible),
          ),
        ],
        onChanged: !enabled
            ? null
            : (value) => _save(context, strictness: value),
      ),
    );
  }

  void _save(BuildContext context, {String? strictness}) {
    final document = editor.document;
    if (document == null) return;
    context.read<EditorCubit>().updateSourceCode(
      editor.sourceCode,
      executionConfiguration: ExecutionConfiguration(
        documentId: document.id,
        strictness: strictness ?? document.strictness,
        arguments: document.executionArguments,
      ),
    );
  }
}
