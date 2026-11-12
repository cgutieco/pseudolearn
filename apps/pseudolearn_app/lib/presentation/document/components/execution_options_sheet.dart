import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/editor/editor_cubit.dart';
import '../../../application/editor/editor_state.dart';
import '../../../application/execution/execution_cubit.dart';
import '../../../application/execution/execution_state.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';
import 'execution_arguments_field.dart';
import 'execution_replay_section.dart';
import 'working_directory_note.dart';

void showExecutionOptionsSheet(BuildContext context) {
  final theme = AppThemeExtension.of(context);
  final editor = context.read<EditorCubit>();
  final execution = context.read<ExecutionCubit>();
  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: theme.colors.surfaces.overlay,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(RadiusTokens.radiusXl),
      ),
    ),
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider<EditorCubit>.value(value: editor),
        BlocProvider<ExecutionCubit>.value(value: execution),
      ],
      child: const ExecutionOptionsSheet(key: ValueKey('feature:execution-options')),
    ),
  );
}

final class ExecutionOptionsSheet extends StatelessWidget {
  const ExecutionOptionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final inset = DesignCanvasScope.of(context).keyboardInset;
    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: SafeArea(
        child: BlocBuilder<EditorCubit, EditorState>(
          builder: (context, editor) =>
              BlocBuilder<ExecutionCubit, ExecutionState>(
                builder: (context, execution) =>
                    _SheetContent(editor: editor, execution: execution),
              ),
        ),
      ),
    );
  }
}

final class _SheetContent extends StatelessWidget {
  final EditorState editor;
  final ExecutionState execution;

  const _SheetContent({required this.editor, required this.execution});

  @override
  Widget build(BuildContext context) {
    final directory = execution.workingDirectory;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SpacingTokens.space4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SheetTitle(),
          const SizedBox(height: SpacingTokens.space4),
          ExecutionArgumentsField(
            editor: editor,
            enabled: !execution.isInFlight,
          ),
          if (execution.recordedTape != null) ...[
            const SizedBox(height: SpacingTokens.space4),
            ExecutionReplaySection(execution: execution),
          ],
          const SizedBox(height: SpacingTokens.space4),
          WorkingDirectoryNote(directory: directory),
        ],
      ),
    );
  }
}

final class _SheetTitle extends StatelessWidget {
  const _SheetTitle();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: AppText(
        AppLocalizations.of(context)!.runOptionsTitle,
        variant: AppTextVariant.heading4,
      ),
    );
  }
}
