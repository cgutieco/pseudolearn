import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../application/exercises/user_exercise_editor_cubit.dart';
import '../../application/exercises/user_exercise_editor_state.dart';
import '../../application/settings/settings_cubit.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../components/button/app_button.dart';
import '../theme/tokens/spacing.dart';
import '../components/layout/app_page.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import 'user_exercise_controllers.dart';
import 'user_exercise_form_fields.dart';
import 'user_exercise_problem_text.dart';

const String newUserExerciseSegment = 'nuevo';

final class UserExerciseEditorPage extends StatefulWidget {
  final String exerciseId;

  const UserExerciseEditorPage({super.key, required this.exerciseId});

  @override
  State<UserExerciseEditorPage> createState() => _UserExerciseEditorPageState();
}

final class _UserExerciseEditorPageState extends State<UserExerciseEditorPage> {
  final UserExerciseControllers _controllers = UserExerciseControllers();

  @override
  void initState() {
    super.initState();
    final language = context.read<SettingsCubit>().state.language;
    context.read<UserExerciseEditorCubit>().open(
      widget.exerciseId == newUserExerciseSegment ? null : widget.exerciseId,
      profileId: language == UiLanguageId.english
          ? SyntaxProfileId.english
          : SyntaxProfileId.classicSpanish,
    );
  }

  @override
  void dispose() {
    _controllers.dispose();
    super.dispose();
  }

  void _onState(BuildContext context, UserExerciseEditorState state) {
    if (state.status == UserExerciseEditorStatus.saved) {
      context.pop();
    } else if (state.status == UserExerciseEditorStatus.editing && state.publication == null) {
      _controllers.fill(state.draft);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserExerciseEditorCubit, UserExerciseEditorState>(
      listener: _onState,
      builder: (context, state) => _EditorView(
        state: state,
        controllers: _controllers,
        onSubmit: () => context.read<UserExerciseEditorCubit>().submit(_controllers.read()),
        onBack: () => context.pop(),
      ),
    );
  }
}

final class _EditorView extends StatelessWidget {
  final UserExerciseEditorState state;
  final UserExerciseControllers controllers;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  const _EditorView({
    required this.state,
    required this.controllers,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return Scaffold(
      key: const ValueKey('feature:user-exercise-editor'),
      backgroundColor: theme.colors.surfaces.canvas,
      body: AppPage(
        title: state.isNew ? l10n.userExerciseEditorNewTitle : l10n.userExerciseEditorEditTitle,
        measure: ContentMeasure.form,
        onBack: onBack,
        backSemanticLabel: l10n.settingsBack,
        body: ListView(
          children: [
            UserExerciseFormFields(controllers: controllers),
            _Feedback(text: userExerciseFeedback(l10n, state)),
            AppButton(
              key: const ValueKey('user-exercise-publish'),
              label: l10n.userExercisePublish,
              variant: AppButtonVariant.primary,
              onPressed: state.status == UserExerciseEditorStatus.saving ? null : onSubmit,
            ),
            const SizedBox(height: SpacingTokens.space8),
          ],
        ),
      ),
    );
  }
}

final class _Feedback extends StatelessWidget {
  final String? text;

  const _Feedback({required this.text});

  @override
  Widget build(BuildContext context) {
    final message = text;
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.space4),
      child: Semantics(
        liveRegion: true,
        child: AppText(
          message,
          variant: AppTextVariant.bodySmall,
          color: AppThemeExtension.of(context).colors.severities.error.fg,
        ),
      ),
    );
  }
}
