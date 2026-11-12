import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/editor/editor_cubit.dart';
import '../../../application/execution/execution_cubit.dart';
import '../../../application/execution/execution_state.dart';
import '../../../application/execution/step_pace.dart';
import '../../../application/settings/settings_cubit.dart';
import '../../../domain/model/execution/execution_configuration.dart';
import '../../../domain/model/profiles/syntax_profile_id.dart';
import '../../components/button/app_button.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import 'replay_rejection_text.dart';

final class ExecutionReplaySection extends StatelessWidget {
  final ExecutionState execution;

  const ExecutionReplaySection({super.key, required this.execution});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final rejection = execution.replayRejection;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppButton(
          label: l10n.executionReplay,
          icon: Icons.replay,
          variant: AppButtonVariant.secondary,
          onPressed: execution.isInFlight ? null : () => _replay(context),
        ),
        const SizedBox(height: SpacingTokens.space1),
        AppText(
          rejection == null
              ? l10n.executionReplayHelp
              : replayRejectionText(rejection, l10n),
          variant: AppTextVariant.caption,
          color: rejection != null
              ? theme.colors.severities.warning.fg
              : theme.colors.text.secondary,
        ),
      ],
    );
  }

  void _replay(BuildContext context) {
    final current = context.read<EditorCubit>().state;
    final document = current.document;
    context.read<ExecutionCubit>().advance(
      pace: StepPace.toEnd,
      sourceCode: current.sourceCode,
      profileId: document?.profileId ?? SyntaxProfileId.classicSpanish,
      languageId: context.read<SettingsCubit>().state.language,
      replay: true,
      configuration: ExecutionConfiguration(
        documentId: document?.id ?? 'untitled',
        arguments: document?.executionArguments ?? const [],
      ),
    );
  }
}
