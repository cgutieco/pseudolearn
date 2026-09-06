import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../application/knowledge/prediction/prediction_session_cubit.dart';
import '../../../../application/knowledge/prediction/prediction_session_state.dart';
import '../../../../application/settings/settings_cubit.dart';
import '../../../../domain/model/knowledge/prediction_activity.dart';
import '../../../../domain/model/profiles/syntax_profile_for_language.dart';
import '../../../../domain/model/settings/effective_ui_language.dart';
import '../../../components/button/app_button.dart';
import '../../../components/field/app_text_field.dart';
import '../../../components/typography/app_text.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/tokens/spacing.dart';
import 'prediction_activity_cards.dart';

final class PredictionActivityView extends StatefulWidget {
  final PredictionActivity activity;

  const PredictionActivityView({
    super.key,
    required this.activity,
  });

  @override
  State<PredictionActivityView> createState() => _PredictionActivityViewState();
}

final class _PredictionActivityViewState extends State<PredictionActivityView> {
  @override
  void initState() {
    super.initState();
    _loadActivity();
  }

  @override
  void didUpdateWidget(PredictionActivityView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activity.id != widget.activity.id) {
      _loadActivity();
    }
  }

  void _loadActivity() {
    final settings = context.read<SettingsCubit>().state;
    final systemLocale =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final effectiveLanguage = resolveEffectiveLanguage(
      setting: settings.language,
      systemLanguageCode: systemLocale,
    );
    final profile = syntaxProfileForLanguage(effectiveLanguage);
    context.read<PredictionSessionCubit>().loadActivity(
          activity: widget.activity,
          profileId: profile,
          languageId: effectiveLanguage,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PredictionSessionCubit, PredictionSessionState>(
      builder: (context, state) => _PredictionBody(state: state),
    );
  }
}

final class _PredictionBody extends StatelessWidget {
  final PredictionSessionState state;

  const _PredictionBody({required this.state});

  @override
  Widget build(BuildContext context) {
    return switch (state.status) {
      PredictionSessionStatus.initial ||
      PredictionSessionStatus.loading =>
        const _PredictionLoadingView(),
      PredictionSessionStatus.error => _PredictionErrorView(
          message: state.errorMessage,
        ),
      PredictionSessionStatus.ready => _PredictionReadyView(state: state),
      PredictionSessionStatus.result => _PredictionResultView(state: state),
    };
  }
}

final class _PredictionLoadingView extends StatelessWidget {
  const _PredictionLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(SpacingTokens.space4),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

final class _PredictionErrorView extends StatelessWidget {
  final String? message;

  const _PredictionErrorView({this.message});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.space3),
      child: AppText(
        message ?? '',
        variant: AppTextVariant.bodyDefault,
        color: theme.colors.severities.error.fg,
      ),
    );
  }
}

final class _PredictionReadyView extends StatefulWidget {
  final PredictionSessionState state;

  const _PredictionReadyView({required this.state});

  @override
  State<_PredictionReadyView> createState() => _PredictionReadyViewState();
}

final class _PredictionReadyViewState extends State<_PredictionReadyView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<PredictionSessionCubit>();

    return PredictionCard(
      sourceCode: widget.state.sourceCode,
      currentStepFocus: widget.state.currentStep?.focus,
      prompt: widget.state.activity?.prompt ?? '',
      action: Row(
        children: [
          Expanded(
            child: AppTextField(
              controller: _controller,
              placeholder: l10n.knowledgePredictionEmptyHint,
            ),
          ),
          const SizedBox(width: SpacingTokens.space3),
          AppButton(
            label: l10n.knowledgePredictionCheck,
            variant: AppButtonVariant.primary,
            onPressed: () => cubit.checkPrediction(_controller.text),
          ),
        ],
      ),
    );
  }
}

final class _PredictionResultView extends StatelessWidget {
  final PredictionSessionState state;

  const _PredictionResultView({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<PredictionSessionCubit>();

    return PredictionCard(
      sourceCode: state.sourceCode,
      currentStepFocus: state.currentStep?.focus,
      prompt: state.activity?.prompt ?? '',
      action: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PredictionOutcomeCard(
            matches: state.matches ?? false,
            predicted: state.predictedValue ?? '',
            actual: state.actualValue ?? '',
          ),
          const SizedBox(height: SpacingTokens.space3),
          Align(
            alignment: Alignment.centerRight,
            child: AppButton(
              label: l10n.knowledgePredictionRetry,
              variant: AppButtonVariant.secondary,
              onPressed: cubit.retry,
            ),
          ),
        ],
      ),
    );
  }
}
