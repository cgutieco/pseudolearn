import 'package:flutter/material.dart';
import '../../../domain/model/dashboard/next_lesson.dart';
import '../../components/button/app_button.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import 'dashboard_card.dart';
import 'required_exercises_strip.dart';

final class NextStepCard extends StatelessWidget {
  final NextLesson? nextLesson;
  final ValueChanged<String> onOpenModule;

  const NextStepCard({
    super.key,
    required this.nextLesson,
    required this.onOpenModule,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final module = nextLesson;

    return DashboardCard(
      title: l10n.dashboardNextStepTitle,
      child: module == null
          ? const _RouteCompleted()
          : _NextModuleContent(module: module, onOpenModule: onOpenModule),
    );
  }
}

final class _RouteCompleted extends StatelessWidget {
  const _RouteCompleted();

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AppText(
      l10n.dashboardNextStepDone,
      variant: AppTextVariant.bodyDefault,
      color: theme.colors.text.secondary,
    );
  }
}

final class _NextModuleContent extends StatelessWidget {
  final NextLesson module;
  final ValueChanged<String> onOpenModule;

  const _NextModuleContent({required this.module, required this.onOpenModule});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LessonHeading(module: module),
        SizedBox(height: canvas.scaled(SpacingTokens.space3)),
        RequiredExercisesStrip(count: module.requiredExercises),
        SizedBox(height: canvas.scaled(SpacingTokens.space4)),
        AppButton(
          label: l10n.dashboardNextStepOpen,
          variant: AppButtonVariant.primary,
          icon: Icons.arrow_forward_rounded,
          onPressed: () => onOpenModule(module.id),
        ),
      ],
    );
  }
}

final class _LessonHeading extends StatelessWidget {
  final NextLesson module;

  const _LessonHeading({required this.module});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final text = AppThemeExtension.of(context).colors.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(
          module.partTitle,
          variant: AppTextVariant.caption,
          color: text.tertiary,
        ),
        SizedBox(height: canvas.scaled(SpacingTokens.space1)),
        AppText(
          '${module.number} · ${module.title}',
          variant: AppTextVariant.heading3,
          color: text.primary,
        ),
      ],
    );
  }
}
