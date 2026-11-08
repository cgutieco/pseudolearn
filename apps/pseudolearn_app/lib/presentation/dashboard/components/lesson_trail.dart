import 'package:flutter/material.dart';
import '../../../domain/model/dashboard/lesson_mark.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/border_metrics.dart';
import '../../theme/tokens/component_metrics.dart';
import '../../theme/tokens/icon_metrics.dart';
import '../charts/chart_palette.dart';
import '../charts/chart_reveal.dart';

final class LessonTrail extends StatelessWidget {
  final List<LessonMark> marks;
  final ValueChanged<String> onOpenModule;

  const LessonTrail({
    super.key,
    required this.marks,
    required this.onOpenModule,
  });

  @override
  Widget build(BuildContext context) {
    return ChartReveal(
      builder: (context, progress) => Row(
        children: [
          for (final (index, mark) in marks.indexed) ...[
            if (index > 0)
              Expanded(
                child: _TrailLink(lit: mark.isTouched, progress: progress),
              ),
            _LessonNode(
              mark: mark,
              progress: progress,
              onTap: () => onOpenModule(mark.lessonId),
            ),
          ],
        ],
      ),
    );
  }
}

final class _TrailLink extends StatelessWidget {
  final bool lit;
  final double progress;

  const _TrailLink({required this.lit, required this.progress});

  @override
  Widget build(BuildContext context) {
    final palette = ChartPalette.of(context);

    return Container(
      height: ComponentMetricsTokens.dashboardLessonLinkHeight,
      color: palette.track,
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: lit ? progress : 0,
        child: ColoredBox(color: palette.lessons),
      ),
    );
  }
}

final class _LessonNode extends StatelessWidget {
  final LessonMark mark;
  final double progress;
  final VoidCallback onTap;

  const _LessonNode({
    required this.mark,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      button: true,
      label: l10n.dashboardLessonNode(
        mark.number,
        lessonStageLabelOf(mark.stage, l10n),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Transform.scale(
          scale: 0.4 + 0.6 * progress,
          child: _NodeDot(mark: mark),
        ),
      ),
    );
  }
}

final class _NodeDot extends StatelessWidget {
  final LessonMark mark;

  const _NodeDot({required this.mark});

  @override
  Widget build(BuildContext context) {
    final palette = ChartPalette.of(context);
    final theme = AppThemeExtension.of(context);

    return Container(
      width: ComponentMetricsTokens.dashboardLessonNodeSize,
      height: ComponentMetricsTokens.dashboardLessonNodeSize,
      decoration: ShapeDecoration(
        color: lessonFillOf(mark.stage, palette),
        shape: CircleBorder(
          side: mark.isNext
              ? BorderSide(
                  color: palette.accent,
                  width: BorderMetricsTokens.widthChannel,
                )
              : BorderSide.none,
        ),
      ),
      child: mark.stage == LessonStage.completed
          ? Icon(
              Icons.check_rounded,
              size: IconMetricsTokens.iconXs,
              color: theme.colors.text.onBrand,
            )
          : null,
    );
  }
}

Color lessonFillOf(LessonStage stage, ChartPalette palette) => switch (stage) {
  LessonStage.completed => palette.exercises,
  LessonStage.inProgress => palette.lessons,
  LessonStage.pending => palette.track,
};

String lessonStageLabelOf(LessonStage stage, AppLocalizations l10n) =>
    switch (stage) {
      LessonStage.completed => l10n.routeLessonCompleted,
      LessonStage.inProgress => l10n.routeLessonVisited,
      LessonStage.pending => l10n.dashboardLessonPending,
    };
