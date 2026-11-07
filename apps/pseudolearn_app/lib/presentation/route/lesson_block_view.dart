import 'package:flutter/material.dart';
import '../../domain/model/reference/reference_run.dart';
import '../../domain/model/route/lesson_block.dart';
import '../reference/blocks/reference_block_view.dart';
import '../reference/reference_runs_text.dart';
import '../components/typography/app_text.dart';
import '../theme/app_theme.dart';
import 'blocks/attempt_view.dart';
import 'blocks/brief_view.dart';
import 'blocks/cycle_strip.dart';
import 'blocks/lesson_callouts.dart';
import 'blocks/lesson_links.dart';
import 'blocks/lesson_tools.dart';
import 'blocks/practice_view.dart';
import 'lesson_scope.dart';

final class LessonBlockView extends StatelessWidget {
  final LessonBlock block;
  final LessonScope scope;

  const LessonBlockView({super.key, required this.block, required this.scope});

  @override
  Widget build(BuildContext context) {
    final block = this.block;
    return switch (block) {
      SharedLessonBlock(:final block) => ReferenceBlockView(
        block: block,
        edition: scope.edition,
        onOpenSection: scope.onOpenLink,
      ),
      PhraseLessonBlock(:final runs) => PhraseView(runs: runs, scope: scope),
      ProblemLessonBlock(:final blocks) => ProblemView(blocks: blocks, scope: scope),
      AttemptLessonBlock() => AttemptView(attempt: block, scope: scope),
      CycleLessonBlock(:final phases) => CycleStrip(active: phases),
      PhaseHeadingLessonBlock() => PhaseHeadingView(heading: block, scope: scope),
      BriefLessonBlock() => BriefView(brief: block, scope: scope),
      _ => LessonToolView(block: block, scope: scope),
    };
  }
}

final class LessonToolView extends StatelessWidget {
  final LessonBlock block;
  final LessonScope scope;

  const LessonToolView({super.key, required this.block, required this.scope});

  @override
  Widget build(BuildContext context) {
    final block = this.block;
    return switch (block) {
      ParadigmLessonBlock() => ParadigmView(paradigm: block, scope: scope),
      RolesLessonBlock(:final roles) => RolesView(roles: roles, scope: scope),
      RecallLessonBlock() => RecallView(recall: block, scope: scope),
      SpecLinksLessonBlock(:final links) => SpecLinksView(links: links, scope: scope),
      DeepenLessonBlock() => DeepenView(deepen: block, scope: scope),
      PracticeLessonBlock(:final exerciseIds) => PracticeView(ids: exerciseIds, scope: scope),
      NextLessonBlock() => NextView(next: block, scope: scope),
      SpecFigureLessonBlock() => SpecFigureView(figure: block, scope: scope),
      CalloutLessonBlock() => LessonCalloutView(callout: block, scope: scope),
      _ => const SizedBox.shrink(),
    };
  }
}

final class LessonBlockColumn extends StatelessWidget {
  final List<LessonBlock> blocks;
  final LessonScope scope;

  const LessonBlockColumn({super.key, required this.blocks, required this.scope});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final block in blocks)
          Padding(
            padding: const EdgeInsets.only(bottom: referenceBlockGap),
            child: LessonBlockView(block: block, scope: scope),
          ),
      ],
    );
  }
}

final class LessonRunsText extends StatelessWidget {
  final List<ReferenceRun> runs;
  final LessonScope scope;
  final AppTextVariant variant;
  final Color? color;

  const LessonRunsText({
    super.key,
    required this.runs,
    required this.scope,
    this.variant = AppTextVariant.bodyDefault,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ReferenceRunsText(
      runs: runs,
      onOpenSection: scope.onOpenLink,
      variant: variant,
      color: color ?? AppThemeExtension.of(context).colors.text.primary,
    );
  }
}
